xhost +local:root

# BUILD THE IMAGE
ROS_IMAGE="arm/lab11"
docker build -f Dockerfile -t $ROS_IMAGE ./..
