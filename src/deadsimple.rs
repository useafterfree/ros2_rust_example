use gstreamer as gst;
use gstreamer_app as gst_app;
use gst::prelude::*;

fn main() -> Result<(), anyhow::Error> {
    // Initialize GStreamer
    gst::init()?;

    // Pipeline: UDP → RTP/H264 → depay → parse → appsink
    let pipeline_str = "\
        udpsrc port=5000 \
        ! application/x-rtp, media=video, clock-rate=90000, encoding-name=H264 \
        ! rtph264depay \
        ! h264parse \
        ! appsink name=sink emit-signals=false sync=false max-buffers=1 drop=true";

    let pipeline = gst::parse::launch(pipeline_str)?;
    let pipeline = pipeline.dynamic_cast::<gst::Pipeline>().unwrap();

    // Get appsink
    let appsink = pipeline
        .by_name("sink")
        .unwrap()
        .dynamic_cast::<gst_app::AppSink>()
        .unwrap();

    // Install callbacks
    appsink.set_callbacks(
        gst_app::AppSinkCallbacks::builder()
            .new_sample(|appsink| {
                let sample = appsink.pull_sample().map_err(|_| gst::FlowError::Eos)?;
                let buffer = sample.buffer().ok_or_else(|| gst::FlowError::Error)?;

                // Map buffer into CPU-readable memory
                let map = buffer.map_readable().map_err(|_| gst::FlowError::Error)?;

                // This is compressed H.264 data
                println!("Got H264 buffer: {} bytes", map.size());

                Ok(gst::FlowSuccess::Ok)
            })
            .build(),
    );

    // Start playing
    pipeline.set_state(gst::State::Playing)?;

    // Watch bus
    let bus = pipeline.bus().unwrap();
    for msg in bus.iter_timed(gst::ClockTime::NONE) {
        use gst::MessageView;
        match msg.view() {
            MessageView::Eos(..) => {
                println!("End of stream");
                break;
            }
            MessageView::Error(err) => {
                eprintln!(
                    "Error from {:?}: {} ({:?})",
                    err.src().map(|s| s.path_string()),
                    err.error(),
                    err.debug()
                );
                break;
            }
            _ => {}
        }
    }

    pipeline.set_state(gst::State::Null)?;
    Ok(())
}
