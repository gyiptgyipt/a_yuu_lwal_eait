FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

# Install dev tools, locales and Python3
RUN apt-get update && apt-get install -y curl wget gnupg2 lsb-release python3-pip python3-colcon-common-extensions locales build-essential && rm -rf /var/lib/apt/lists/*
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

# Install ROS1 Noetic
RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -cs) main" > /etc/apt/sources.list.d/ros1-latest.list'
RUN curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add -
RUN apt-get update && apt-get install -y ros-noetic-desktop python3-rosbag

# Install ROS2 Humble
RUN apt-get update && apt-get install -y software-properties-common
RUN add-apt-repository universe
RUN apt-get update && apt-get install -y curl gnupg2 lsb-release
RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key | apt-key add -
RUN sh -c 'echo "deb [arch=amd64] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" > /etc/apt/sources.list.d/ros2-latest.list'
RUN apt-get update && apt-get install -y ros-humble-desktop ros-humble-rosbag2

# Install ros1_bridge dependencies and tools
RUN apt-get update && apt-get install -y python3-vcstool

# Build the ros1_bridge
SHELL ["/bin/bash", "-c"]
WORKDIR /bridge_ws
RUN source /opt/ros/noetic/setup.bash && \
    source /opt/ros/humble/setup.bash && \
    mkdir src && \
    cd src && \
    git clone -b humble https://github.com/ros2/ros1_bridge.git && \
    cd .. && \
    . /opt/ros/noetic/setup.bash && \
    . /opt/ros/humble/setup.bash && \
    colcon build --packages-select ros1_bridge

# Copy the bridge & conversion script
COPY run_bridge.sh /run_bridge.sh
RUN chmod +x /run_bridge.sh
WORKDIR /data

ENTRYPOINT ["/run_bridge.sh"]