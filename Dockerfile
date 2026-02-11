FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

# Install basics
RUN apt-get update && apt-get install -y \
    wget lsb-release gnupg2 curl locales python3-pip python3-colcon-common-extensions \
    && rm -rf /var/lib/apt/lists/*

# Set locales
RUN locale-gen en_US en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Install ROS1 Noetic
RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -cs) main" > /etc/apt/sources.list.d/ros1-latest.list'
RUN curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add -
RUN apt-get update && apt-get install -y ros-noetic-desktop python3-rosbag

# Install ROS2 Humble
RUN apt-get update && apt-get install -y software-properties-common
RUN add-apt-repository universe
RUN apt-get update && apt-get install -y \
    curl gnupg2 lsb-release
RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key | apt-key add -
RUN sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" > /etc/apt/sources.list.d/ros2-latest.list'
RUN apt-get update && apt-get install -y ros-humble-desktop ros-humble-rosbag2

# Source ROS distros on container start
SHELL ["/bin/bash", "-c"]
ENV ROS1_DISTRO=noetic
ENV ROS2_DISTRO=humble

WORKDIR /ros_ws/
COPY . /ros_ws/

RUN pip3 install -r requirements.txt

ENTRYPOINT source /opt/ros/$ROS1_DISTRO/setup.bash && source /opt/ros/$ROS2_DISTRO/setup.bash && python3 -m ros1bag2ros2bag.cli