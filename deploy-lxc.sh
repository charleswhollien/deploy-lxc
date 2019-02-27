#!/bin/bash
###################################################################################
# deploy-lxc.sh - 
# Author Charles Hollien
# Deploy a lxc container that can run docker in lxc via libvirt. 
#
###################################################################################
set -x
# Variables
TEMPLATE="template.xml"
DOWNLOADURL="images.linuxcontainers.org"
CONTAINERNAME=$1
CONTAINERROOT="/var/lib/container"
CONTAINERPATH="$CONTAINERROOT/${CONTAINERNAME}"
OS=$2
UUID=`uuidgen`
WORKXML="./.work/$CONTAINERNAME.xml"
CURDIR=$PWD
echo $1
echo $2
echo $3

#create work dir
mkdir -p ./.work


if [ -z $1 ]
then
echo "deploy-lxc.sh requires 3 arguments. NAME OS PATH"
echo "Current supported OS is Ubuntu Bionic (ubuntu) and Centos 7 (centos)"
echo "Path is the location where your rootfs will deploy"
echo "Example run:"
echo "./deploy-lxc.sh test1 centos /var/lib/contnainer/test1"
exit 1
fi

create_root(){
echo ""
mkdir -p $CONTAINERPATH
}

download_link(){
echo ""
centosurl=`curl -sSl https://us.images.linuxcontainers.org/meta/1.0/index-system |grep centos\;7 |grep amd64 |cut -d ';' -f 6`
ubuntuurl=`curl -sSl https://us.images.linuxcontainers.org/meta/1.0/index-system |grep ubuntu\;bionic |grep amd64 |cut -d ';' -f 6`

if [ $OS = "ubuntu" ]
then 
wget -O $CONTAINERPATH/rootfs.tar.xz $DOWNLOADURL/$ubunturl/rootfs.tar.xz
fi

if [ $OS = "centos" ]
then
echo ""
wget -O $CONTAINERPATH/rootfs.tar.xz $DOWNLOADURL/$centosurl/rootfs.tar.xz
fi
}

extractrootfs(){
cd $CONTAINERPATH
xz -d $CONTAINERPATH/rootfs.tar.xz
tar -xvf $CONTAINERPATH/rootfs.tar
rm $CONTAINERPATH/rootfs.tar
cd $CURDIR
}

update_domain(){
echo "" 
cp $TEMPLATE $WORKXML
sed -i "s/CONTAINERNAME/$CONTAINERNAME/" $WORKXML
sed -i "s/UUID/$UUID/" $WORKXML
sed -i "s/CONTAINERNAME/$CONTAINERNAME/" $WORKXML
}

create_domain(){
echo ""
virsh -c lxc:/// define $WORKXML
}

create_root
download_link
update_domain
extractrootfs
create_domain