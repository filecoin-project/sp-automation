#!/bin/bash

set -x
set -e
shopt -s nullglob

source $HOME/.bashrc > /dev/null 2>&1
source ./variables > /dev/null 2>&1

lotus_miner_api() {
  MINER_TOKEN=$(lotus-miner auth create-token --perm admin)
  echo "export MINER_API_INFO=${MINER_TOKEN}:/ip4/${MINER_IP}/tcp/${MINER_PORT}/http" >> $HOME/.bashrc
  export MINER_API_INFO=${MINER_TOKEN}:/ip4/${MINER_IP}/tcp/${MINER_PORT}/http
}

announce_miner() {
  PUB_IP=$1
  P2P_PORT=$2
  echo "Announcing miner on-chain"
  lotus-miner actor set-addrs /ip4/${PUB_IP}/tcp/${P2P_PORT}
}

add_miner_storage() {
  STORAGE=$1
  sudo chown $(whoami) ${STORAGE}
  echo "Adding storage path to miner"
  lotus-miner storage attach --init --store ${STORAGE}
  lotus-miner storage list
}

lotus_miner_api
announce_miner ${PUBLIC_IP} ${P2P_PORT}
add_miner_storage ${SEALED_STORAGE}
