#!/usr/bin/env bash
# tidy.sh
#   Description
#
#   Written by Mike Cramer
#   Started on DATE


main(){
  for filepath in $*; do
    if [[ -n $filepath && -e $filepath ]]; then
      result=`perltidy -se -b $filepath 2>&1`
      if [[ -n $result ]]; then
        echo "$filepath"
        echo "$result"
      fi
    fi
  done
}

main $*
