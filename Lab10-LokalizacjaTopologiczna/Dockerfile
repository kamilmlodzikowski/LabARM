FROM osrf/ros:humble-desktop-full

# SETUP ENVS
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV color_prompt=yes
ENV DEBIAN_FRONTEND noninteractive
ENV NVIDIA_VISIBLE_DEVICES ${NVIDIA_VISIBLE_DEVICES:-all}
ENV NVIDIA_DRIVER_CAPABILITIES ${NVIDIA_DRIVER_CAPABILITIES:+$NVIDIA_DRIVER_CAPABILITIES,}graphics

# SETUP parallel workers
ARG parallel_workers=1

# INSTALL SOME ESSENTIAL PROGRAMS
RUN apt update
RUN apt install -y    \
        git wget bash-completion unzip python3-pip ros-$ROS_DISTRO-navigation2 ros-$ROS_DISTRO-nav2-bringup ros-$ROS_DISTRO-rtabmap-ros
RUN pip3 install rosbags

# CLONE TURTLEBOT3 GIT REPOS
RUN mkdir -p /arm_ws/src
WORKDIR /arm_ws
RUN /bin/bash -c ". /opt/ros/humble/setup.bash; colcon build --parallel-workers $parallel_workers --symlink-install"

WORKDIR /arm_ws
RUN wget https://raw.githubusercontent.com/kamilmlodzikowski/LabARM/main/Lab10-LokalizacjaTopologiczna/rtabmap.rviz
RUN /bin/bash -c ". /opt/ros/humble/setup.bash; colcon build --parallel-workers $parallel_workers --symlink-install"\

RUN ldconfig

RUN mkdir bags
RUN wget http://robotics.ethz.ch/~asl-datasets/ijrr_euroc_mav_dataset/machine_hall/MH_03_medium/MH_03_medium.bag
RUN rosbags-convert MH_03_medium.bag
RUN rm MH_03_medium.bag

# FILL BASHRC
WORKDIR /arm_ws
RUN echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> ~/.bashrc
RUN echo "source /arm_ws/install/setup.bash" >> ~/.bashrc
RUN echo "export TURTLEBOT3_MODEL=waffle" >> ~/.bashrc
