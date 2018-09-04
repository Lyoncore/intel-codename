#!/bin/bash

set -euo pipefail

if [[ $# == 0 ]]; then
    modelname=$(cat /proc/cpuinfo | grep 'model name' | head -1)
    if ! grep Intel <<<"$modelname" > /dev/null; then
        echo "You don't seem to have an Intel processor" >&2
        exit 1
    fi

    name=$(sed 's/.*\s\(\S*\) CPU.*/\1/' <<<"$modelname")
    echo "Processor name: $name" >&2
else
    name=$1
fi

links=($(curl --silent "https://ark.intel.com/search?q=$name" | pup '.result-title a attr{href}'))

results=${#links[@]}
if [[ $results == 0 ]]; then
    echo "try to find a codename"
    product=`curl --silent "https://ark.intel.com/search?q=$name" | pup 'a attr{href}'`
    url="https://ark.intel.com$product"
    codename=$(curl --silent "$url" | pup '.CodeNameText .value text{}' | xargs | sed 's/Products formerly //')
    if [ -z "$codename" ]; then
        echo "No results found" >&2
        exit 1
    else
        echo "$codename"
        exit 0
    fi
fi

link=${links[0]}
if [[ $results != 1 ]]; then
    echo "Warning: $results results found" >&2
    echo "Using: $link" >&2
fi

url="https://ark.intel.com$link"
codename=$(curl --silent "$url" | pup '.CodeNameText .value text{}' | xargs | sed 's/Products formerly //')

echo "$codename"
