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
time colcon build --executor sequential --cmake-args -DCMAKE_BUILD_TYPE=Release

source ./install/setup.sh