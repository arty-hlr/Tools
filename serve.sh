#!/bin/bash

function usage {
    echo "Usage: serve -h|f|s <windows|linux|pwd|other> [port] [-N | --no-pass]"
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

# root=$2
if [ $root == 'pwd' ] || [ $root == '.' ]; then
    directory=$(pwd)
elif [ $root == 'windows' ]; then
    directory='/home/kali/Documents/Tools/Windows/www-root'
elif [ $root == 'linux' ]; then
    directory='/home/kali/Documents/Tools/Linux/www-root'
else
    directory=$root
fi

# method=$1
# if [ $# -eq 3 ] && [ $3 != '--no-pass' ]; then
#     port=$3
# else
#     port=''
# fi

# if [ $# -eq 4 ] && [ $4 == '--no-pass' ]; then
#     pass=''
#     pass_reminder=''
# elif  [ $# -eq 3 ] && [ $3 == '--no-pass' ]; then
#     pass=''
#     pass_reminder=''
# else
# fi

ls $directory
echo ''
if [ $# -lt 1 ]; then
    port=''
else
    port=$1
fi

if [ $method == 'http' ]; then
    if [ ! $port ]; then
        port=8000
    fi
    echo "Serving HTTP in $directory..."
    if [ $port -lt 1024 ]; then
        sudo python3 -m http.server -d $directory $port
    else
        python3 -m http.server -d $directory $port
    fi

elif [ $method == 'ftp' ]; then
    echo "Serving FTP in $directory..."
    if [ ! $port ]; then
        port=21
    fi
    if [ $port -lt 1024 ]; then
        sudo python3 -m pyftpdlib -d $directory -p $port -w
    else
        python3 -m pyftpdlib -d $directory -p $port -w
    fi

elif [ $method == 'smb' ]; then
    echo "Serving SMB in $directory..."
    if [ ! $port ]; then
        port=445
    fi
    echo -en $pass_reminder
    sudo impacket-smbserver root $directory -port $port -smb2support $pass 2>/dev/null
else
    usage
fi
