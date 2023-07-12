#!/bin/bash

set -x
set -e
shopt -s nullglob

source $HOME/.bashrc > /dev/null 2>&1
source ./variables > /dev/null 2>&1

create_boost_wallets() {
  DIR=$1

  echo "Creating deals and collateral wallets"
  DEALS_WALLET=$(lotus wallet new bls)
  COLLATERAL_WALLET=$(lotus wallet new bls)

  export PUBLISH_STORAGE_DEALS_WALLET=${DEALS_WALLET}
  echo "export PUBLISH_STORAGE_DEALS_WALLET=${DEALS_WALLET}" >> $HOME/.bashrc
  export COLLAT_WALLET=${COLLATERAL_WALLET}
  echo "export COLLAT_WALLET=${COLLATERAL_WALLET}" >> $HOME/.bashrc
}

set_boost_vars() {
  export BOOST_CLIENT_REPO=${BOOST_CLIENT}
  echo "export BOOST_CLIENT_REPO=${BOOST_CLIENT}" >> $HOME/.bashrc
  export BOOST_BITSWAP_REP=${BOOST_BITSWAP}
  echo "export BOOST_BITSWAP_REP=${BOOST_BITSWAP}" >> $HOME/.bashrc
  export BOOST_PATH=${BOOST_DIR}
  echo "export BOOST_PATH=${BOOST_DIR}" >> $HOME/.bashrc
  }

send_funds_to_boost() {
  lotus send --from ${OWNER_WALLET} ${PUBLISH_STORAGE_DEALS_WALLET} 0.2
  lotus send --from ${OWNER_WALLET} ${COLLAT_WALLET} 0.2
  echo "Waiting 2 minutes for funds to arrive"
  sleep 2m
}

set_boost_control_wallet() {
    lotus-miner actor control set --really-do-it ${PUBLISH_STORAGE_DEALS_WALLET}
}

install_node() {
    DIR=$1
    cd ${DIR}
    
    wget https://nodejs.org/dist/${NODEJS_VERSION}/node-${NODEJS_VERSION}-linux-x64.tar.xz
    sudo tar -C /usr/local --strip-components 1 -xf node-${NODEJS_VERSION}-linux-x64.tar.xz
    rm node-${NODEJS_VERSION}-linux-x64.tar.xz
}

build_boost() {
    DIR=$1
    cd ${DIR}
    
    git clone https://github.com/filecoin-project/boost
    cd boost
    git checkout ${BOOST_VERSION}

    if [ $USE_CALIBNET == "y" ];
        then make clean calibnet
        make booster-http
        sudo cp booster-http /usr/local/bin/

    else 
      make clean build
      make booster-http
      sudo cp booster-http /usr/local/bin/

  fi

    sudo make install
}

create_boost_wallets ${INSTALL_DIR}
set_boost_vars
send_funds_to_boost
set_boost_control_wallet
install_node ${INSTALL_DIR} 
build_boost ${INSTALL_DIR}
