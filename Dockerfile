FROM osrf/ros:rolling-desktop

COPY setup.sh /root/setup.sh

RUN chmod +x /root/setup.sh && /root/setup.sh
