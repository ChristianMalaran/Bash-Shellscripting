#!/bin/bash
eval para1="$1"


if [ ! -f ${para1} ]; then
    echo "Non-existing file ${para1}"
    exit 0
elif [ ! -s ${para1} ]; then
    echo "Provided text file does not contain any line entries!"
    exit 0
else
    while read line; do
        if [[ $line != db[0-9][0-9][0-9][0-9][0-9][0-9] ]]; then 
            echo "Invalid data line entry in the provided text file!"
            exit 0
        fi
    done <${para1}
fi


bool=0
dbase(){
    eval pass="$1"
    data=""
    index=2
    while read line; do 
            next=`sed "${index}q;d" ${para1}`
            if [[ ${line:0:6} != ${next:0:6} ]]; then
                touch createbackupfor${line:2:4}.sh
                chmod +x createbackupfor${line:2:4}.sh
                data=$data" "$line
                echo "mysqldump -u sysad -h 127.0.0.1 -p $1 --skip-set-charset --add-drop-database --databases $data > ${line:2:4}monthlydb.sql" > createbackupfor${line:2:4}.sh
                ./createbackupfor${line:2:4}.sh $password
                bool=1
            fi
            data=$data" "$line
            ((index++))
            if [ $bool -eq 1 ]; then
                data=""
                bool=0
            fi
    done <${para1}
    bool=0
    last=`tac ${para1} |egrep -m 1 .`
    last=${last:(-6)}

    while read line; do
        if [[ $line = db????12 ]]; then 
            touch createbackupformaster.sh
            chmod +x createbackupformaster.sh
            echo "mysqldump -u sysad -h 127.0.0.1 -p $1 --skip-set-charset --add-drop-database --databases forapproval genesys_accountcharts master par > ${last}master.sql"  > createbackupformaster.sh
            ./createbackupformaster.sh $password
            touch createbackupforimage.sh
            chmod +x createbackupforimage.sh
            echo "mysqldump -u sysad -h 127.0.0.1 -p $1 --skip-set-charset --add-drop-database --databases image > ${last}image.sql" > createbackupforimage.sh 
            ./createbackupforimage.sh $password
            bool=1
            break
        fi
    done <${para1}
}
read -sp "Please provide sysad user password:" password
echo ""

dbase \$1