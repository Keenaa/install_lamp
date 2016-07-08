#!/bin/bash

current_directory="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PASSWORD="octave"
DOMAIN_NAME=""
DIRECTORY=""
vhost_example="$current_directory/vhost.example.conf"
VHOST_DIR="/etc/apache2/sites-available/"

function install {
  echo -n "Update and upgrade..."
  apt-get -y update > /dev/null
  echo -n "Update done..."
  apt-get -y upgrade > /dev/null
  echo "All done"
  echo "Installing web dependancies..."
  apt-get install -y vim sudo wget curl git zsh libxml2-dev libcurl3 mysql-client apache2 php5 php5-mysql php5-curl libapache2-mod-php5 php5-mcrypt php5-gd php5-cli php5-dev mcrypt > /dev/null
  debconf-set-selections <<< 'mysql-server mysql-server/root_password password $PASSWORD'
  debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password $PASSWORD'
  apt-get -y install mysql-server > /dev/null

  echo "All web dependancies installed!"
  echo -e "\n"

  service apache2 restart && service mysql restart > /dev/null

  echo -e "\n"

  if [ $? -ne 0 ]; then
    echo "Please Check the Install Services, There is some $(tput bold)$(tput setaf 1) Problem $(tput sgr0)"
  else
    echo "Installed Services run $(tput bold)$(tput setaf 2)Sucessfully$(tput sgr0)"
  fi
}

function uninstall {
  echo "Uninstalling web dependancies..."
  apt-get remove -y mysql-server git libxml2-dev libcurl3 mysql-client apache2 php5 php5-mysql php5-curl libapache2-mod-php5 php5-mcrypt php5-gd php5-cli php5-dev mcrypt > /dev/null

  echo "Web service succesfully removed!"
}

apache_installed = "netstat -laputen | grep '80$'"
php_installed = "dpkg-query -l php5"
mysql_installed = "dpkg-query -l 'mysql*'"

function is_installed {
  echo $apache_installed  > /dev/null || $php_installed  > /dev/null || $mysql_installed  > /dev/null
}

function create_vhost {
  cp $vhost_example $VHOST_DIR
  mv $VHOST_DIR $VHOST_DIR$DOMAIN_NAME.conf

  #UPDATE VHOST CONF FILE
  vhost_file="$VHOST_DIR$DOMAIN_NAME.conf"
  sed "s/%%DocumentRoot%%/DocumentRoot \"$DIRECTORY\"/g" $vhost_file
  sed "s/%%ServerName%%/ServerName $DOMAIN_NAME.dev/g" $vhost_file
  sed "s/%%Directory%%/Directory \"$DIRECTORY\"/g" $vhost_file
  sed "s/%%ErrorLog%%/ErrorLog \"logs/$DOMAIN_NAME.error_log.log\"/g" $vhost_file
  sed "s/%%CustomLog%%/CustomLog \"logs/$DOMAIN_NAME.access_log.log\"/g" $vhost_file

  echo -n "Vhost configured!"

  a2ensite $DOMAIN_NAME.dev > /dev/null

  apachectl graceful > /dev/null

  echo  -n "Vhost loaded!"

  cat /etc/hosts
  echo "127.0.0.1   $DOMAIN_NAME.dev"

  echo "Vhost finished!"
}

while getopts "hfuv:d:p:" options
do
  case $options in
    h)
        echo "-f       Launch installation even if web server is already installed"
        echo "-u       Uninstall web server"
        echo "-v        Create a vhost with param domain name don't forget to use -d next to signal the directory"
        echo "-d        To use next to -v to signal the directory name of the vhost"
        echo "-p                    Install web server with MySQL password defined by user"
        ;;
    f)
        install
        ;;
    u)
        uninstall
        ;;
    v)
      if [$2 = NULL || $3 = NULL]
      then
        echo "Missing arguments! -v expects domain name then directory as arguments"
        exit
      fi
      DOMAIN_NAME=$OPTARG
      ;;
    d)
      DIRECTORY=$OPTARG
      create_vhost
      ;;
    p)
    PASSWORD=$OPTARG
    if [$1 != "-f" || $3 != "-f"]
    then
      if is_installed
      then
        echo "Web server already installed! If you want to re-install anyway try using -f"
        exit
      else
        install
      fi
    else
      install
    fi
      ;;
  esac
done

if [ $OPTIND -eq 1 ]
then
  if is_installed
  then
    echo "Web server already installed! If you want to re-install anyway try using -f"
    exit
  else
    install
  fi
fi
