#!/bin/bash

FILE=$HOME/Downloads/1000-Sales-Records.csv

check_condition(){
    local -n TMP=$3
    echo "Sample data file $1"
    echo "Sample data max lines $2"

    echo -n "Please select your line: "
    read TMP 
    
    if [ $TMP -lt 0 ] || [ $TMP -gt $2 ]; then
        echo "Invalid input!"
        exit 1
    fi
}
 
getLine() {
    LINE=`echo "$1" | sed 's/ /_/g' | sed 's/,/ /g'`
    echo $LINE
}

getMaxLine() {
    MAX_LENGTH=`cat $1 | wc -l`
    echo $MAX_LENGTH
}

getArrayMaxLength(){
    COUNT=0
    for i in $1; do
        ((COUNT++))
    done
    echo $COUNT
}

setArrayKeys() {
    local -n ARR=$1
    for ((i=1; i<=$(getArrayMaxLength "`echo $2`");i++ )); do
        ARR[$i]=`echo $2 | awk '{ print $'$i'}'`
    done 
}

setArrayValues(){
    local -n ARR=$1
    for ((i=1; i<=$(getArrayMaxLength "`echo $2`"); i++)); do
        ARR[$i]=${ARR[$i]}:`echo $2 | awk '{print $'$i'}'`
    done    
    
}

printArr() {
    local -n ARR=$1
    for ((i=1; i<=$(getArrayMaxLength "`echo $2`"); i++)); do
        echo ${ARR[$i]} | sed 's/_/ /g'| sed 's/:/: /g'
    done
}

MAX_LINE=$(getMaxLine $FILE)
check_condition "$FILE" "$MAX_LINE" INPUT

HEADER_LINE=$(getLine "`cat $FILE | head -n 1`")
SELECTED_LINE=$(getLine "`cat $FILE | sed -n "$INPUT"p`")

ARR_MAX_LENGTH=$(getArrayMaxLength "`echo $HEADER_LINE`") 

declare -A RESULTS

setArrayKeys RESULTS "`echo $HEADER_LINE`"

setArrayValues RESULTS "`echo $SELECTED_LINE`"

printArr RESULTS "`echo $HEADER_LINE`"
exit
