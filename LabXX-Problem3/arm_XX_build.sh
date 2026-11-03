xhost +local:root

# BUILD THE IMAGE
ROS_IMAGE="arm/labxx"
docker build -f Dockerfile -t $ROS_IMAGE .
