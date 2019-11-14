#!/bin/bash

function die(){
	exit 0;
}

function is_root(){

	if [ $(id -u) = 0 ]
	then
		return 0
	else
		return 1
	fi

}

##print with color
NC='\033[0m' # No Color
function echo_e(){
	case $1 in 
		red)	echo -e "\033[0;31m$2 ${NC} " ;;
		green) 	echo -e "\033[0;32m$2 ${NC} " ;;
		yellow) echo -e "\033[0;33m$2 ${NC} " ;;
		blue)	echo -e "\033[0;34m$2 ${NC} " ;;
		purple)	echo -e "\033[0;35m$2 ${NC} " ;;
		cyan) 	echo -e "\033[0;36m$2 ${NC} " ;;
		*) echo $1;;
	esac
}

function echo_en(){
	case $1 in 
		red)    echo -e -n "\033[0;31m$2 ${NC} " ;;
		green)  echo -e -n "\033[0;32m$2 ${NC} " ;;
		yellow) echo -e -n "\033[0;33m$2 ${NC} " ;;
		blue)   echo -e -n "\033[0;34m$2 ${NC} " ;;
		purple) echo -e -n "\033[0;35m$2 ${NC} " ;;
		cyan)   echo -e -n "\033[0;36m$2 ${NC} " ;;
		*) echo $1;;
	esac
}

function find_ip(){
	ping -c1 -w 1 $1 > /dev/null
	if [ $? -eq 0 ]
 	then
		if its_up $* 
		then
			echo_en green "[+]" $1
			echo -n $1
			echo 
		fi
  	else
	 	echo_en red "[-]" $1
    	echo -n $1 
        echo 
	fi
}


function its_up(){

	ping -c1 -w 1 $1 > /dev/null
	if [ $? -eq 0 ]
 	then
		 return 0
  	else
		return 1
	fi
}

function read_file(){
	total_lines=`wc -l $1 | cut -d" " -f1 ` 
	count=0
	while IFS= read -r line
	do
		count=`expr $count + 1`
  		if its_up $line 
		then
			echo_en green "[+]"
			echo -n "["
			echo -n $count
			echo -n " | "
			echo -n $total_lines
			echo -n "]"
			echo -n " "
			echo -n $line
			if [ "$2" == "--save-state-on" ]
			then
				echo $line >> $3
			fi 
			echo 
		else
			echo_en red "[-]"
			echo -n "["
			echo -n $count
			echo -n " | "
			echo -n $total_lines
			echo -n "]"
			echo -n " "
			echo -n $line
			if [ "$2" == "--save-state-off" ]
			then
				echo $line >> $3
			fi 
			echo
		fi
	done < $1

}

function install(){

	if [ -f "/usr/sbin/itsup" ]
	then 
		rm -r /usr/sbin/itsup
		cp ./itsup.sh /usr/sbin/itsup
	else
		cp ./itsup.sh /usr/sbin/itsup
	fi	
	echo_en green "[+]" 
	echo "itsup installed in /usr/sbin like itsup "
}

function helper(){

	#logo
echo '
isup [IP | list] [OPTIONS]
		  --save-state-on | --save-state-off 	[PATH] 
		  --install
	 '
}

function init_menu(){
	case $1 in
		"--help")
			helper 
			die	;;
		"--install")
			if is_root
			then
				install
			else
				echo_en red "[-]"
				echo "itsup need root" 
			fi
			die	;;
		*)
			if [ -z $1 ]
			then 
				helper
			else
				if [ -f $1 ]
				then 
					read_file $*
					die
				else
					find_ip $1
					die
				fi
			fi
			die;;
	esac


}

##MAIN

init_menu $*
