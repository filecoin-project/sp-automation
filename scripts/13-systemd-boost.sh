#!/bin/bash

set -x
set -e
shopt -s nullglob

source $HOME/.bashrc > /dev/null 2>&1
source ./variables > /dev/null 2>&1

create_env_file () {
    cat $HOME/.bashrc | grep export | sed "s/^export //" | sudo tee /etc/lotus_env > /dev/null
}

install_systemd_boostd () {
    printf "
[Unit]\n
Description=Boostd\n
After=lotus-miner.service\n
Requires=network-online.target\n\n

[Service]\n
EnvironmentFile=/etc/lotus_env\n
User=$(whoami)\n
Group=$(whoami)\n
ExecStart=/usr/local/bin/boostd run\n\n
StandardOutput=append:$LOG_DIR/boostd.log
StandardError=append:$LOG_DIR/boostd.log

[Install]\n
WantedBy=multi-user.target\n
" | sudo tee /etc/systemd/system/boostd.service > /dev/null

    sudo chmod 0644 /etc/systemd/system/boostd.service
}

install_systemd_booster () {
    printf "
[Unit]\n
Description=Booster-HTTP\n
After=boostd.service\n
Requires=network-online.target\n\n

[Service]\n
EnvironmentFile=/etc/lotus_env\n
User=$(whoami)\n
Group=$(whoami)\n
ExecStart=/usr/local/bin/booster-http run --api-boost=$BOOST_API_INFO --api-fullnode=$FULLNODE_API_INFO --api-storage=$MINER_API_INFO --port=$HTTP_PORT\n\n

StandardOutput=append:$LOG_DIR/booster-http.log
StandardError=append:$LOG_DIR/booster-http.log

[Install]\n
WantedBy=multi-user.target\n
" | sudo tee /etc/systemd/system/booster-http.service > /dev/null

    sudo chmod 0644 /etc/systemd/system/booster-http.service
}

reload_systemd () {
    sudo systemctl daemon-reload
}

stop_services () {
    killall booster-http
    killall boostd
}
start_services () {
    sudo systemctl start boostd
    sleep 5
    sudo systemctl start booster-http
}

create_env_file
install_systemd_boostd

if [ ${USE_BOOSTER_HTTP} == "y" ]; then
    install_systemd_booster
fi

reload_systemd
stop_services
start_services