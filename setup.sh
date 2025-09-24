# docker run --hostname=08185713c717 --mac-address=2e:fc:2f:a0:ff:58 --env=DISPLAY=host.docker.internal:0 --env=PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin --env=LANG=C.UTF-8 --env=LC_ALL=C.UTF-8 --env=ROS_DISTRO=rolling --volume=/tmp/.X11-unix:/tmp/.X11-unix:rw --volume=/Users/boolean/ros2_ws:/root/ros2_ws --network=bridge -p 8765:8765 --restart=no --label='org.opencontainers.image.ref.name=ubuntu' --label='org.opencontainers.image.version=24.04' --runtime=runc -t -d osrf/ros:rolling-desktop

apt update
apt install -y ros-$ROS_DISTRO-foxglove-bridge vim screen
source /opt/ros/rolling/setup.bash

# screen -dmS foxglove-bridge ros2 launch foxglove_bridge foxglove_bridge_launch.xml port:=8765

## https://medium.com/@arohanaday/how-i-set-up-ros-2-on-my-macbook-using-docker-without-losing-my-sanity-fe6e55857cc2
## Rust library for foxglove
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

apt install -y git libclang-dev python3-pip python3-vcstool python3.12-venv

cargo install --debug cargo-ament-build  # --debug is faster to install

cd
python3 -m venv foxglove-rust
source foxglove-rust/bin/activate

pip install pyyaml 
pip install git+https://github.com/colcon/colcon-cargo.git
pip install git+https://github.com/colcon/colcon-ros-cargo.git

mkdir -p rust_ws/src && cd rust_ws
git clone https://github.com/ros2-rust/ros2_rust.git src/ros2_rust
git clone https://github.com/useafterfree/ros2_rust_example src/ros2_rust_example

vcs import src < src/ros2_rust/ros2_rust_$ROS_DISTRO.repos

cd src

apt install -y ros-rolling-test-msgs

cd ../..
pip install numpy
pip install lark
# colcon build
time colcon build --executor sequential --cmake-args -DCMAKE_BUILD_TYPE=Release

## Gstreamer
apt-get install libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev \
      gstreamer1.0-plugins-base gstreamer1.0-plugins-good \
      gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly \
      gstreamer1.0-libav libgstrtspserver-1.0-dev libges-1.0-dev gstreamer1.0-tools