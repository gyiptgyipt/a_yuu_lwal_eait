#!/bin/bash
set -e

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <ros1_bag_path> <output_ros2_bag_name>"
    exit 1
fi

source /opt/ros/noetic/setup.bash
source /opt/ros/humble/setup.bash
source /bridge_ws/install/setup.bash

ROS1_BAG=$1
ROS2_BAG=$2

# Start the bridge
ros2 run ros1_bridge dynamic_bridge --bridge-all-topics &
bridge_pid=$!

echo "Waiting for bridge to initialize..."
sleep 4

# Record in ROS2 (all bridged topics)
ros2 bag record -a -o "/data/$ROS2_BAG" &
rec_pid=$!

echo "Playing ROS1 bag: $ROS1_BAG"
rosbag play "$ROS1_BAG"

# Stop recording after playback
kill $rec_pid
kill $bridge_pid
wait