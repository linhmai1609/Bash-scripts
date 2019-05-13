#! /bin/bash

dir="$HOME/Downloads/"
name="1000-Sales-Records.csv"

get_files_name() {
    filename=`echo $2 | sed 's/.csv//g'`    
    files_names=$(ls -l $1 | grep "$filename" | awk '{print $9}' | tr '\n' ' ')
    echo $files_names
}


getMaxLine() {
    max_line=`cat $1 | wc -l`
    echo $max_line
}

getMaxElement() {
    count=0
    for i in $1; do
        echo $i
        ((count++))        
    done  
    echo $count 
}

merge_files() {
    files_names=`get_files_name $1 $2`
    name=`echo $1$2`
    touch "$name"
    count=1
    for i in $files_names; do
        curr_file=`echo $1$i`
        if [ $count -eq 1 ]; then
            echo "`cat $curr_file | head -n 1`" >> $name
        fi
        for((j=2;j<=`getMaxLine $curr_file`; j++)); do
            echo "`cat $curr_file | sed -n "$j"p`" >> $name
        done
        ((count++)) 
    done
    echo 1
}

#files_names=`get_files_name $dir $name`
#for i in $files_names; do
#    echo $dir$i
#done 

merge_files $dir $name

exit
