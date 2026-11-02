FROM osrf/ros:jazzy-desktop-full

# SETUP ENVS
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV DEBIAN_FRONTEND=noninteractive
ENV NVIDIA_VISIBLE_DEVICES="${NVIDIA_VISIBLE_DEVICES:-all}"
ENV NVIDIA_DRIVER_CAPABILITIES="${NVIDIA_DRIVER_CAPABILITIES:+$NVIDIA_DRIVER_CAPABILITIES,}graphics"

# INSTALL SOME ESSENTIAL PROGRAMS
# (upgrade first: packages installed below are built against newer ROS core packages than the base image)
RUN apt update     && \
    apt upgrade -y && \
    apt install -y    \
        git wget bash-completion \
        ros-jazzy-ros-gz \
        ros-jazzy-cartographer \
        ros-jazzy-cartographer-ros \
        ros-jazzy-navigation2 ros-jazzy-nav2-bringup

# CLONE TURTLEBOT3 GIT REPOS
RUN mkdir -p /arm_ws/src
WORKDIR /arm_ws
RUN /bin/bash -c '. /opt/ros/jazzy/setup.bash; colcon build --symlink-install'
WORKDIR /arm_ws/src
RUN git clone -b jazzy https://github.com/ROBOTIS-GIT/DynamixelSDK.git
RUN git clone -b jazzy https://github.com/ROBOTIS-GIT/turtlebot3_msgs.git
RUN git clone -b jazzy https://github.com/ROBOTIS-GIT/turtlebot3.git
WORKDIR /arm_ws
RUN /bin/bash -c '. /opt/ros/jazzy/setup.bash; colcon build --symlink-install'
WORKDIR /arm_ws/src
RUN git clone -b jazzy https://github.com/ROBOTIS-GIT/turtlebot3_simulations.git
WORKDIR /arm_ws
RUN /bin/bash -c '. /opt/ros/jazzy/setup.bash; colcon build --symlink-install'

# CLONE LAB_05 REPO
WORKDIR /arm_ws/src
RUN git clone -b jazzy https://github.com/kamilmlodzikowski/arm05_sim.git
RUN chmod +x ./arm05_sim/scripts_arm05/spawn_aruco.py
WORKDIR /arm_ws
RUN /bin/bash -c '. /opt/ros/jazzy/setup.bash; colcon build --symlink-install'

# FILL BASHRC
RUN echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> ~/.bashrc
RUN echo "source /arm_ws/install/setup.bash" >> ~/.bashrc
RUN echo 'export TURTLEBOT3_MODEL=waffle' >> ~/.bashrc
