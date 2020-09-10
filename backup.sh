#!/usr/bin/expect -f
set timeout -1;
spawn pg_dump -h localhost -p 5432 -U sisapp -F c ejemplo -f /home/ejemplo.backup;
expect "Password:" ;
send "sisapp98\n" ;
interact
exit 0;
exit $?



