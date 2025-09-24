use gstreamer as gst;
use gstreamer_app as gst_app;
use gst::prelude::*;

use rclrs::*;
use sensor_msgs::msg::CompressedImage;

// from: gst-launch-1.0 udpsrc port=5000 ! application/x-rtp, media=video, clock-rate=90000, encoding-name=H264 ! rtph264depay ! h264parse ! avdec_h264 ! videoconvert ! autovideosink

fn main() -> Result<(), anyhow::Error> {
    // Init GStreamer + ROS2
    gst::init()?;

    let context = Context::default_from_env()?;
    let mut executor = context.create_basic_executor();
    let node = executor.create_node("h264_relay")?;

    // Publisher: compressed H264 video packets
    let publisher = node.create_publisher::<CompressedImage>("h264/compressed")?;

    // --- Build pipeline ---
    let pipeline = gst::Pipeline::new();

    let src = gst::ElementFactory::make("udpsrc")
        .property("port", 5000i32)
        .build()?;

    let caps = gst::Caps::builder("application/x-rtp")
        .field("media", "video")
        .field("clock-rate", 90000i32)
        .field("encoding-name", "H264")
        .build();

    let capsfilter = gst::ElementFactory::make("capsfilter")
        .property("caps", &caps)
        .build()?;

    let depay = gst::ElementFactory::make("rtph264depay").build()?;
    let parse = gst::ElementFactory::make("h264parse").build()?;

    let appsink = gst_app::AppSink::builder()
        .caps(
            &gst::Caps::builder("video/x-h264")
                // you could restrict profile/stream-format here if needed
                .build(),
        )
        .sync(false)
        .build();

    // Clone publisher into closure
    let pub_clone = publisher.clone();
    appsink.set_callbacks(
        gst_app::AppSinkCallbacks::builder()
            .new_sample(move |appsink| {
                println!("New sample received");
                let sample = appsink.pull_sample().map_err(|_| gst::FlowError::Eos)?;
                let buffer = sample.buffer().ok_or_else(|| {
                    gst::element_error!(
                        appsink,
                        gst::ResourceError::Failed,
                        ("Failed to get buffer from appsink")
                    );
                    gst::FlowError::Error
                })?;

                let map = buffer.map_readable().map_err(|_| {
                    gst::element_error!(
                        appsink,
                        gst::ResourceError::Failed,
                        ("Failed to map buffer readable")
                    );
                    gst::FlowError::Error
                })?;

                // Wrap into ROS2 CompressedImage
                let mut msg = CompressedImage::default();
                msg.format = "h264".to_string();
                msg.data = map.as_slice().to_vec();

                // Optionally fill in ROS2 header timestamp
                // msg.header.stamp = builtin_interfaces::msg::Time { sec: ..., nanosec: ... };
                // msg.header.frame_id = "camera".to_string();

                if let Err(e) = pub_clone.publish(&msg) {
                    eprintln!("Publish error: {e:?}");
                }

                Ok(gst::FlowSuccess::Ok)
            })
            .build(),
    );


    pipeline.add_many(&[&src, &capsfilter, &depay, &parse, appsink.upcast_ref()])?;
    gst::Element::link_many(&[&capsfilter, &depay, &parse, appsink.upcast_ref()])?;
    src.link(&capsfilter)?;
    println!("Starting pipeline...");
    pipeline.set_state(gst::State::Playing).unwrap();
    println!("Pipeline running, relaying UDP H264 to ROS2 topic h264/compressed");

    let bus = pipeline.bus().unwrap();
    let pipeline_weak = pipeline.downgrade();
    for msg in bus.iter_timed(gst::ClockTime::NONE) {
        use gst::MessageView;
        match msg.view() {
            MessageView::Eos(..) => {
                eprintln!("EOS received");
                if let Some(p) = pipeline_weak.upgrade() {
                    let _ = p.set_state(gst::State::Null);
                }
                break;
            }
            MessageView::Error(err) => {
                eprintln!("Error: {:?}", err.error());
                break;
            }
            _ => {
                eprintln!("Other message: {:?}", msg);
            }
        }
    }

    // Spin the executor — this runs callbacks and keeps publisher alive
    // executor.spin(SpinOptions::default());

    // pipeline.set_state(gst::State::Null)?;

    // Spawn ROS2 executor thread
    // let ros_thread = std::thread::spawn({
    //     move || {
    //         executor.spin(SpinOptions::default());
    //     }
    // });

    // GStreamer main loop
    let main_loop = glib::MainLoop::new(None, false);
    main_loop.run();

    // ros_thread.join().unwrap();

    Ok(())
}
