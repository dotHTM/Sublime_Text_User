#!/usr/bin/env bash
# setup pylsp.sh

pipList='rope pyflakes mccabe pycodestyle pydocstyle autopep8 yapf python-language-server'

announcer=`which figlet || which echo`


# for i in $pipList; do
#   pip uninstall -y $i
# done

for i in $pipList; do
  $announcer $i
  pip install --upgrade $i
done

