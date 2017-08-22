#!/usr/bin/env bash

set -x
WEED_ROOT=$(dirname "$BASH_SOURCE")
MASTER_IP="172.16.1.86:9333"

# the volume server will be deployed on these nodes
export nodes=${VOLUME_NODES:-"root@172.16.1.86 root@172.16.1.87 root@172.16.1.88"}

# directory name on each volume node for save data, log and executable file
WEED_DIR="/home/seaweedfs/volume"
# directory name on master node for saving data
WEED_DATA_DIR=${WEED_DIR}/data
# directory name on master node for saveing logs
WEED_LOG_DIR=${WEED_DIR}/log

# create directories for weedfs
function create_dir(){
    ssh $1 "mkdir -p ${WEED_DIR}"
    ssh $1 "mkdir -p ${WEED_DATA_DIR}"
    ssh $1 "mkdir -p ${WEED_LOG_DIR}"
}

# deploy master using ssh
for node in ${nodes[@]}
do
   # mkdir weedfs dir to save data and executable file
   create_dir $node
   scp $WEED_ROOT/weed $node:${WEED_DIR}
   cmd="nohup ${WEED_DIR}/weed volume -mserver=${MASTER_IP} -publicUrl=${node##*@} -ip=${node##*@} -ip.bind=${node##*@} > ${WEED_DIR}/volume.log 2>&1 &"
   ssh $node "$cmd"
done
