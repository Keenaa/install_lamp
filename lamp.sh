#!/bin/bash

current_directory="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
no_print = > /dev/null
PASSWORD = octave
DOMAIN_NAME =
DIRECTORY =
vhost_example =  "$current_directory/vhost.example.conf"
VHOST_DIR = "/etc/apache2/sites-available/"

function install {
  echo -n "Update and upgrade..."
  apt-get -y update $no_print
  echo -n "Update done..."
  apt-get -y upgrade $no_print
  echo "All done"
  echo "Installing web dependancies..."
  apt-get install -y vim sudo wget curl git zsh libxml2-dev libcurl3 mysql-client apache2 php5 php5-mysql php5-curl libapache2-mod-php5 php5-mcrypt php5-gd php5-cli php5-dev php5enmod mcrypt $no_print
  debconf-set-selections <<< 'mysql-server mysql-server/root_password password $PASSWORD'
  debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password $PASSWORD'
  apt-get -y install mysql-server $no_print

  echo "All web dependancies installed!"
  echo -e "\n"

  service apache2 restart && service mysql restart $no_print

  echo -e "\n"

  if [ $? -ne 0 ]; then
    echo "Please Check the Install Services, There is some $(tput bold)$(tput setaf 1) Problem $(tput sgr0)"
  else
    echo "Installed Services run $(tput bold)$(tput setaf 2)Sucessfully$(tput sgr0)"
  fi
}

function uninstall {
  echo "Uninstalling web dependancies..."
  apt-get remove -y mysql-server git libxml2-dev libcurl3 mysql-client apache2 php5 php5-mysql php5-curl libapache2-mod-php5 php5-mcrypt php5-gd php5-cli php5-dev php5enmod mcrypt $no_print

  echo "Web service succesfully removed!"
}

apache_installed = netstat -laputen | grep '80$' $no_print
php_installed = dpkg-query -l php5 $no_print
mysql_installed = dpkg-query -l 'mysql*' $no_print

function is_installed {
  echo apache_installed || php_installed || mysql_installed
}

function create_vhost {
  cp $vhost_example $VHOST_DIR
  mv $VHOST_DIR $VHOST_DIR$DOMAIN_NAME.conf

  #UPDATE VHOST CONF FILE
  vhost_file = $VHOST_DIR$DOMAIN_NAME.conf
  sed "s/%%ServerName%%/ServerName $DOMAIN_NAME.dev/g" $vhost_file
  sed "s/%%ErrorLog%%/ErrorLog \"logs/$DOMAIN_NAME.error_log.log\"/g" $vhost_file
  sed "s/%%AccessLog%%/AccessLog \"logs/$DOMAIN_NAME.Access_log.log\"/g" $vhost_file

  echo -n "Vhost configured!"

  a2ensite $DOMAIN_NAME.dev $no_print

  apachectl graceful $no_print

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
        echo "-v        Create a vhost with param domain name"
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
      DOMAIN_NAME = $OPTARG
      ;;
    d)
      DIRECTORY = $OPTARG
      create_vhost
      ;;
    p)
    PASSWORD = $OPTARG
    if [$1 != "-f" || $3 != "-f"]
    then
      if is_installed
      then
        echo "Web server already installed! If you want to re-install anyway try using --force-install"
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
