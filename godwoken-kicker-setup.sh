#!/bin/bash

set -eux;

echo "# Installing development environment on debian/ubuntu"

sudo apt-get update;
sudo apt-get install -y curl;
curl -fsSL https://deb.nodesource.com/setup_14.x | sudo  bash -;
curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -;
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list;

sudo apt-get update;
sudo apt-get install -y build-essential wget git p7zip-full python nodejs yarn;

curl -fsSL https://get.docker.com | sudo  bash -;
sudo groupadd docker || true;
sudo gpasswd -a $USER docker;

echo "To use docker log out and log back in so that your group membership is re-evaluated";
echo "or use just use: 'newgrp docker' to start a subshell with a re-evaluated group membership";

newgrp docker << END
set -eux;
docker ps;
sudo rm /usr/bin/docker-compose || true;
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose;
sudo chmod +x /usr/local/bin/docker-compose;
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose;
docker-compose --version;

echo "# Running godwoken-kicker environment"

git clone https://github.com/RetricSu/godwoken-kicker.git;
cd godwoken-kicker;
make init;
make start;
END
