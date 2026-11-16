FROM osrf/ros:lyrical-desktop-full

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
        git wget bash-completion unzip pipx viewnior \
        ros-lyrical-vision-opencv ros-lyrical-message-filters ros-lyrical-rosbag2-storage-mcap \
        libopencv-dev python3-opencv python3-numpy python3-matplotlib python3-yaml python3-utm \
        libeigen3-dev libboost-serialization-dev libssl-dev \
        libgl1-mesa-dev libwayland-dev libxkbcommon-dev wayland-protocols libegl1-mesa-dev \
        libepoxy-dev libglew-dev libjpeg-dev libpng-dev ninja-build

# INSTALL rosbags (bag conversion) in an isolated environment
ENV PIPX_HOME=/opt/pipx
ENV PIPX_BIN_DIR=/usr/local/bin
RUN pipx install rosbags

# DOWNLOAD ROS Bags and convert them to ROS2
RUN mkdir -p /arm_ws/bags
WORKDIR /arm_ws/bags
# TUM-VI room4 (https://cvg.cit.tum.de/data/datasets/visual-inertial-dataset, CC BY 4.0)
RUN wget -q -O room4.bag https://cvg.cit.tum.de/tumvi/calibrated/512_16/dataset-room4_512_16.bag && \
    rosbags-convert --src room4.bag --dst room4 --dst-storage mcap && \
    rm room4.bag
# PUT car around the Piotrowo campus
RUN wget -q -O put_car.bag https://chmura.put.poznan.pl/s/9pkDucSDiPlwgsd/download && \
    rosbags-convert --src put_car.bag --dst put_car --dst-storage mcap && \
    rm put_car.bag

# INSTALL Pangolin (viewer used by ORB-SLAM3)
WORKDIR /
RUN git clone -b v0.9.6 --depth 1 https://github.com/stevenlovegrove/Pangolin.git
WORKDIR /Pangolin/build
RUN cmake .. -DCMAKE_BUILD_TYPE=Release -DBUILD_EXAMPLES=OFF -DBUILD_TOOLS=OFF -DBUILD_PANGOLIN_PYTHON=OFF && \
    make -j${parallel_workers} && \
    make install && \
    ldconfig

# INSTALL ORB_SLAM3
WORKDIR /
RUN git clone https://github.com/zang09/ORB-SLAM3-STEREO-FIXED ORB_SLAM3 && \
    git -C ORB_SLAM3 checkout f8ac79153b103dd44f7ea3cf2a1a4aea10b18483
WORKDIR /ORB_SLAM3
# enforce C++14
RUN printf '%s \n' "add_compile_options(-std=c++14)" | cat - CMakeLists.txt > tmpfile && mv tmpfile CMakeLists.txt
# no -march=native: with it Eigen aligns its types differently than in the ROS 2 wrapper and the system
# libraries (e.g. 64 bytes with AVX-512 vs 16), which made the stereo-inertial node crash randomly
RUN sed -i 's/ *-march=native//g' CMakeLists.txt Thirdparty/DBoW2/CMakeLists.txt Thirdparty/g2o/CMakeLists.txt && \
    ! grep -q march CMakeLists.txt Thirdparty/DBoW2/CMakeLists.txt Thirdparty/g2o/CMakeLists.txt
# FrameDrawer::Update: with two fisheye cameras (TUM-VI) the loop goes over the keypoints of both images, but
# read only the left ones (past the end of mvCurrentKeys, random segfaults)
RUN sed -i 's/mmMatchedInImage\[pMP->mnId\] = mvCurrentKeys\[i\]\.pt;/if(i < (int)mvCurrentKeys.size()) mmMatchedInImage[pMP->mnId] = mvCurrentKeys[i].pt;/; s/mvOutlierKeys\.push_back(mvCurrentKeys\[i\]);/mvOutlierKeys.push_back(i < (int)mvCurrentKeys.size() ? mvCurrentKeys[i] : mvCurrentKeysRight[i - mvCurrentKeys.size()]);/' src/FrameDrawer.cc && \
    grep -q "if(i < (int)mvCurrentKeys.size()) mmMatchedInImage" src/FrameDrawer.cc && \
    grep -q "mvCurrentKeysRight\[i - mvCurrentKeys.size()\]" src/FrameDrawer.cc
# Frame::ComputeStereoFishEyeMatches: mvDepth and mvuRight had entries only for the left keypoints, but are
# also read with indices of the right ones (e.g. in LocalMapping::CreateNewMapPoints, random segfaults);
# -1 means no stereo depth, as for left keypoints without a match
RUN sed -i 's/    mvDepth = vector<float>(Nleft,-1.0f);/    mvDepth = vector<float>(Nleft + Nright,-1.0f);/; s/    mvuRight = vector<float>(Nleft,-1);/    mvuRight = vector<float>(Nleft + Nright,-1);/' src/Frame.cc && \
    grep -q "mvDepth = vector<float>(Nleft + Nright,-1.0f);" src/Frame.cc && \
    grep -q "mvuRight = vector<float>(Nleft + Nright,-1);" src/Frame.cc
# Make all 'make -j', 'make -j4', etc. use our parallel_workers value
RUN sed -i "s/make -j[0-9]*/make -j${parallel_workers}/g" build.sh
# Sophus is header-only, its tests do not build with GCC 15 (-Werror)
RUN sed -i '/cd ..\/..\/Sophus/,/make -j/ s/-DCMAKE_BUILD_TYPE=Release/-DCMAKE_BUILD_TYPE=Release -DBUILD_TESTS=OFF -DBUILD_EXAMPLES=OFF/' build.sh && \
    grep -q BUILD_TESTS=OFF build.sh
# run the build (CMake 4 refuses the old cmake_minimum_required versions of ORB_SLAM3 and its Thirdparty
# libraries); build.sh does not stop on errors, so check that the libraries are there
RUN chmod +x build.sh && \
    CMAKE_POLICY_VERSION_MINIMUM=3.5 /bin/bash build.sh && \
    test -f lib/libORB_SLAM3.so && \
    test -f Thirdparty/DBoW2/lib/libDBoW2.so && \
    test -f Thirdparty/g2o/lib/libg2o.so

# ORB_SLAM3_ROS2
RUN mkdir -p /arm_ws/src
WORKDIR /arm_ws/src
RUN git clone -b lyrical https://github.com/kamilmlodzikowski/ORB_SLAM3_ROS2 orbslam3_ros2
WORKDIR /arm_ws/src/orbslam3_ros2/vocabulary
RUN tar xzf ORBvoc.txt.tar.gz
WORKDIR /arm_ws
RUN /bin/bash -c ". /opt/ros/lyrical/setup.bash; colcon build --parallel-workers ${parallel_workers} --symlink-install --cmake-args -DCMAKE_BUILD_TYPE=Release"

# FILL BASHRC
WORKDIR /arm_ws
RUN echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> ~/.bashrc
RUN echo "source /arm_ws/install/setup.bash" >> ~/.bashrc
