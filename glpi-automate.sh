#!/bin/bash

banner(){
clear
echo " 						CentOS Only."
echo ""
echo "    aMMMMP dMP     dMMMMb  dMP         .aMMMb  dMP dMP dMMMMMMP .aMMMb  dMMMMMMMMb  .aMMMb dMMMMMMP dMMMMMP" 
echo "  dMP\"    dMP     dMP.dMP amr         dMP\"dMP dMP dMP    dMP   dMP\"dMP dMP\"dMP\"dMP dMP\"dMP   dMP   dMP"      
echo " dMP MMP\"dMP     dMMMMP\" dMP         dMMMMMP dMP dMP    dMP   dMP dMP dMP dMP dMP dMMMMMP   dMP   dMMMP    " 
echo " dMP.dMP dMP     dMP     dMP         dMP dMP dMP.aMP    dMP   dMP.aMP dMP dMP dMP dMP dMP   dMP   dMP        "
echo " VMMMP\" dMMMMMP dMP     dMP         dMP dMP  VMMMP\"    dMP    VMMMP\" dMP dMP dMP dMP dMP   dMP   dMMMMMP   "  
echo "												Dev: Igor Soares"                                                                                                      
}

clear_and_banner(){
	clear && banner
}

mariadb_insert_password(){
	clear_and_banner
	echo "[!]Please insert the root password of MariaDB:"
	read ROOTPASS 
	return ROOTPASS
}

download_packets(){

	### DOWNLOAD PACKETS
	clear_and_banner
	echo "[x] Starting to download packets.."
	sleep 1
	yum install epel-release yum-utils -y
	yum install -y httpd mariadb mariadb-server mariadb-devel wget 

	## DOWNLOAD PHP 7.2
	yum install -y http://rpms.remirepo.net/enterprise/remi-release-7.rpm
	echo "[x] Repository has been installed."
	sleep 1
	yum-config-manager --enable remi-php73
	echo "[x] Downloading and installing PHP.."
	sleep 3
	clear
	sudo yum install php php-common php-opcache php-mcrypt php-cli php-gd php-curl php-mysqlnd

}

clear_and_banner
echo "[x] Verifying pre-requisits..."
sleep 2

### VERIFY ID (RUN AS ROOT)

if [ $(id -u) != 0 ]; then
	echo "[!] Run as root."
	exit 1;
fi


if test -f /etc/redhat-release ; then
	echo "[x] Pre-requisite successfull. Is a CentOS"	
fi

### VERIFY SELinux
if [ $(sestatus | cut -d':' -f2) != "disabled" ]; then
	echo "[x] Disabling SELinux..."
	sleep 2
	setenforce 0 # Put in permissive mode.
	echo "[x] SELinux disabled.. Please restart your system. Do you want to restart now ? y/n "
	read CHOICE
	if [ "$CHOICE" == "y" || "$CHOICE" == "Y" ]; then
		poweroff --reboot	
	fi 
else
	echo "[x] SELinux already disabled."
fi


### DOWNLOAD PACKETS
#download_packets

### DOWNLOAD GLPI
sleep 2
clear_and_banner
if [ -d "/var/www/html/glpi" ]; then
	echo "[x] GLPI Already downloaded."
else

	if [ -f "glpi-9.5.1.tgz" ]; then
		echo "[x] Extrating files.."
		sleep 2
		gunzip glpi-9.5.1.tgz && tar -xf glpi-9.5.1.tar > /dev/null
		mv glpi /var/www/html/
		chown -R apache:apache /var/www/html/glpi
		chmod -R 775 /var/www/html/glpi
	else
		echo "[x] Downloading GLPI 9.5.1"
		wget https://github.com/glpi-project/glpi/releases/download/9.5.1/glpi-9.5.1.tgz > /dev/null
		echo "[x] Extracting files.."
		sleep 2
		gunzip glpi-9.5.1.tgz && tar -xf glpi-9.5.1.tar > /dev/null
		mv glpi /var/www/html/
		chown -R apache:apache /var/www/html/glpi
		chmod -R 775 /var/www/html/glpi
	fi
fi  

### Activating links of services and starting it..
sleep 1
clear_and_banner
echo "[!]Activating links and starting it.."
systemctl enable httpd > /dev/null
echo "[x] httpd enabled."
systemctl enable mariadb > /dev/null
echo "[x] mariadb enabled."
systemctl start httpd && systemctl start mariadb
echo "[+] httpd service daemon started."
sleep 1
echo "[+] mariadb service daemon started."
sleep 2
### MARIADB FUNCTION
clear_and_banner
echo "[x] Installing and configuring MARIADB..."
sleep 2
mysql_secure_installation
echo "You've been configured the database."
sleep 1
echo "Please insert the root password of MariaDB:"
read ROOTPASS 
mysql -u root -p"$ROOTPASS" -e "create database if not exists glpi; GRANT ALL PRIVILEGES ON glpi.* TO 'glpi'@'%' IDENTIFIED BY 'glpi'; FLUSH PRIVILEGES; "

## VERIFY IF DATABASE EXISTS. IF EXISTS, SO EVERYTHING'S FINE.
 
COUNTER=$(mysql -u root -p"$ROOTPASS" -e "show databases;" | grep -i glpi | wc -l)

while [ "$COUNTER" == 0 ]; do
	RETURNPASS=mariadb_insert_password
	COUNTER=$(mysql -u root -p"$RETURNPASS" -e "show databases;" | grep -i glpi | wc -l)
	
done 

clear_and_banner
echo "[x] Database configured..."
echo "[!] Username for login is glpi and password is glpi."
sleep 2


if [ $(ss -lnt | grep 80 | wc -l) -ge 1 ]; then
	echo "[!] To finish the configs please enter in \"http://localhost/glpi/\" and fill the needeed camps, therefore \"next\" buttons"
fi
