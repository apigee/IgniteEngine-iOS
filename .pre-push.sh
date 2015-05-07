#!/bin/bash

RED='\033[0;31m'
NC='\033[0m' # No Color

protected_branch='master'  
current_branch=$(git symbolic-ref HEAD | sed -e 's,.*/\(.*\),\1,')

if [ $protected_branch = $current_branch ]  
then  
    printf "${RED}\nYou're trying to push to master, but that's not allowed.\nPlease use fork-and-branch workflow and submit a pull request with your changes.\n\n${NC}"
    exit 1 > /dev/null # push will not execute
else  
    exit 0 # push will execute
fi
