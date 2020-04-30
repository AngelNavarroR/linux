# Variables
DATE=`date +%F`
TIME=`date +%H%M`
BACKUPDIR=/backup
SEAFDIR=/srv
BACKUPFILE=$BACKUPDIR/seafile-$DATE-$TIME.tar
TEMPDIR=/tmp/seafile-$DATE-$TIME

# Shutdown seafile
systemctl stop seahub
systemctl stop seafile

# Create directories
if [ ! -d $BACKUPDIR ]
  then
  echo Creating Backupdirectory $BACKUPDIR...
  mkdir -pm 0600 $BACKUPDIR
fi
# Directorio de archivos temporales
if [ ! -d $TEMPDIR ]
  then
  echo Create temporary directory $TEMPDIR...
  mkdir -pm 0600 $TEMPDIR
  mkdir -m 0600 $TEMPDIR/databases
  mkdir -m 0600 $TEMPDIR/data
fi

# Dump data / copy data sqlite3
# echo Dumping GroupMgr database...
# sqlite3 $SEAFDIR/ccnet/GroupMgr/groupmgr.db .dump > $TEMPDIR/databases/groupmgr.db.bak
# if [ -e $TEMPDIR/databases/groupmgr.db.bak ]; then echo ok.; else echo ERROR.; fi
# echo Dumping UserMgr database...
# sqlite3 $SEAFDIR/ccnet/PeerMgr/usermgr.db .dump > $TEMPDIR/databases/usermgr.db.bak
# if [ -e $TEMPDIR/databases/usermgr.db.bak ]; then echo ok.; else echo ERROR.; fi
# echo Dumping SeaFile database...
# sqlite3 $SEAFDIR/seafile-data/seafile.db .dump > $TEMPDIR/databases/seafile.db.bak
# if [ -e $TEMPDIR/databases/seafile.db.bak ]; then echo ok.; else echo ERROR.; fi
# echo Dumping SeaHub database...
# sqlite3 $SEAFDIR/seahub.db .dump > $TEMPDIR/databases/seahub.db.bak
# if [ -e $TEMPDIR/databases/seahub.db.bak ]; then echo ok.; else echo ERROR.; fi

echo Dumping Mysql database...
#sqlite3 $SEAFDIR/ccnet/GroupMgr/groupmgr.db .dump > $TEMPDIR/databases/groupmgr.db.bak
#mysqldump -u anavarro -p arteaga31 --databases seafile_db ccnet_db seahub_db > dbdump.sql
mysqldump -u anavarro -p arteaga31 --databases seafile_server ccnet_server seahub_server > dbdump.sql

echo Copying seafile directory...
rsync -az $SEAFDIR/* $TEMPDIR/data
if [ -d $TEMPDIR/data/seafile-data ]; then echo ok.; else echo ERROR.; fi

# Start the server
systemctl start seafile
systemctl start seahub

# compress data
echo Archive the backup...
cd $TEMPDIR
tar -cf $BACKUPFILE *
gzip $BACKUPFILE
if [ -e $BACKUPFILE.gz ]; then echo ok.; else echo ERROR.; fi

# Cleanup
echo Deleting temporary files...
rm -Rf $TEMPDIR
if [ ! -d $TEMPDIR ]; then echo ok.; else echo ERROR.; fi
