# Variables
DATE=`date +%F`
TIME=`date +%H%M`
USER=$1
PASS=$2
BACKUPDIR=/backup
SEAFDIR=$3
BACKUPFILE=$BACKUPDIR/seafile-$DATE-$TIME.tar
TEMPDIR=/tmp/seafile-$DATE-$TIME

if [ "$USER" == "" ]; then
    echo "Debe agregar el usuario de mysql"
cat <<EOF 
	Ejemplo: ./seafile-backup.sh usuario pass
EOF
    exit 1
fi


if [ "$PASS" == "" ]; then
    echo "Debe agregar la contasenia del usuario"
cat <<EOF 
	Ejemplo: ./seafile-backup.sh usuario pass
EOF
    exit 1
fi

if [ "$SEAFDIR" == "" ]; then
    echo "Debe agregar la ruta de la data del seafile"
cat <<EOF 
	Ejemplo: ./seafile-backup.sh usuario pass /seafile/data
EOF
    exit 1
fi

#apt  install expect
pkg= `dpkg-query -l 'expect'`
if [[ $pkg =~ "dpkg-query: no se ha encontrado" ]]; then
    echo "Installed expect"
    { 
       apt install -y expect;
    } || {
	echo "An unexpected exception was thrown"
	exit 1
    }
fi


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

echo Dumping Mysql database...

expect_sh=$(expect -c "
        spawn mysqldump -u anavarro -p --databases seafile_server ccnet_server seahub_server -r $TEMPDIR/databases/dbdump-all.sql
        expect \"password:\"
        send \"arteaga31\r\"
        expect \"#\"
")

echo "$expect_sh"
echo "Backup dababase finish"

#interact exit'

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
if [ ! -d $TEMPDIR ]; then echo "Copy Seafile directory finish"; exit 1; else echo ERROR.; fi
exit 1
