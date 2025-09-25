#!/bin/bash

set -e

# docker run --hostname=08185713c717 --mac-address=2e:fc:2f:a0:ff:58 --env=DISPLAY=host.docker.internal:0 --env=PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin --env=LANG=C.UTF-8 --env=LC_ALL=C.UTF-8 --env=ROS_DISTRO=rolling --volume=/tmp/.X11-unix:/tmp/.X11-unix:rw --volume=/Users/boolean/ros2_ws:/root/ros2_ws --network=bridge -p 8765:8765 --restart=no --label='org.opencontainers.image.ref.name=ubuntu' --label='org.opencontainers.image.version=24.04' --runtime=runc -t -d osrf/ros:rolling-desktop

source /opt/ros/rolling/setup.bash

# screen -dmS foxglove-bridge ros2 launch foxglove_bridge foxglove_bridge_launch.xml port:=8765

## https://medium.com/@arohanaday/how-i-set-up-ros-2-on-my-macbook-using-docker-without-losing-my-sanity-fe6e55857cc2
## Rust library for foxglove
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y


cat ~/.profile

source ~/.profile

cargo install --debug cargo-ament-build  # --debug is faster to install

cd
python3 -m venv foxglove-rust
source foxglove-rust/bin/activate

pip install pyyaml 
pip install git+https://github.com/colcon/colcon-cargo.git
pip install git+https://github.com/colcon/colcon-ros-cargo.git

pip install numpy
pip install lark

