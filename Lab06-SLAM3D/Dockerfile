FROM osrf/ros:humble-desktop-full

# SETUP ENVS
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV DEBIAN_FRONTEND noninteractive
ENV NVIDIA_VISIBLE_DEVICES ${NVIDIA_VISIBLE_DEVICES:-all}
ENV NVIDIA_DRIVER_CAPABILITIES ${NVIDIA_DRIVER_CAPABILITIES:+$NVIDIA_DRIVER_CAPABILITIES,}graphics

# SETUP parallel workers
ARG parallel_workers=1

# INSTALL SOME ESSENTIAL PROGRAMS
RUN apt update     && \
    apt install -y    \
        git wget bash-completion unzip python3-pip
RUN pip3 install rosbags

# CREATE the workspace
RUN mkdir -p /arm_ws/src
WORKDIR /arm_ws
RUN /bin/bash -c ". /opt/ros/humble/setup.bash; colcon build --parallel-workers $parallel_workers --symlink-install"

# INSTALL lidarslam_ros2
WORKDIR /arm_ws/src
RUN git clone --recursive https://github.com/rsasaki0109/lidarslam_ros2
WORKDIR /arm_ws
RUN rosdep update
RUN rosdep install --from-paths src --ignore-src -r -y
RUN /bin/bash -c "	. /opt/ros/humble/setup.bash; colcon build --parallel-workers ${parallel_workers}  --symlink-install --cmake-args -DCMAKE_BUILD_TYPE=Release"

# DOWNLOAD 1st ROS Bag and convert it to ROS2
RUN mkdir bags
WORKDIR /arm_ws/bags
RUN wget http://www.aisl.cs.tut.ac.jp/databases/hdl_graph_slam/hdl_400.bag.tar.gz
RUN tar -zxvf hdl_400.bag.tar.gz
RUN rm hdl_400.bag.tar.gz
RUN rosbags-convert --src hdl_400.bag --dst hdl_400 --dst-storage sqlite3 --dst-version 8
RUN rm hdl_400.bag

# DOWNLOAD 2nd ROS Bag
RUN wget https://chmura.put.poznan.pl/s/23jd0OBrPYvcNWB/download -O ./kitti.tar.gz
RUN tar -zxvf kitti.tar.gz
RUN rm kitti.tar.gz
RUN mv kitti2 kitti

# FILL BASHRC
WORKDIR /arm_ws
RUN echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> ~/.bashrc
RUN echo "source /arm_ws/install/setup.bash" >> ~/.bashrc
