#!/bin/bash
no_print = >&- 2>&-

function install {
  echo -n "Update and upgrade..."
  apt-get -y update no_print
  echo -n "Update done..."
  apt-get -y upgrade no_print
  echo "All done"
  echo "Installing web dependancies..."
  apt-get install -y vim sudo wget curl git zsh libxml2-dev libcurl3 mysql-client apache2 php5 php5-mysql php5-curl libapache2-mod-php5 php5-mcrypt php5-gd php5-cli php5-dev php5enmod mcrypt no_print
  debconf-set-selections <<< 'mysql-server mysql-server/root_password password 97ZE3Hj1Rrbn'
  debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password 97ZE3Hj1Rrbn'
  apt-get -y install mysql-server no_print
}

if netstat -laputen | grep '80$' || dpkg-query -l php5 >&- 2>&- || dpkg-query -l 'mysql*' no_print
then
  echo "Web server already installed! Do you wish to continue anyway?"
else
  if [ "$UID" -ne "0" ]
    echo "You are not sudoer! Try with sudo..."
  else
    install

    echo "All web dependancies installed!"
    echo -e "\n"

    service apache2 restart && service mysql restart no_print

    echo -e "\n"

    if [ $? -ne 0 ]; then
      echo "Please Check the Install Services, There is some $(tput bold)$(tput setaf 1) Problem $(tput sgr0)"
    else
     echo "Installed Services run $(tput bold)$(tput setaf 2)Sucessfully$(tput sgr0)"
    fi

    echo -e "\n"
  fi  
fi
