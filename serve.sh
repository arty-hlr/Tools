#!/bin/bash

function usage {
    echo "Usage: serve -h|f|s <windows|linux|pwd|other> [interface] [port] [-N | --no-pass]"
    exit
}


if [ $# -lt 2 ]; then
    usage
fi

ARGS=$(getopt -o ":h:f:s:,N" -l no-pass -- "$@")
eval set -- "$ARGS"

pass='-user root -password root'
pass_reminder='/user:root root\n\n'

while true; do
    case "$1" in
        -h|-f|-s) root=$2;;&
        -h) method='http';shift 2;;
        -f) method='ftp';shift 2;;
        -s) method='smb';shift 2;;
        -N|--no-pass) pass='';pass_reminder='';shift;;
        --) shift; break;;
        *) break;;
    esac
done

if [ $root == 'pwd' ] || [ $root == '.' ]; then
    directory=$(pwd)
elif [ $root == 'windows' ]; then
    directory='/home/kali/Documents/Tools/Windows/www-root'
elif [ $root == 'linux' ]; then
    directory='/home/kali/Documents/Tools/Linux/www-root'
else
    directory=$root
fi

ls $directory
echo ''
if [ $# -lt 1 ]; then
    ip='0.0.0.0'
    port=''
elif [ $# -eq 1 ]; then
    if [ $1 -eq $1 ] 2>/dev/null; then
        # if arg is number
        ip='0.0.0.0'
        port=$1
    else
        ip=$(ifconfig $1 | grep -oP 'inet \d+\.\d+\.\d+\.\d+' | cut -d ' ' -f 2)
        port=''
    fi
elif [ $# -eq 2 ]; then
    ip=$(ifconfig $1 | grep -oP 'inet \d+\.\d+\.\d+\.\d+' | cut -d ' ' -f 2)
    port=$2
else
    usage
fi

# -b
if [ $method == 'http' ]; then
    if [ ! $port ]; then
        port=8000
    fi
    echo "Serving HTTP in $directory..."
    if [ $port -lt 1024 ]; then
        sudo python3 -m http.server -d $directory -b $ip $port
    else
        python3 -m http.server -d $directory -b $ip $port
    fi

# -i
elif [ $method == 'ftp' ]; then
    echo "Serving FTP in $directory..."
    if [ ! $port ]; then
        port=21
    fi
    if [ $port -lt 1024 ]; then
        sudo python3 -m pyftpdlib -d $directory -i $ip -p $port -w
    else
        python3 -m pyftpdlib -d $directory -i $ip -p $port -w
    fi

# -ip
elif [ $method == 'smb' ]; then
    echo "Serving SMB in $directory..."
    if [ ! $port ]; then
        port=445
    fi
    echo -en $pass_reminder
    if [ $port -lt 1024 ]; then
        sudo impacket-smbserver root $directory -ip $ip -port $port -smb2support $pass 2>/dev/null
    else
        impacket-smbserver root $directory -ip $ip -port $port -smb2support $pass 2>/dev/null
    fi
else
    usage
fi
