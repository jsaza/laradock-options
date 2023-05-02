#!/bin/bash

if [ ! -f /etc/nginx/ssl/default.crt ]; then
    openssl genrsa -out "/etc/nginx/ssl/default.key" 2048
    openssl req -new -key "/etc/nginx/ssl/default.key" -out "/etc/nginx/ssl/default.csr" -subj "/CN=default/O=default/C=UK"
    openssl x509 -req -days 365 -in "/etc/nginx/ssl/default.csr" -signkey "/etc/nginx/ssl/default.key" -out "/etc/nginx/ssl/default.crt"
    chmod 644 /etc/nginx/ssl/default.key
fi

# 秘密鍵の作成
if [ ! -f /etc/nginx/ssl/dev.local.key ]; then
    openssl genrsa -out "/etc/nginx/ssl/dev.local.key" 2048
fi

for filename in "dev1.local" "dev2.local" "dev3.local" "dev4.local" "dev5.local"
do
    if [ ! -f /etc/nginx/ssl/$filename.crt ]; then
        # CSRの作成
        openssl req -new -key "/etc/nginx/ssl/dev.local.key" -out "/etc/nginx/ssl/$filename.csr" -subj "/CN=$filename/O=EnvLocal/C=JP/ST=Fukuoka/L=Fukuoka-City/OU=developer"
        # SSLサーバー証明書の作成
        openssl x509 -req -days 3650 -in "/etc/nginx/ssl/$filename.csr" -signkey "/etc/nginx/ssl/dev.local.key" -out "/etc/nginx/ssl/$filename.crt"
        chmod 644 /etc/nginx/ssl/dev.local.key
    fi
done

# Start crond in background
crond -l 2 -b

# Start nginx in foreground
nginx