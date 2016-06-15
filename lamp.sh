#!/bin/bash
if netstat -laputen | grep '80$'
then
  echo "Web server already installed! Do you wish to continue anyway?";
  read -p "Y/N" var install :
else
  apt-get update
  apt-get upgrade
  apt-get install -y vim sudo wget curl git zsh libxml2-dev libcurl3 mysql-server mysql-client apache2 php5 php5-mysql php5-curl
fi

# update repo && install softwares
#apt-get update
#apt-get upgrade

# basics
#apt-get install -y vim sudo wget curl git zsh libxml2-dev libcurl3

# (l)amp
#apt-get install mysql-server mysql-client apache2 php5 php5-mysql php5-curl

#Environnement Nodejs
#curl -sL https://deb.nodesource.com/setup_0.12 | bash -
#apt-get install -y nodejs
#curl -l https://npmjs.org/install.sh | sudo sh
#npm install -g gulp
#npm install -g grunt

#Environnement ruby
#apt-get install -y ruby-full
#gem install sass
#gem install compass
