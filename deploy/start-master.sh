#!/usr/bin/env bash

set -x
WEED_ROOT=$(dirname "$BASH_SOURCE")

# the master will be deployed on these nodes
export nodes=${MASTER_NODES:-"root@172.16.1.86 root@172.16.1.87 root@172.16.1.88"}

# directory name ont each master node for save data, log and executable file
WEED_DIR="/home/seaweedfs"
# directory name on master node for saving data
WEED_DATA_DIR=${WEED_DIR}/data
# directory name on master node for saveing logs
WEED_LOG_DIR=${WEED_DIR}/log

# port for master
PORT="9333"
# create directories for weedfs
function create_dir(){
    ssh $1 "mkdir -p ${WEED_DIR}"
    ssh $1 "mkdir -p ${WEED_DATA_DIR}"
    ssh $1 "mkdir -p ${WEED_LOG_DIR}"
}

# generate peers with ip and port
# @param $node
function gen_peers(){
    peers=""
    for node in ${nodes[@]}
    do 
        if [ $1 = $node ];then
            continue
        fi
        if [ "${peers}X" = "X" ];then
           peers=${node##*@}":${PORT}"
        else
           peers=$peers","${node##*@}":${PORT}"
        fi
    done
    echo $peers
}

# deploy master using ssh
for node in ${nodes[@]}
do
   # mkdir weedfs dir to save data and executable file
   create_dir $node
   scp $WEED_ROOT/weed $node:${WEED_DIR}
   peers=$(gen_peers $node)
   cmd="nohup ${WEED_DIR}/weed master -mdir=${WEED_DATA_DIR} -ip=${node##*@} -peers=$peers > ${WEED_DIR}/server.log 2>&1 &"
   ssh $node "$cmd"
done
