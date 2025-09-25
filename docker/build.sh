#!/bin/bash

set -e

BASE_IMAGE="osrf/ros:rolling-desktop@sha256:1e5bc9496885c33a2fdbdfc530eec8accddbb3a302ba8a7f9164b189a457fbfa"
STEPTWO_IMAGE="localhost:50000/ros2-rust-deps-1:latest"
STEPTHREE_IMAGE="localhost:50000/ros2-rust-deps-2:latest"
STEPFOUR_IMAGE="localhost:50000/ros2-rust-3:latest"
FINAL_IMAGE="localhost:50000/ros2-rust:latest"

echo "Building STEP 2 image (apt deps): ${STEPTWO_IMAGE} from base image: ${BASE_IMAGE}"
docker buildx build --platform linux/amd64 --tag ${STEPTWO_IMAGE} --build-arg BASE_IMAGE=${BASE_IMAGE} \
    -f Dockerfile.1 --push .

echo "Building STEP 3 image (rust and python deps: ${STEPTHREE_IMAGE} from base image: ${STEPTWO_IMAGE}"
docker buildx build --platform linux/amd64 --tag ${STEPTHREE_IMAGE} --build-arg BASE_IMAGE=${STEPTWO_IMAGE} \
    -f Dockerfile.2 --push .

echo "Building STEP 4 image (colcon deps): ${STEPFOUR_IMAGE} from base image: ${STEPTHREE_IMAGE}"
docker buildx build --platform linux/amd64 --tag ${STEPFOUR_IMAGE} --build-arg BASE_IMAGE=${STEPTHREE_IMAGE} \
    -f Dockerfile.3 --push .

echo "Building FINAL image (user code): ${FINAL_IMAGE} from base image: ${STEPFOUR_IMAGE}"
docker buildx build --platform linux/amd64 --tag ${FINAL_IMAGE} --build-arg BASE_IMAGE=${STEPFOUR_IMAGE} \
    -f Dockerfile.4 --push .