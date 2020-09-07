#!/bin/bash


####################################### INIT OF FUNCTIONS

banner(){
clear
echo " 						Redhat / CentOS Only."
echo ""
echo "    aMMMMP dMP     dMMMMb  dMP         .aMMMb  dMP dMP dMMMMMMP .aMMMb  dMMMMMMMMb  .aMMMb dMMMMMMP dMMMMMP" 
echo "  dMP\"    dMP     dMP.dMP amr         dMP\"dMP dMP dMP    dMP   dMP\"dMP dMP\"dMP\"dMP dMP\"dMP   dMP   dMP"      
echo " dMP MMP\"dMP     dMMMMP\" dMP         dMMMMMP dMP dMP    dMP   dMP dMP dMP dMP dMP dMMMMMP   dMP   dMMMP    " 
echo " dMP.dMP dMP     dMP     dMP         dMP dMP dMP.aMP    dMP   dMP.aMP dMP dMP dMP dMP dMP   dMP   dMP        "
echo " VMMMP\" dMMMMMP dMP     dMP         dMP dMP  VMMMP\"    dMP    VMMMP\" dMP dMP dMP dMP dMP   dMP   dMMMMMP   "  
echo "												github.com/igorsoares"                                                                                                      
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
	yum update -y
	yum install epel-release yum-utils wget -y
	## Create repository for MariaDB updated.
  	echo "[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.1/centos7-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1" > /etc/yum.repos.d/MariaDB10.repo
	yum install -y httpd MariaDB-server MariaDB-client 
	echo "MARIADB INSTALLED"
	sleep 7


	## DOWNLOAD PHP 7.2
	yum install -y http://rpms.remirepo.net/enterprise/remi-release-7.rpm
	echo "[x] Repository has been installed."
	sleep 3
	yum-config-manager --enable remi-php73
	echo "[x] Downloading and installing PHP.."
	sleep 3
	clear
	sudo yum install php php-ldap php-common php-opcache php-mcrypt php-cli php-gd php-curl php-mysqlnd php-mbstring php-intl php-sodium php-xmlrpc php73-php-pecl-apcu-bc php-pear-CAS php-pecl-apcu 

}

config_services(){


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

}

#################################### END OF FUNCTIONS

clear_and_banner
echo "[!] Before you start , check if you date on your system's correct."
sleep 2
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
SELINUXSTATE=$(grep -w "SELINUX" /etc/selinux/config | grep -v "#" | cut -d'=' -f 2)
COUNTER=0 # IF IS ONE, THEN WAS DISABLED SUCCESSFULLY. 
if [ "$SELINUXSTATE" != "disabled" ]; then
	echo "[x] SELinux is Enabled. Disabling..."
	sleep 2
	
	## DISABLE ON  /etc/selinux/config with backup
	if [ "$SELINUXSTATE" == "permissive" ]; then
		sed -i.bk 's/permissive/disabled/g' /etc/selinux/config
		OUTPUT=$(grep "disabled" /etc/selinux/config | grep -v "#" | wc -l)
		if [ "$OUTPUT" == "1" ]; then
			COUNTER="1"
		fi
	else
		# enforcing
		sed -i.bk 's/enforcing/disabled/g' /etc/selinux/config
		
		OUTPUT=$(grep "disabled" /etc/selinux/config | grep -v "#" | wc -l)
		if [ "$OUTPUT" == "1" ]; then
			COUNTER="1"
		fi
	fi 

	if [ "$OUTPUT" == "1" ]; then
	
		echo "[x] Please restart your system. Do you want to restart now ? y/n "
		read CHOICE
		if [ "$CHOICE" == "y" ]; then
			poweroff --reboot	
		fi 
	else
		sleep 2
		echo "[!] An error has ocurred. Exiting."
		exit 1
	fi 

else
	echo "[x] SELinux already disabled."
	sleep 2
	clear_and_banner
fi


### DOWNLOAD PACKETS
download_packets

### DOWNLOAD GLPI
sleep 2
clear_and_banner
if [ -d "/var/www/html/glpi" ]; then
	echo "[x] GLPI Already downloaded."
	sleep 2
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

config_services


### MARIADB FUNCTION
clear_and_banner
echo "[x] Installing and configuring MARIADB..."
sleep 2
mysql_secure_installation
clear_and_banner
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
