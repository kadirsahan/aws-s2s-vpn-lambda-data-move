#!/bin/bash

echo "Installing docker "

if hash docker 2>/dev/null; then
  echo "Docker aleady installed"
else
  sudo yum update -y
  sudo yum install openswan -y
  sudo amazon-linux-extras install -y docker
  sudo service docker start
  sudo usermod -a -G docker ec2-user
fi


sudo docker login -u kadirsahan -p Ks^773549
sudo docker pull emberstack/sftp

# This configuration creates a user demo with the password demo. A directory "sftp" is created for each user in the own home and is accessible for read/write
sudo docker run -d --restart always -p 2222:22 --name sftp emberstack/sftp



