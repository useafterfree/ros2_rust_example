#!/bin/bash

set -e

source ~/.profile
source /root/foxglove-rust/bin/activate
source /opt/ros/rolling/setup.bash

mkdir -p /root/rust_ws/src && cd /root/rust_ws
git clone https://github.com/ros2-rust/ros2_rust.git src/ros2_rust

vcs import src < src/ros2_rust/ros2_rust_$ROS_DISTRO.repos

time colcon build --executor sequential --cmake-args -DCMAKE_BUILD_TYPE=Release
