#!/usr/local/bin/bash
# run_osascript.sh

filename="$1"

errormsg=`osascript "$filename" 2>&1`
script_text=`cat "$filename"`

character_start=`echo "${errormsg}" | perl -pe 's/^.*?(\d+):.*/$1/'`
character_end=`echo "${errormsg}" | perl -pe 's/^.*?\d+:(\d+).*/$1/'`

message=`echo "${errormsg}" | perl -pe 's/.*script error: (.*)/$1/gi'`

# echo "character_start    : $character_start"
# echo "character_end      : $character_end"
# echo "----------------------------------------"

lineNumber=1
columnNumber=1
characterNumber=0
for characterNumber in `seq 1 ${#script_text}`; do

    if [[ "$characterNumber" == "$character_start" ]]; then
        start_lineNumber=$lineNumber
        start_columnNumber=$columnNumber
    fi

    if [[ "$characterNumber" == "$character_end" ]]; then
        end_lineNumber=$lineNumber
        end_columnNumber=$columnNumber
        break
    fi

    anChar=${script_text:$(( characterNumber - 1 )):1}
    columnNumber=$(( $columnNumber + 1 ))
    if [[ "$anChar" == '
' ]]; then
         lineNumber=$(( $lineNumber + 1 ))
         columnNumber=1
    fi

    # echo "$anChar , $lineNumber , $columnNumber"
done


# echo "start_lineNumber   : $start_lineNumber"
# echo "start_columnNumber : $start_columnNumber"
# echo "end_lineNumber     : $end_lineNumber"
# echo "end_columnNumber   : $end_columnNumber"
# echo "----------------------------------------"


echo "f:$filename l:$start_lineNumber c:$start_columnNumber m:$message"






















