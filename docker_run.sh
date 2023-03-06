#! /bin/bash
# Runs a docker container for PX4 + ROS 2 Humble dev environment
# Requires:
#   - docker
#   - nvidia-docker
#   - an X server
# Optional:
#   - device mounting such as: joystick mounted to /dev/input/js0
#
# Authors: Mohammed Abdelkader, mohamedashraf123@gmail.com

# if [ -z "$GIT_USER" ]; then
# 	echo && echo "ERROR: Environment variable GIT_USER is not defined. Kindly export your GIT_USER" && echo
# 	exit 10
# fi

# # GIT_TOKEN must be exported (e.g. in .bashrc)
# if [ -z "$GIT_TOKEN" ]; then
# 	echo && echo "ERROR: GIT_TOKEN of the Github pkgs is not exported. Contact your Github admin to obtain it." && echo
# 	exit 10
# fi

if [ -z "$CATKIN_WS" ]; then
	CATKIN_WS=/home/user/shared_volume/catkin_ws
fi
echo "path to catkin_ws is defined at $CATKIN_WS" && echo

if [ -z "$PX4_ROOT" ]; then
	PX4_ROOT=/home/user/shared_volume

fi
echo "path to catkin_ws is defined at $CATKIN_WS" && echo

# DOCKER_REPO="mzahana/px4-dev-simulation-ubuntu22"
DOCKER_REPO="osrf/ros:humble-desktop-full"
CONTAINER_NAME="px4_ros2_humble"
WORKSPACE_DIR=~/${CONTAINER_NAME}_shared_volume
CMD=""
DOCKER_OPTS=""


# This will enable running containers with different names
# It will create a local workspace and link it to the image's catkin_ws
if [ "$1" != "" ]; then
    CONTAINER_NAME=$1
fi
WORKSPACE_DIR=~/${CONTAINER_NAME}_shared_volume
if [ ! -d $WORKSPACE_DIR ]; then
    mkdir -p $WORKSPACE_DIR
fi
echo "Container name:$CONTAINER_NAME WORSPACE DIR:$WORKSPACE_DIR" 


if [ "$2" != "" ]; then
    CMD=$2
fi

XAUTH=/tmp/.docker.xauth
xauth_list=$(xauth nlist :0 | sed -e 's/^..../ffff/')
if [ ! -f $XAUTH ]
then
    echo XAUTH file does not exist. Creating one...
    touch $XAUTH
    chmod a+r $XAUTH
    if [ ! -z "$xauth_list" ]
    then
        echo $xauth_list | xauth -f $XAUTH nmerge -
    fi
fi

# Prevent executing "docker run" when xauth failed.
if [ ! -f $XAUTH ]
then
  echo "[$XAUTH] was not properly created. Exiting..."
  exit 1
fi


echo "Shared WORKSPACE_DIR: $WORKSPACE_DIR";
 
echo "Starting Container: ${CONTAINER_NAME} with REPO: $DOCKER_REPO"

# CMD="export GIT_TOKEN=${GIT_TOKEN} && export GIT_USER=${GIT_USER} && \
#         export CATKIN_WS=$CATKIN_WS && \
#         export PX4_ROOT=$PX4_ROOT && \
#         export OSQP_SRC=/root/shared_volume/src && /bin/bash"

xhost +local:root

CMD="export CATKIN_WS=$CATKIN_WS && \
        export PX4_ROOT=$PX4_ROOT && /bin/bash"

if [ "$2" != "" ]; then
    CMD=$2
fi
echo $CMD
if [ "$(docker ps -aq -f name=${CONTAINER_NAME})" ]; then
    if [ "$(docker ps -aq -f status=exited -f name=${CONTAINER_NAME})" ]; then
        # cleanup
        echo "Restarting the container..."
        docker start ${CONTAINER_NAME}
    fi

    docker exec --user user -it ${CONTAINER_NAME} bash -c "${CMD}"

else


    # The following command clones drone_hunter_sim. It gets executed the first time the container is run
    # CMD="source /opt/ros/noetic/setup.bash  && source /root/.bashrc &&\
    # 	export ROS_PACKAGE_PATH=\$ROS_PACKAGE_PATH:$PX4_ROOT/PX4-Autopilot &&\
    #     export GIT_TOKEN=${GIT_TOKEN} && export GIT_USER=${GIT_USER} && \
    #     export CATKIN_WS=$CATKIN_WS && \
    #     export PX4_ROOT=$PX4_ROOT && \
    #     export OSQP_SRC=/root/shared_volume/src &&\
    #     if [ ! -d "$CATKIN_WS/src" ]; then
    #     mkdir -p $CATKIN_WS/src
    #     fi && \
    #     if [ ! -d "$CATKIN_WS/src/drone_hunter_sim" ]; then
    #     cd $CATKIN_WS/src
    #     git clone https://${GIT_USER}:${GIT_TOKEN}@github.com/mzahana/drone_hunter_sim.git
    #     fi && \
    #     cd $CATKIN_WS/src/drone_hunter_sim && git checkout noetic && \
    #     cd scripts && ./setup.sh && \
    #     cd \${HOME} && source .bashrc && \
    #     /bin/bash"

    CMD="export ROS_PACKAGE_PATH=\$ROS_PACKAGE_PATH:$PX4_ROOT/PX4-Autopilot &&\
        export CATKIN_WS=$CATKIN_WS && \
        export PX4_ROOT=$PX4_ROOT && /bin/bash"

    echo "Running container ${CONTAINER_NAME}..."
    #-v /dev/video0:/dev/video0 \
    docker run -it \
        --network host \
        -e LOCAL_USER_ID="$(id -u)" \
        --env="DISPLAY=$DISPLAY" \
        --env="QT_X11_NO_MITSHM=1" \
        -v /tmp/.X11-unix:/tmp/.X11-unix:ro \
        -v /dev/dri:/dev/dri\
        --volume="$WORKSPACE_DIR:/home/user/shared_volume:rw" \
        --volume="/dev/input:/dev/input" \
        --volume="$XAUTH:$XAUTH" \
        -env="XAUTHORITY=$XAUTH" \
        --publish 14556:14556/udp \
        --name=${CONTAINER_NAME} \
        --privileged \
        ${DOCKER_REPO} \
        bash -c "${CMD}"
fi

