xhost +local:root

# BUILD THE IMAGE
ROS_IMAGE="arm/lab07"
DOCKERFILE="Dockerfile"
WORKERS=1

while [[ $# -gt 0 ]]; do
	case "$1" in
		-l|--low-resource)
			echo "USING low-resource Dockerfile (Dockerfile_low)"
			DOCKERFILE="Dockerfile_low"
			shift
			;;
		-h|--help)
			echo "Usage: $0 [workers] [--low-resource]"
			exit 0
			;;
		*)
			WORKERS="$1"
			shift
			;;
	esac
done

echo "RUNNING WITH $WORKERS WORKER(S)"
echo "Dockerfile: $DOCKERFILE"
docker build --no-cache -f "$DOCKERFILE" --build-arg parallel_workers=$WORKERS -t $ROS_IMAGE ./..
