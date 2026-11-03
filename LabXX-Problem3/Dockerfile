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
        ros-jazzy-teleop-twist-keyboard

# DOWNLOAD 3D MODELS (cars, pedestrians, trees) FROM GAZEBO FUEL
ENV CROSSWALK_ASSETS=/opt/crosswalk_assets
ADD https://raw.githubusercontent.com/kamilmlodzikowski/arm_crosswalk_sim/main/crosswalk_sim/scripts/fetch_assets.sh /tmp/fetch_assets.sh
RUN /bin/bash -c '. /opt/ros/jazzy/setup.bash; bash /tmp/fetch_assets.sh $CROSSWALK_ASSETS'

# CREATE WORKSPACE
RUN mkdir -p /arm_ws/src
WORKDIR /arm_ws
RUN /bin/bash -c '. /opt/ros/jazzy/setup.bash; colcon build --symlink-install'

# CLONE LAB SIMULATION REPO
# (the ADD changes whenever the repo gets a new commit, so rebuilding the image always clones the latest version)
ADD https://api.github.com/repos/kamilmlodzikowski/arm_crosswalk_sim/git/refs/heads/main /tmp/arm_crosswalk_sim_version.json
WORKDIR /arm_ws/src
RUN git clone -b main https://github.com/kamilmlodzikowski/arm_crosswalk_sim.git
WORKDIR /arm_ws
RUN /bin/bash -c '. /opt/ros/jazzy/setup.bash; colcon build --symlink-install'

# FILL BASHRC
RUN echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> ~/.bashrc
RUN echo "source /arm_ws/install/setup.bash" >> ~/.bashrc
# keep ROS 2 and Gazebo traffic on this computer, so simulations of different students do not mix
RUN echo 'export ROS_AUTOMATIC_DISCOVERY_RANGE=LOCALHOST' >> ~/.bashrc
RUN echo 'export GZ_IP=127.0.0.1' >> ~/.bashrc
