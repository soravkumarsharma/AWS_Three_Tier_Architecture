#!/bin/bash

sudo yum update
yes | sudo yum install mysql
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
source ~/.bashrc
nvm install 16
nvm use 16
npm install -g pm2
cd ~/
aws s3 cp s3://devops-soravks/app-tier/ app-tier --recursive
