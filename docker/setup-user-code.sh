#!/bin/bash

set -e

cat <<'EOF' >> ~/.bashrc

source /root/foxglove-rust/bin/activate
source /opt/ros/rolling/setup.bash
cd /root/rust_ws
source ./install/setup.sh

EOF

source ~/.bashrc

mkdir -p /root/rust_ws/src && cd /root/rust_ws

git clone https://github.com/useafterfree/ros2_rust_example src/ros2_rust_example
cd src/ros2_rust_example && git checkout gstreamer && git pull
cd /root/rust_ws

source /root/foxglove-rust/bin/activate
source /opt/ros/rolling/setup.bash
cd /root/rust_ws
source ~/.profile
source ./install/setup.sh


colcon build
source ./install/setup.sh
ros2 pkg executables | grep rust
