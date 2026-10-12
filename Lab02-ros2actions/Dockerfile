FROM osrf/ros:lyrical-desktop-full

# SETUP ENVS
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV DEBIAN_FRONTEND=noninteractive
ENV NVIDIA_VISIBLE_DEVICES="${NVIDIA_VISIBLE_DEVICES:-all}"
ENV NVIDIA_DRIVER_CAPABILITIES="${NVIDIA_DRIVER_CAPABILITIES:+$NVIDIA_DRIVER_CAPABILITIES,}graphics"

# INSTALL SOME ESSENTIAL PROGRAMS
RUN apt update     && \
    apt install -y    \
        git wget bash-completion
        
RUN apt install -y \
        ros-lyrical-ros-gz \
        ros-lyrical-navigation2 \
        ros-lyrical-nav2-bringup

# CLONE TURTLEBOT3 GIT REPOS
RUN mkdir -p /arm_ws/src
WORKDIR /arm_ws
RUN /bin/bash -c '. /opt/ros/lyrical/setup.bash; colcon build --symlink-install'

WORKDIR /arm_ws/src
RUN git clone https://github.com/kamilmlodzikowski/arm02_sim.git
WORKDIR /arm_ws
RUN /bin/bash -c '. /opt/ros/lyrical/setup.bash; colcon build --symlink-install'

# FILL BASHRC
RUN echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> ~/.bashrc
RUN echo "source /arm_ws/install/setup.bash" >> ~/.bashrc
RUN echo 'export TURTLEBOT3=waffle' >> ~/.bashrc
