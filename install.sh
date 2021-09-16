#!/bin/bash

function jumpto
{
    label=$1
    cmd=$(sed -n "/$label:/{:a;n;p;ba};" $0 | grep -v ':$')
    eval "$cmd"
    exit
}

sudo apt update && sudo apt full-upgrade -y && sudo apt autoremove -y

#instal basic functions
sudo apt install fortune-mod cowsay -y

#add alias and fortune
echo -e "\nalias update='sudo apt update && sudo apt full-upgrade -y && sudo apt autoremove -y'" >> .bashrc
echo -e "\nfortune | cowsay" >> .bashrc

#install webmin
sudo sh -c "echo 'deb http://download.webmin.com/download/repository sarge contrib' >> /etc/apt/sources.list"
sudo wget -q -O- http://www.webmin.com/jcameron-key.asc | sudo apt-key add
sudo apt update
sudo apt install webmin -y
sudo ufw allow 10000

while true
do
    # (1) prompt user, and read command line argument
    read -p "What kind of server is this? " answer

    # (2) handle the input we were given
    case $answer in
        webserver) jumpto $answer
            echo "Installing as a Web Server."
            break;;

    docker) jumpto $answer
            echo "Installing as docker server."
            break;;

    

    * )     echo "Invalid option. Please enter a valid option.";;
    esac
done

webserver:
{
    sudo apt install apache2 certbot python3-certbot-apache -y
    sudo ufw allow 'Apache Full'

#add directories for webserver
    sudo mkdir /var/www/dracohaus.com
    sudo mkdir /var/www/dracohaus.tech
    sudo chown -R nobiryu:nobiryu /var/www/dracohaus.com
    sudo chown -R nobiryu:nobiryu /var/www/dracohaus.tech
    sudo chmod -R 755 /var/www/dracohaus.com
    sudo chmod -R 755 /var/www/dracohaus.tech
}

docker:
{
#docker install
	sudo apt install apt-transport-https ca-certificates curl software-properties-common -y
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
	sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
	sudo apt update
	sudo apt install docker-ce -y
#portainer install
	sudo docker volume create portainer_data
	sudo docker run -d -p 8000:8000 -p 9000:9000 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce
}
