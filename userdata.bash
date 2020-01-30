#!/bin/bash
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

## USUARIO ADMINCI
sudo sudo adduser --disabled-password --gecos "" --shell /bin/bash adminci
sudo mkdir  /home/adminci/.ssh
sudo chown adminci:adminci /home/adminci/.ssh
sudo chmod 700 /home/adminci/.ssh
sudo echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDHjUweE4Te36CQ6wRAvyA/H950ALLeR1Ew6NT/5XGJwgy7WmqWXVpVVtWjhgd6xxrGcikZ5vfb3wewtQ4lGYHNgRFtsX5bIGIYUz6DTCxyoIeTh+SyUM7hrhfqGm7i/N5ynVB0pn/7mde9lVL7+mpCgFdbPN3LO11+zX0AzRefbjEf3X1oTDCj2CdVQeWz5GEU2y+obKUIfJTdUiK8vT2U6xhxj2lD8Y2YjvdxR+5bOEBmrXCRMyllXHueip87uy+XTyP6VQicy2MbntT7Zv4u4nrBX+yMHIQthXv+3wJBC4+LJh/fjm3G5imFt4eYBxHTxVuBUuGa4nKcUNy+xJHJ adminci" > /home/adminci/.ssh/authorized_keys
sudo echo "adminci    ALL = NOPASSWD: ALL" >> /etc/sudoers
sudo chown adminci:adminci /home/adminci/.ssh/authorized_keys
sudo chmod 600 /home/adminci/.ssh/authorized_keys


## PACKAGES
sudo apt-get install git
sudo apt-get install -y openssh-server
sudo apt-add-repository -y ppa:ansible/ansible
sudo apt update -y 
sudo apt install -y ansible

## RUN PLAYBOOK

git clone https://github.com/jacky9595/ansible-artifactory.git

sudo mv /var/lib/waagent/custom-script/download/0/ansible-artifactory /home/ubuntu
sudo chown ubuntu:ubuntu -R /home/ubuntu/ansible-artifactory
cd /home/ubuntu/ansible-artifactory/
ansible-playbook playbook-artifactory.yml




