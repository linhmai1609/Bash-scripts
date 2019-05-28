#!/bin/bash

confpath="/home/blink1609/apache-tomcat-9.0.20"
dir=${confpath%/*}

get_input() {
    local -n host=$1
    local -n port=$2
    local -n user=$3 
    host=$(echo `cat $4 | grep "[Hh]ost=" | tr '\n' ' ' | sed 's/[Hh]ost=//g'`)
    port=$(echo `cat $4 | grep "[Pp]ort=" | tr '\n' ' ' | sed 's/[Pp]ort=//g'`)
    user=$(echo `cat $4 | grep "[Uu]ser=" | tr '\n' ' ' | sed 's/[Uu]ser=//g'`)
}

get_max_element() {
    count=0
    for i in $1; do
        ((count++))
    done
    echo $count
}

add_pub_key() {
    pub_key=`cat $HOME/.ssh/id_rsa.pub`
    component=`echo $pub_key | tr " " "\n" | awk 'NR == 2'`
    if [[ -z `ssh -p $2 $3@$1 "cat /home/$3/.ssh/authorized_keys | grep $component"` ]]; then
        ssh -p $2 $3@$1 "echo $pub_key >> /home/$3/.ssh/authorized_keys"
    fi
}

ssh_task() {
    for((i=0; i<`get_max_element $1`; i++)); do
        host=`echo $1 | awk '{print $"$i";}'`
        port=`echo $2 | awk '{print $"$i";}'`
        user=`echo $3 | awk '{print $"$i";}'`
        
        
        #ssh -p $port $user@$host "export TOMCAT_HOME=`echo /home/$user/${confpath##*/}`"
        add_pub_key $host $port $user

        #if [[ -n `cat /etc/os-release | grep [Uu]buntu` ]]; then
         #   ssh -p $port $user@$host "sudo apt-get -y install openjdk-8-jdk"
        #elif [[ -n `cat /etc/os-release | grep [Ff]edora` ]]; then
         #   ssh -p $port $user@$host "sudo yum -y install java-1.8.0-openjdk-devel" 
        #elif [[ -n `cat /etc/os-release | grep [Cc]ent[Oo]s` ]]; then
         #   ssh -p $port $user@$host "sudo yum -y install java-1.8.0-openjdk-devel"
        #fi
        ssh -p $port $user@$host "tar zxvf /home/$user/${confpath##*/}/jdk-7u80-linux-x64.tar.gz"

        scp -r $confpath $user@$host:/home/$user
        
        ssh -p $port $user@$host "sed -i 's/[Uu]ser=/User=$user/g' /home/$user/${confpath##*/}/tomcat.service"
        ssh -p $port $user@$host "sed -i 's/ExecStart=/ExecStart=\/home\/$user\/${confpath##*/}\/bin\/startup.sh/g' /home/$user/${confpath##*/}/tomcat.service"
        ssh -p $port $user@$host "sed -i 's/ExecStop=/ExecStop=\/home\/$user\/${confpath##*/}\/bin\/shutdown.sh/g' /home/$user/${confpath##*/}/tomcat.service"
        ssh -p $port $user@$host "chmod +x /home/$user/${confpath##*/}/bin/startup.sh"
        ssh -p $port $user@$host "chmod +x /home/$user/${confpath##*/}/bin/shutdown.sh"

        ssh -p $port $user@$host "sudo cp /home/$user/${confpath##*/}/tomcat.service /etc/systemd/system"
        ssh -p $port $user@$host "sudo systemctl enable tomcat.service"
        ssh -p $port $user@$host "sudo systemctl daemon-reload"
   done
}

get_input hosts ports users `echo $confpath/setup_conf.txt`
ssh_task $hosts $ports $users

exit
