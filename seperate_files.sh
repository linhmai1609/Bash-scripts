#!/bin/bash

FILE="/home/blink1609/Downloads/1000-Sales-Records.csv"

check_condition() {
    local -n TMP=$3
    echo "File location: $1"
    echo "Numbers of lines: $2"
    
    echo "Please input the number of lines you want to seperate:"
    read TMP

    if [ $TMP -lt 0 ] || [ $TMP -gt $2 ]; then
        echo "Invalid input!" 
        exit 1
    fi
}

getNumberOfLine() {
    LINE=`cat $1 | wc -l` 
    echo $LINE
}

getHeader() {
    HEADER=`cat $1 | head -n 1`
    echo $HEADER 
}

seperate_files() {
    NUMBER_OF_LINES=$(getNumberOfLine $2)
    NUMBER_OF_FILES=$(( $((`getNumberOfLine $2` - 1))/$1 ))
    NUMBER_OF_ODD_LINES=$(( $((`getNumberOfLine $2` - 1 ))%$1 ))

    CURRENT_LINE=2
    
    for(( i=1; i<=$NUMBER_OF_FILES; i++ )); do
        new_file_name=`create_file "$2" $i`
        echo $(getHeader $2) >> $new_file_name
        for ((j=$CURRENT_LINE; j<$(($CURRENT_LINE+$1)); ++j)); do
            echo `cat $2 | sed -n "$j"p` >> $new_file_name
        done 
        CURRENT_LINE=$(($CURRENT_LINE+$1))
        echo $CURRENT_LINE
    done

   if [[ $NUMBER_OF_ODD_LINES -ne 0 ]]; then
        new_file_name=`create_file "$2" $(($NUMBER_OF_FILES+1))`
           echo $(getHeader $2) >> $new_file_name
        for ((i=$CURRENT_LINE; i<=$(($CURRENT_LINE+$NUMBER_OF_ODD_LINES)); ++i)); do
            echo `cat $2 | sed -n "$i"p` >> $new_file_name
        done
   fi
}

create_file() {
    dir=${1%/*}
    name="$dir/`echo ${1##*/} | sed 's/.csv//g'`-$2.csv"
    touch "$name"  
    echo $name 
}

NUMBER_OF_LINES=$(getNumberOfLine $FILE)

check_condition "$FILE" "$NUMBER_OF_LINES" INPUT

seperate_files $INPUT $FILE

exit
