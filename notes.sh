## Run foxglove bridge in screen session "foxglove"
screen -dmS foxglove ros2 launch foxglove_bridge foxglove_bridge_launch.xml;
## Run ROS2/Rust program
ros2 run rust_example udppublisher; 
## Run GStreamer to receive and display video
gst-launch-1.0 udpsrc port=5000   ! application/x-rtp, media=video, clock-rate=90000, encoding-name=H264   ! rtph264depay   ! h264parse   ! avdec_h264   ! videoconvert   ! jpegenc   ! image/jpeg,format=jpeg   ! appsink name=sink emit-signals=false sync=false max-buffers=1 drop=true


docker pull localhost:50000/ros2-rust:latest
docker run \
  --platform linux/amd64 \
  -it \
  -p 50001:5000/udp \
  -p 8765:8765 \
  --name ros2_container2 \
  --env="DISPLAY=host.docker.internal:0" \
  --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
  -v ~/ros2_ws:/root/ros2_ws \
  localhost:50000/ros2-rust:latest

  docker exec -it ros2_container2 bash