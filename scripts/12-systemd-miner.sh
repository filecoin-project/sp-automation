#!/bin/bash

set -x
set -e
shopt -s nullglob

source $HOME/.bashrc > /dev/null 2>&1
source ./variables > /dev/null 2>&1

create_env_file () {
    cat $HOME/.bashrc | grep export | sed "s/^export //" | sudo tee /etc/lotus_env > /dev/null
}

install_systemd_miner () {
    printf "
[Unit]\n
Description=Lotus Miner\n
After=lotus-daemon.service\n
Requires=network-online.target\n\n

[Service]\n
Environment=GOLOG_FILE=\"$LOG_DIR/lotusminer.log\"\n
EnvironmentFile=/etc/lotus_env\n
User=$(whoami)\n
Group=$(whoami)\n
ExecStartPre=/bin/sleep 30\n
ExecStart=/usr/local/bin/lotus-miner run\n\n

StandardOutput=append:$LOG_DIR/lotusminer.log
StandardError=append:$LOG_DIR/lotusminer.log

[Install]\n
WantedBy=multi-user.target\n
" | sudo tee /etc/systemd/system/lotus-miner.service > /dev/null

    sudo chmod 0644 /etc/systemd/system/lotus-miner.service
}

reload_systemd () {
    sudo systemctl daemon-reload
}

stop_services () {
    lotus-miner stop
    sleep 5
}
start_services () {
    sudo systemctl start lotus-miner
    sleep 30
}

enable_services () {
    sudo systemctl enable lotus-miner
}

create_env_file
install_systemd_miner
reload_systemd
stop_services
start_services
enable_services