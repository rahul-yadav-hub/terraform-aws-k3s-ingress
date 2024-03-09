#!/bin/bash

apt-get update -y
apt-get upgrade -y

local_ip=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
flannel_iface=$(ip -4 route ls | grep default | grep -Po '(?<=dev )(\S+)')
provider_id="$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)/$(curl -s http://169.254.169.254/latest/meta-data/instance-id)"
instance_id="$(curl -s http://169.254.169.254/latest/meta-data/instance-id)"

CUR_HOSTNAME=$(cat /etc/hostname)
NEW_HOSTNAME=$instance_id

hostnamectl set-hostname $NEW_HOSTNAME
hostname $NEW_HOSTNAME

sudo sed -i "s/$CUR_HOSTNAME/$NEW_HOSTNAME/g" /etc/hosts
sudo sed -i "s/$CUR_HOSTNAME/$NEW_HOSTNAME/g" /etc/hostname

echo "master ip ${master_ip}" > /home/ubuntu/test

curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=v1.24.17+k3s1 K3S_TOKEN=coIeS98V5UxzKYTLX0Uzzd4pkxfPSwBxiCUFtUm1sURd66mnZlT3uhk K3S_URL=https://${master_ip}:6443 sh -s - agent --node-ip $local_ip  --kubelet-arg="provider-id=aws:///$provider_id"

sleep 20s

sync; echo 3 > /proc/sys/vm/drop_caches 