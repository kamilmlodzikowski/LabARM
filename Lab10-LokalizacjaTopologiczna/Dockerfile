FROM osrf/ros:lyrical-desktop-full

# SETUP ENVS
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV DEBIAN_FRONTEND=noninteractive
ENV NVIDIA_VISIBLE_DEVICES="${NVIDIA_VISIBLE_DEVICES:-all}"
ENV NVIDIA_DRIVER_CAPABILITIES="${NVIDIA_DRIVER_CAPABILITIES:+$NVIDIA_DRIVER_CAPABILITIES,}graphics"

# INSTALL RTAB-Map and some essential programs
# (upgrade first: packages installed below are built against newer ROS core packages than the base image)
RUN apt update     && \
    apt upgrade -y && \
    apt install -y    \
        git wget bash-completion pipx \
        ros-lyrical-rtabmap-ros ros-lyrical-rosbag2-storage-mcap

# INSTALL rosbags (bag conversion) in an isolated environment
ENV PIPX_HOME=/opt/pipx
ENV PIPX_BIN_DIR=/usr/local/bin
RUN pipx install rosbags

# FIX rgbdslam_datasets.launch.py (TUM RGB-D example): static_transform_publisher on Lyrical
# no longer accepts the old "x y z yaw pitch roll frame child" arguments
RUN f=/opt/ros/lyrical/share/rtabmap_examples/launch/rgbdslam_datasets.launch.py && \
    sed -i "s/arguments=\['0.0', '0.0', '0.0', '-1.57079632679', '0.0', '-1.57079632679', 'kinect', 'openni_rgb_optical_frame'\]/arguments=['--yaw', '-1.57079632679', '--roll', '-1.57079632679', '--frame-id', 'kinect', '--child-frame-id', 'openni_rgb_optical_frame']/" $f && \
    grep -q -- "'--child-frame-id', 'openni_rgb_optical_frame'" $f

# DOWNLOAD the dataset (~1.7 GB) and convert it to ROS 2: TUM RGB-D freiburg3_long_office_household
# (https://cvg.cit.tum.de/data/datasets/rgbd-dataset, CC BY 4.0); with datasets=false
# (arm_10_build.sh --no-datasets) it is skipped and can be added later from a drive with arm_10_load_datasets.sh
ARG datasets=true
# Prepares the converted bag for rtabmap_examples rgbdslam_datasets.launch.py: frame ids without the
# leading '/' (not accepted by tf2) and /tf with only the ground truth (world -> kinect_gt, the camera
# frame is published by the launch file)
COPY <<'EOF' /opt/arm/tum_rgbd_fix.py
import sys
from rosbags.rosbag2 import CompressionFormat, CompressionMode, Reader, StoragePlugin, Writer
from rosbags.typesys import Stores, get_typestore

typestore = get_typestore(Stores.ROS2_LYRICAL)
writer = Writer(sys.argv[2], version=9, storage_plugin=StoragePlugin.MCAP)
writer.set_compression(CompressionMode.STORAGE, CompressionFormat.ZSTD)
with Reader(sys.argv[1]) as reader, writer:
    connections = {c.id: writer.add_connection(c.topic, c.msgtype, typestore=typestore) for c in reader.connections}
    for connection, timestamp, data in reader.messages():
        msg = typestore.deserialize_cdr(data, connection.msgtype)
        if connection.msgtype == 'tf2_msgs/msg/TFMessage':
            msg.transforms = [t for t in msg.transforms if t.header.frame_id == '/world']
            if not msg.transforms:
                continue
            for t in msg.transforms:
                t.header.frame_id = 'world'
                t.child_frame_id = t.child_frame_id.lstrip('/') + '_gt'
        else:
            msg.header.frame_id = msg.header.frame_id.lstrip('/')
        writer.write(connections[connection.id], timestamp, typestore.serialize_cdr(msg, connection.msgtype))
EOF
RUN mkdir -p /arm_ws/bags
WORKDIR /arm_ws/bags
RUN if [ "$datasets" = true ]; then \
        wget -q -O tum.bag https://cvg.cit.tum.de/rgbd/dataset/freiburg3/rgbd_dataset_freiburg3_long_office_household.bag && \
        rosbags-convert --src tum.bag --dst tum_ros2 --dst-storage mcap --compress zstd --compress-mode storage --include-topic \
            /tf /camera/rgb/camera_info /camera/rgb/image_color /camera/depth/camera_info /camera/depth/image && \
        /opt/pipx/venvs/rosbags/bin/python /opt/arm/tum_rgbd_fix.py tum_ros2 fr3_long_office_household && \
        rm -rf tum.bag tum_ros2; \
    fi

# RVIZ CONFIG (ADD downloads it again when it changes)
ADD --chmod=644 https://raw.githubusercontent.com/kamilmlodzikowski/LabARM/main/Lab10-LokalizacjaTopologiczna/rtabmap.rviz /arm_ws/rtabmap.rviz

# FILL BASHRC
WORKDIR /arm_ws
RUN echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> ~/.bashrc
