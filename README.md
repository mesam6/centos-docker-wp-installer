CentOS Docker Installer + Test LEMP WordPress containers stack

Supported OS: CentOS

Language: bash

Author: shyamsundar bhat

Description: This bash script will help you with install Docker packages on your CentOS system & helps build a default WordPress LEMP stack.

Usage:

./centos-docker-wp-installer.sh docker-install

./centos-docker-wp-installer.sh docker-clean

./centos-docker-wp-installer.sh wordpress-install

./centos-docker-wp-installer.sh wordpress-stop

./centos-docker-wp-installer.sh wordpress-delete



docker-install : 
1. Installs docker-ce, cli & containerd.io packages
2. Installs docker-compose into your local usr:bin
3. Enables docker as default service & starts docker.

docker-clean:
1. Removes packages installed related to docker.
2. Assists on remaining cleanup.

wordpress-install:
1. Copies wordpress default docker confs for db, nginx-fpm & app services & builds container.
2. Includes full configuration to change passwords etc.
3. Change domain name in nginx.conf, use /etc/hosts if testing locally.
4. Default WP, you need to access localhost or local domain via browser.

wordpress-stop:
1. Stops all containers created by this script.

wordpress-delete:
1. Deletes all containers created by this script.
