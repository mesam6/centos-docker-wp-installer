#!/bin/bash

# begin with variables
_this_os=$(grep -oi centos /etc/redhat-release 2>/dev/null)
_os_version=$(rpm -E %{rhel})
_user=$(id -u)
_dockerbin=$(whereis docker)
_dockercomposebin=$(whereis docker-compose | awk '{print $2}')
_docker_rpm=$(sudo yum list installed | grep -io docker-ce)
_docker_compose_rpm=$(sudo yum list installed | grep -io docker-compose)
_dc_file="wordpress/docker-compose.yml"
option=$1


# fresh docker installation
docker_installation() {
# install yum-utils, add repo to yum-manager & install docker-ce,cli,containerd.io & start docker
sudo yum install -y yum-utils
sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install docker-ce docker-ce-cli containerd.io

# install latest docker-compose binary
sudo curl -s -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/bin/docker-compose
sudo chmod +x /usr/bin/docker-compose
# start service docker on all centos systems
if (( "$_os_version" >= "7" ))
then
sudo systemctl start docker
sudo systemctl enable docker
elif (( "$_os_version" <= "6" ))
then
sudo service docker start
sudo chkconfig docker on
fi
}



# re-install if installed already 
docker_re_installation() {
# first remove old apackages
sudo yum remove -y docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine
# remove even packages are -ce too, just package deletion, we have data at /var/lib/docker
sudo yum remove -y docker \
                docker-ce-cli \
                containerd.io \

# install yum-utils, add repo to yum-manager & install docker-ce,cli,containerd.io & start docker
sudo yum install -y yum-utils
sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install docker-ce docker-ce-cli containerd.io

# install latest docker-compose binary
sudo curl -s -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/bin/docker-compose
sudo chmod +x /usr/bin/docker-compose

if (( "$_os_version" >= "7" ))
then
sudo systemctl start docker
sudo systemctl enable docker
elif (( "$_os_version" <= "6" ))
then
sudo service docker start
sudo chkconfig docker on
fi
}


# clean everything
docker_clean() {
sudo yum remove -y docker-ce docker-ce-cli containerd.io
sudo rm -vrf /usr/bin/docker-compose
echo 'You may remove files from: /var/lib/docker/'
}


# pre-requisites for docker installtion
docker_install() {
if [ -z "$_docker_rpm" ]
then
echo '[x] No docker packages found'
while true; do
read -p 'Proceed docker & docker-compose package installation?(y/n):' yn
case $yn in
      [Yy]* ) echo 'installing..docker';docker_installation; break;;
      [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
else
echo 'Docker packages already installed.'
while true; do
read -p 'Do you wish to re-install fresh copy of Docker engine?(y/n):' yn
case $yn in
      [Yy]* ) echo 'installing..docker';docker_re_installation;break;;
      [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
fi
}

dockerwp_install() {
if [ -e "$_dc_file" ]
then
cd wordpress/; sudo docker-compose up -d;
curl -I 127.0.0.1
fi
}

dockerwp_stop() {
echo 'stopping web, app & db containers'
sudo docker stop wordpress1-web wordpress1-app wordpress1-db
}

dockerwp_delete() {
echo 'Deleting wp related containers'
sudo docker rm wordpress1-web wordpress1-app wordpress1-db
}

help() {
echo -e "Usage:\n$0 docker-install\n$0 docker-clean\n$0 wordpress-install\n$0 wordpress-stop\n$0 wordpress-delete"
}

if [ "$_user" -ne "0" ]
then
echo 'This script must be executed as root (hint:sudo)'
exit

elif [ "$_this_os" != "CentOS" ]
then
echo 'Sorry, we cannot proceed as this system is not a CentOS system.'
exit

elif [ "$option" == "docker-install" ]
then
echo 'Installing docker...'
docker_install

elif [ "$option" == "docker-clean" ]
then
echo 'Clean up docker installation'
docker_clean

elif [ "$option" == "wordpress-install" ]
then
echo 'Installing docker wordpress..;'
dockerwp_install

elif [ "$option" == "wordpress-stop" ]
then
dockerwp_stop

elif [ "$option" == "wordpress-delete" ]
then
dockerwp_delete

else
help
fi
