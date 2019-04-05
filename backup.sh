#!/usr/bin/env bash
#!/usr/bin/expect -f 

if ! `which expect 1>/dev/null`; then exit 1; yum install -y expect; fi 

set timeout -1
expect -c 'spawn ssh root@192.168.100.3 "mkdir -p /home/tesxx1/test"; 
expect "assword:"; send "sisapp98\r";
interact exit'

#interact

#mkdir -p /home/tesxx1/test


exit 0;
exit $?




