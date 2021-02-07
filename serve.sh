#!/bin/bash

function usage {
    echo "Usage: serve -h|f|s[2] <windows|linux|pwd|other> <port> [--no-pass]"
    exit
}

if [ $# -lt 3 ]; then
    usage
fi

root=$2
if [ $root = 'pwd' ]; then
    directory=$(pwd)
elif [ $root = 'windows' ]; then
    directory='/home/florian/Documents/Tools/Windows'
elif [ $root = 'linux' ]; then
    directory='/home/florian/Documents/Tools/Linux'
else
    directory=$root
fi

method=$1
port=$3
if [ $# -eq 4 ]; then
    if [ $4 = '--no-pass' ]; then
        pass=''
        pass_reminder=''
    fi
else
    pass='-user root -password root'
    pass_reminder='/user:root root\n\n'
fi

if [ $method = '-h' ]; then
    echo "Serving HTTP in $directory..."
    if [ $port -lt 1024 ]; then
        sudo python3 -m http.server -d $directory $port
    else
        python3 -m http.server -d $directory $port
    fi

elif [ $method = '-f' ]; then
    echo "Serving FTP in $directory..."
    if [ $port -lt 1024 ]; then
        sudo python3 -m pyftpdlib -d $directory -p $port -w
    else
        python3 -m pyftpdlib -d $directory -p $port -w
    fi

elif [ $method = '-s' ]; then
    echo -en $pass_reminder
    sudo impacket-smbserver root $directory -port $port $pass
elif [ $method = '-s2' ]; then
    echo -en $pass_reminder
    sudo impacket-smbserver root $directory -port $port -smb2support $pass
fi
