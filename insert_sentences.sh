#!/bin/bash 

# Write INSERT sentences with data from a .csv files to a .sql files

getMaxLine() {
    echo "`cat $1 | wc -l`"
}

information_retrieval() {
    local -n path=$1
    local -n name=$2
    local -n input=$3
    echo "INSERT INTO ?"
    read table
    
    echo "Input full name and path of the .csv file: "
    read file

    path=${file%/*}
    name=`echo ${file##*/}| sed 's/.csv//g'`
}

check_file_existence() {
    checker=`ls -l $1 | grep "$2" | awk '{print $9}'`
    if [[ "$checker" != "$3" ]]; then
        echo 0
    elif [[ "$checker" == "$3" ]]; then
        echo 1
    fi
}

add_data() {
    newFile=`echo $1/$2.sql`
    oriName=`echo $1/$2.csv`
    checker=`check_file_existence $1 $2 $newFile`
    symbol1=`echo \' , \'`
    if [[ "$checker" == "0" ]]; then
        touch "$newFile"
    fi
    for ((i=1; i<= `getMaxLine $oriName`; ++i)); do
        curr_line=`cat $oriName | sed -n "$i"p | sed 's/,/'"$symbol1"'/g'`
        echo INSERT INTO $3 VALUES \( \' $curr_line \' \)\;  >> $newFile
    done
}

information_retrieval dir file table

checker=`check_file_existence $dir $file`

add_data $dir $file $table

exit
