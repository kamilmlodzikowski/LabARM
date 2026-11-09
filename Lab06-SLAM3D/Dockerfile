FROM osrf/ros:jazzy-desktop-full

# SETUP ENVS
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV DEBIAN_FRONTEND=noninteractive
ENV NVIDIA_VISIBLE_DEVICES="${NVIDIA_VISIBLE_DEVICES:-all}"
ENV NVIDIA_DRIVER_CAPABILITIES="${NVIDIA_DRIVER_CAPABILITIES:+$NVIDIA_DRIVER_CAPABILITIES,}graphics"

# SETUP parallel workers
ARG parallel_workers=1

# INSTALL SOME ESSENTIAL PROGRAMS
# (upgrade first: packages installed below are built against newer ROS core packages than the base image)
RUN apt update     && \
    apt upgrade -y && \
    apt install -y    \
        git wget curl gpg bash-completion unzip pipx viewnior \
        ros-jazzy-rosbag2-storage-mcap

# INSTALL GLIM (CPU version) from the author's PPA: https://koide3.github.io/glim/installation/
ARG glim_version=1.2.2
RUN curl -s --compressed "https://koide3.github.io/ppa/ubuntu2404/KEY.gpg" | gpg --dearmor > /etc/apt/trusted.gpg.d/koide3_ppa.gpg && \
    echo "deb [signed-by=/etc/apt/trusted.gpg.d/koide3_ppa.gpg] https://koide3.github.io/ppa/ubuntu2404 ./" > /etc/apt/sources.list.d/koide3_ppa.list && \
    apt update && \
    apt install -y \
        libiridescence-dev libboost-all-dev libglfw3-dev libmetis-dev \
        libgtsam-points-dev=${glim_version}* \
        ros-jazzy-glim-ros=${glim_version}* && \
    ldconfig

# INSTALL evo (trajectory evaluation) and rosbags (bag conversion) in isolated environments
ENV PIPX_HOME=/opt/pipx
ENV PIPX_BIN_DIR=/usr/local/bin
RUN pipx install evo && \
    pipx install rosbags

# DOWNLOAD 1st ROS Bag and convert it to ROS2
RUN mkdir -p /arm_ws/bags
WORKDIR /arm_ws/bags
RUN wget -q http://www.aisl.cs.tut.ac.jp/databases/hdl_graph_slam/hdl_400.bag.tar.gz && \
    tar -zxvf hdl_400.bag.tar.gz && \
    rm hdl_400.bag.tar.gz && \
    rosbags-convert --src hdl_400.bag --dst hdl_400 --dst-storage mcap && \
    rm hdl_400.bag

# DOWNLOAD 2nd ROS Bag
RUN wget -q https://chmura.put.poznan.pl/s/23jd0OBrPYvcNWB/download -O ./kitti.tar.gz && \
    tar -zxvf kitti.tar.gz && \
    rm kitti.tar.gz && \
    mv kitti2 kitti

# CREATE the workspace and INSTALL KISS-ICP
RUN mkdir -p /arm_ws/src
WORKDIR /arm_ws/src
RUN git clone -b v1.3.0 https://github.com/PRBonn/kiss-icp
WORKDIR /arm_ws
RUN /bin/bash -c ". /opt/ros/jazzy/setup.bash; colcon build --parallel-workers ${parallel_workers} --symlink-install --cmake-args -DCMAKE_BUILD_TYPE=Release"

# FAST DDS: point clouds (~2 MB) do not fit the default 512 kB shared memory segment and are
# dropped over UDP, so use larger segments (the run scripts give the container 1 GB of /dev/shm)
RUN echo '<?xml version="1.0" encoding="UTF-8" ?>\n\
<profiles xmlns="http://www.eprosima.com/XMLSchemas/fastRTPS_Profiles">\n\
  <transport_descriptors>\n\
    <transport_descriptor>\n\
      <transport_id>shm_large</transport_id>\n\
      <type>SHM</type>\n\
      <segment_size>33554432</segment_size>\n\
    </transport_descriptor>\n\
  </transport_descriptors>\n\
  <participant profile_name="default_participant" is_default_profile="true">\n\
    <rtps>\n\
      <userTransports>\n\
        <transport_id>shm_large</transport_id>\n\
      </userTransports>\n\
      <useBuiltinTransports>true</useBuiltinTransports>\n\
    </rtps>\n\
  </participant>\n\
</profiles>' > /arm_ws/fastdds_shm.xml
ENV FASTRTPS_DEFAULT_PROFILES_FILE=/arm_ws/fastdds_shm.xml

# PREPARE CONFIGS
RUN mkdir -p /arm_ws/config /arm_ws/results
# KISS-ICP: KITTI scans have no per-point timestamps (and are already motion-compensated)
RUN cp /arm_ws/src/kiss-icp/ros/config/config.yaml /arm_ws/config/kiss_icp.yaml && \
    sed -i 's/deskew: True/deskew: False/; s/# voxel_size: 1.0 .*/voxel_size: 1.0/' /arm_ws/config/kiss_icp.yaml
# GLIM: CPU, LiDAR-only (CT-ICP odometry, no IMU factors), both bags publish /velodyne_points
RUN cp -r /opt/ros/jazzy/share/glim/config /arm_ws/config/glim && \
    cd /arm_ws/config/glim && \
    sed -i 's/"config_odometry": ".*"/"config_odometry": "config_odometry_ct.json"/; s/"config_sub_mapping": ".*"/"config_sub_mapping": "config_sub_mapping_cpu.json"/; s/"config_global_mapping": ".*"/"config_global_mapping": "config_global_mapping_cpu.json"/' config.json && \
    sed -i 's/"enable_imu": true/"enable_imu": false/' config_sub_mapping_cpu.json config_global_mapping_cpu.json && \
    sed -i 's|"points_topic": ".*"|"points_topic": "/velodyne_points"|' config_ros.json

# KITTI GROUND TRUTH in TUM format: /odometry_gt has positions of the LiDAR, but orientations
# of the camera, so rotate the orientations to the LiDAR frame (otherwise RPE is wrong)
WORKDIR /arm_ws/bags
RUN evo_traj bag2 kitti /odometry_gt --save_as_tum && \
    /opt/pipx/venvs/evo/bin/python -c "\
import numpy as np; from scipy.spatial.transform import Rotation as R; \
gt = np.loadtxt('odometry_gt.tum'); \
gt[:, 4:8] = (R.from_quat(gt[:, 4:8]) * R.from_quat(gt[0, 4:8]).inv()).as_quat(); \
np.savetxt('kitti_gt.tum', gt, fmt='%.9f')" && \
    rm odometry_gt.tum

# FILL BASHRC
WORKDIR /arm_ws
RUN echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> ~/.bashrc
RUN echo "source /arm_ws/install/setup.bash" >> ~/.bashrc
