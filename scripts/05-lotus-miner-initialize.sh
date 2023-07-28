#!/usr/bin/bash

set -x
set -e
shopt -s nullglob

source $HOME/.bashrc > /dev/null 2>&1
source ./variables > /dev/null 2>&1

create_wallet() {
  DIR=$1
  
  echo "Creating owner and worker wallets"
  OWNER_WALLET=$(lotus wallet new bls)
  WORKER_WALLET=$(lotus wallet new bls)
  
  echo "export OWNER_WALLET=${OWNER_WALLET}" >> $HOME/.bashrc
  echo "export WORKER_WALLET=${WORKER_WALLET}" >> $HOME/.bashrc

}

transfer_funds() {
  echo "Transfer funds to $OWNER_WALLET and $WORKER_WALLET "
  while true; do
      read -p "Have you transfered funds for the given wallet? (y/n) " choice
      if [ "$choice" == "y" ]; then
          echo "Waiting for funds to arrive. It might take a couple of minutes..."
          break
      elif [ "$choice" == "n" ]; then
          echo -e "Please transfer funds for the given wallet to continue. \nIf you wish stop the installation, press ctrl-c"
      else
          echo "Invalid input"
      fi
  done
}

wait_for_funds() {
  prev_balance=$(lotus wallet list | awk '{print $2}')
  while true; do
      current_balance=$(lotus wallet list | awk '{print $2}')
      if [ "${current_balance}" != "${prev_balance}" ]; then
          echo "The FIL has arrived. Continuing.."
          prev_balance=${current_balance}
          break
      else
          echo -e "Transfer funds to: \n- Owner wallet: $OWNER_WALLET \n- Worker wallet: $WORKER_WALLET "
      fi
      sleep 1m
  done
}

initialize_sp() {
  SIZE=$1
  export FIL_PROOFS_PARAMETER_CACHE=$PARAM_CACHE
  echo "export FIL_PROOFS_PARAMETER_CACHE=$PARAM_CACHE" >> $HOME/.bashrc
  export FIL_PROOFS_PARENT_CACHE=$PARENT_CACHE
  echo "export FIL_PROOFS_PARENT_CACHE=$PARENT_CACHE" >> $HOME/.bashrc

  export LOTUS_SEALING_AGGREGATECOMMITS=false
  echo "export LOTUS_SEALING_AGGREGATECOMMITS=false" >> $HOME/.bashrc
  export LOTUS_SEALING_BATCHPRECOMMITS=false
  echo "export LOTUS_SEALING_BATCHPRECOMMITS=false" >> $HOME/.bashrc
  
  export LOTUS_MINER_PATH=${LOTUS_MINER_PATH}
  echo "export LOTUS_MINER_PATH=${LOTUS_MINER_PATH}" >> $HOME/.bashrc

  echo "Fetching ca.150GB parameter files. This might take a long time..."
  #lotus-miner fetch-params ${SIZE}

  echo "Initializing lotus-miner..."
  lotus-miner init --no-local-storage --owner=$OWNER_WALLET --worker=$WORKER_WALLET --sector-size=${SIZE}
}

start_miner() {
  DIR=$1
  nohup lotus-miner run > ${DIR}/lotusminer.log 2>&1 &
  echo "Starting lotus-miner"
  }

configure_miner() {
    IP=$1
    PORT=$2
    DIR=$3
    
    mv ${DIR}/config.toml ${DIR}/config.toml.backup

    printf "
[API]\n
  ListenAddress = \"/ip4/0.0.0.0/tcp/${PORT}/http\"\n
  RemoteListenAddress = \"${IP}:${PORT}\"\n
  Timeout = \"30s\"\n\n

[Storage]\n
  AllowAddPiece = false\n
  AllowPreCommit1 = false\n
  AllowPreCommit2 = false\n
  AllowCommit = true\n
  AllowUnseal = true\n
  AllowReplicaUpdate = true\n
  AllowProveReplicaUpdate2 = true\n
  " > ${DIR}/config.toml
}

stop_miner(){
  lotus-miner stop
  sleep 15
}

wait_for_miner(){
  LOG=$1
  while ! grep -q "starting up miner" ${LOG}/lotusminer.log; do
    sleep 1
  done
  lotus-miner info
  sleep 5 
}

create_wallet ${INSTALL_DIR}
transfer_funds
wait_for_funds
initialize_sp ${SECTOR_SIZE}
configure_miner ${MINER_IP} ${MINER_PORT} ${LOTUS_MINER_PATH}
start_miner ${LOG_DIR}
#stop_miner
#start_miner ${LOG_DIR}
wait_for_miner ${LOG_DIR}
