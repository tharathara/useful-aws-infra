#!/bin/bash

#exit if error occurs
set -e

while ! grep "Cloud-init .* finished" /var/log/cloud-init.log; do
    echo "$(date -Ins) Waiting for cloud-init to finish"
    sleep 2
done

sudo apt remove --purge unattended-upgrades -y


sudo apt-get update -y
# sudo apt-get remove man-db -y
# sudo apt-get install build-essential -y
# sudo apt-get install landscape-common -y

# sudo dpkg-reconfigure debconf --frontend=noninteractive

# export DEBIAN_FRONTEND="noninteractive"
# sudo apt-get dist-upgrade -y


#install awscli
sudo apt-get install awscli -y

#increase limits
#https://www.linkedin.com/pulse/ec2-tuning-1m-tcp-connections-using-linux-stephen-blum/
# sudo touch /etc/sysctl.d/60-file-max.conf
# sudo touch /etc/security/limits.d/60-nofile-limit.conf
# sudo touch /etc/security/limits.d/60-core-limit.conf
# echo 'fs.file-max = 1048576' | sudo tee -a /etc/sysctl.d/60-file-max.conf
# echo '* soft nofile 1048576' | sudo tee -a /etc/security/limits.d/60-nofile-limit.conf
# echo '* hard nofile 1048576' | sudo tee -a /etc/security/limits.d/60-nofile-limit.conf
# echo '* soft nproc 1048576' | sudo tee -a /etc/security/limits.d/60-nofile-limit.conf
# echo '* hard nproc 1048576' | sudo tee -a /etc/security/limits.d/60-nofile-limit.conf
# echo '* - core unlimited' | sudo tee -a /etc/security/limits.d/60-core-limit.conf

# sudo apt-get install awscli git -y
# sudo apt-get install zip unzip -y
# sudo apt-get install net-tools -y
# sudo apt-get install curl wget jq -y
# sudo apt-get install zstd -y

# sudo apt autoremove --purge snapd -y

ssh-keyscan github.com >> /home/ubuntu/.ssh/known_hosts
#need to configure more secure way
sudo cp /tmp/mizu_jenkins_github_key mizu_jenkins_github_key
sudo chmod 776 /home/ubuntu/mizu_jenkins_github_key

#install cloudwatch agent
cd /tmp
wget -nv https://amazoncloudwatch-agent-us-east-1.s3.dualstack.us-east-1.amazonaws.com/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
sudo dpkg -i amazon-cloudwatch-agent.deb

sudo mkdir -p /usr/share/collectd/
sudo touch /usr/share/collectd/types.db


# sudo apt-get install -f
# sudo apt-get autoremove -y
# sudo apt-get clean

# sudo systemctl disable apt-daily.service
# sudo systemctl disable apt-daily.timer

# sudo systemctl disable apt-daily-upgrade.timer
# sudo systemctl disable apt-daily-upgrade.service

echo "Build done"

