#!/usr/bin/env bash
#https://www.youtube.com/watch?v=gRtvs8JAXyY
yum install -y samba-common
yum install -y samba-swat
yum -y install system-config-samba

firewall-cmd --zone=public --add-service=samba --permanent
firewall-cmd --zone=public --add-port=901/tcp --permanent
firewall-cmd --zone=public --add-port=137/tcp --permanent
firewall-cmd --zone=public --add-port=138/tcp --permanent
firewall-cmd --zone=public --add-port=139/tcp --permanent
firewall-cmd --zone=public --add-port=445/tcp --permanent
firewall-cmd --reload

cp /etc/samba/smb.conf /etc/samba/smb.conf.backup
cp /etc/samba/smb.conf.example /etc/samba/smb.conf
nano /etc/samba/smb.conf 

systemctl start smb 
systemctl start nmb 
systemctl start xinetd 

 netstat -na | grep 901

 #https://lintut.com/easy-samba-installation-on-rhel-centos-7/
 
 
nano /etc/samba/smb.conf

#global
	host allow = 192.168.0.0


[RestrictedAdmin]
	path = /home/test/
	read only = yes
	guest ok = no
	valid user = test
	browseable = yes
	
# guardamos 

chcon -R -t samba_share_t /home/test/ 
semanager fcontext -a -t samba_share_t "/home/test/"


