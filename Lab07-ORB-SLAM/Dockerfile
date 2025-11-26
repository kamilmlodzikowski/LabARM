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
RUN apt update
RUN apt install -y    \
        git wget bash-completion unzip python3-pip ros-$ROS_DISTRO-vision-opencv ros-$ROS_DISTRO-message-filters libopencv-dev python3-opencv python3-dev python3-numpy python3-yaml libeigen3-dev libsuitesparse-dev libboost-dev libboost-iostreams-dev libboost-filesystem-dev libboost-date-time-dev libboost-serialization-dev libboost-thread-dev libblas-dev liblapack-dev libgflags-dev libgoogle-glog-dev libqglviewer-dev-qt5
RUN pip3 install rosbags

# CREATE the workspace
RUN mkdir -p /arm_ws/src
WORKDIR /arm_ws
RUN /bin/bash -c ". /opt/ros/humble/setup.bash; colcon build --parallel-workers $parallel_workers --symlink-install"

# INSTALL dependencies
WORKDIR /
RUN git clone https://github.com/stevenlovegrove/Pangolin.git
WORKDIR /Pangolin
RUN printf "y" | /bin/bash ./scripts/install_prerequisites.sh recommended
RUN mkdir build
WORKDIR /Pangolin/build
RUN cmake ..
RUN make -j$parallel_workers
RUN make install

# INSTALL ORB_SLAM3
WORKDIR /
RUN git clone https://github.com/zang09/ORB-SLAM3-STEREO-FIXED ORB_SLAM3
WORKDIR /ORB_SLAM3
# enforce C++14
RUN printf '%s \n' "add_compile_options(-std=c++14)" | cat - CMakeLists.txt > tmpfile && mv tmpfile CMakeLists.txt
# Make all 'make -j', 'make -j4', etc. use our parallel_workers value
RUN sed -i "s/make -j[0-9]*/make -j${parallel_workers}/g" build.sh
# run the build
RUN chmod +x build.sh && /bin/bash build.sh
# install Sophus
WORKDIR /ORB_SLAM3/Thirdparty/Sophus/build
RUN make install


# ORB_SLAM3_ROS2
WORKDIR /arm_ws/src
RUN git clone -b humble https://github.com/kamilmlodzikowski/ORB_SLAM3_ROS2 orbslam3_ros2
WORKDIR /arm_ws/src/orbslam3_ros2/vocabulary 
RUN tar xvzf ORBvoc.txt.tar.gz

# DOWNLOAD 1st ROS Bag and convert it to ROS2
WORKDIR /arm_ws
RUN mkdir bags
WORKDIR /arm_ws/bags
RUN wget http://robotics.ethz.ch/~asl-datasets/ijrr_euroc_mav_dataset/machine_hall/MH_02_easy/MH_02_easy.bag
RUN wget -O put_car.bag https://chmura.put.poznan.pl/s/9pkDucSDiPlwgsd/download
RUN rosbags-convert --src MH_02_easy.bag --dst MH_02_easy
RUN rosbags-convert --src put_car.bag --dst put_car
RUN rm MH_02_easy.bag
RUN rm put_car.bag

RUN ldconfig

# FILL BASHRC
WORKDIR /arm_ws
RUN echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> ~/.bashrc
RUN echo "source /arm_ws/install/setup.bash" >> ~/.bashrc
