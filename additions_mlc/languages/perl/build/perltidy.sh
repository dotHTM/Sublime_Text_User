#!/usr/bin/env bash
# tidy.sh
#   Description
#
#   Written by Mike Cramer
#   Started on DATE


perltidy_bin='/usr/local/bin/perltidy'

main(){
  for filepath in $*; do
    if [[ -n $filepath && -e $filepath ]]; then
      result=`$perltidy_bin -se -b $filepath 2>&1`
      if [[ -n $result ]]; then
        echo "$filepath"
        echo "$result"
      fi
    fi
  done
}

main $*
