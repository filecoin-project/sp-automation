#!/bin/bash

set -x
set -e
shopt -s nullglob

source $HOME/.bashrc > /dev/null 2>&1
source ./variables > /dev/null 2>&1

install_nginx () {
    sudo apt update
    sudo apt install openssl nginx -y
}

set_booster_http_credentials () {
    sudo mkdir /etc/nginx/ipfs-gateway.conf.d
    sudo htpasswd -b -c /etc/nginx/ipfs-gateway.conf.d/.htpasswd ${HTTP_USER} ${HTTP_PASSW}
}

set_rate_limiting () {
    printf '
limit_req_zone $binary_remote_addr zone=client_ip_10rs:1m rate=1r/s;\n
' | sudo tee /etc/nginx/ipfs-gateway.conf.d/ipfs-gateway.conf 2>&1 &

}

configure_reverse_proxy () {
    if [[ ${CERT_FILE} && ${CERT_KEY} ]];
    then printf "
# ipfs gateway config\n
include /etc/nginx/ipfs-gateway.conf.d/ipfs-gateway.conf;\n
server {\n
        listen ${PROXY_PORT} ssl;\n
        listen [::]:${PROXY_PORT} ssl;\n\n

        server_name ${BOOSTER_HTTP_DNS};\n\n

        ssl_certificate ${CERT_FILE};\n
        ssl_certificate_key ${CERT_KEY};\n
        ssl_protocols TLSv1.2;\n
        ssl_prefer_server_ciphers on;\n
        ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-SHA384;\n\n

       location /piece/ {\n
                proxy_pass http://127.0.0.1:${HTTP_PORT};\n
                auth_basic \"Restricted Server\";\n
                auth_basic_user_file /etc/nginx/ipfs-gateway.conf.d/.htpasswd;\n   

        location /ipfs/ {\n
                proxy_pass http://127.0.0.1:${HTTP_PORT};\n
                auth_basic \"Restricted Server\";\n
                auth_basic_user_file /etc/nginx/ipfs-gateway.conf.d/.htpasswd;\n                
        }\n
}\n
    " | sudo tee /etc/nginx/sites-enabled/ipfs > /dev/null
    else 
        sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/ipfs.key -out /etc/ssl/certs/ipfs.crt -subj "/C=GB/ST=London/L=London/O=Global Security/OU=IT Department/CN=example.com"
        printf "
# ipfs gateway config\n
include /etc/nginx/ipfs-gateway.conf.d/ipfs-gateway.conf;\n
server {\n
        listen ${PROXY_PORT} ssl;\n
        listen [::]:${PROXY_PORT} ssl;\n\n

        server_name ${BOOSTER_HTTP_DNS};\n\n

        ssl_certificate /etc/ssl/certs/ipfs.crt;\n
        ssl_certificate_key /etc/ssl/private/ipfs.key;\n
        ssl_protocols TLSv1.2;\n
        ssl_prefer_server_ciphers on;\n
        ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-SHA384;\n\n

        location /piece/ {\n
                proxy_pass http://127.0.0.1:${HTTP_PORT};\n
                auth_basic \"Restricted Server\";\n
                auth_basic_user_file /etc/nginx/ipfs-gateway.conf.d/.htpasswd;\n                  
        }\n
        location /ipfs/ {\n
                proxy_pass http://127.0.0.1:${HTTP_PORT};\n
                auth_basic \"Restricted Server\";\n
                auth_basic_user_file /etc/nginx/ipfs-gateway.conf.d/.htpasswd;\n  
        }\n
}\n
    " | sudo tee /etc/nginx/sites-enabled/ipfs > /dev/null
    fi
}

start_nginx () {
    sudo systemctl stop apache2
    sudo systemctl disable apache2
    sudo systemctl start nginx
    sudo systemctl enable nginx
}

set_booster_http_retrievals () {
      sed -i -e "/HTTPRetrievalMultiaddr =/ s/= .*/= \"\/dns\/${BOOSTER_HTTP_DNS}\/tcp\/${PROXY_PORT}\/https\"/" ${BOOST_DIR}/config.toml  
}

if [ ${USE_BOOSTER_HTTP} == "y" ]; then
    install_nginx
    set_booster_http_credentials
    set_rate_limiting
    configure_reverse_proxy
    start_nginx
    set_booster_http_retrievals
fi