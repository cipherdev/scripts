#!/bin/sh
# *****************************************
# Copyright  2015
# AMCC, Inc. All Rights Reserved
# Proprietary and Confidential
# *****************************************
#
# Author: HuyLe,email: hule@apm.com
#
###########################################

VERSION="3.0"	

function _device_ata()
{
	lsscsi | grep 'ATA' > /tmp/ata.txt
        wc -l /tmp/ata.txt > /tmp/line.txt
        cut -c1-2 /tmp/line.txt > /tmp/numline.txt
        x=`cat /tmp/numline.txt`
        echo -e '\e[40;32m'"\033[1m ============================== \033[0m"
        echo -e '\e[40;32m'"\033[1m ==> Total device: ${x} HDD   <== \033[0m"
        echo -e '\e[40;32m'"\033[1m ============================== \033[0m"
}
###############
# HDD TESTING #
###############
function _xdd_ata()
{
	#for ((i=0; i<=$x; ++i))
	_device_ata
	for i in `seq 1 $x`
	do
		echo -e '\e[40;32m'"\033[1m ==> Device: ${i} \033[0m"
	        #sed -n "${i}p" /tmp/ata.txt > /tmp/${i}.txt
		head -"${i}" /tmp/ata.txt > /tmp/${i}.txt
	        y=`cat /tmp/$i.txt`
		echo "${y:${#y}-4:3}" > /tmp/result_$i.txt
	        echo -e '\e[40;32m'"\033[1m ==> `cat /tmp/result_${i}.txt` \033[0m"
		z=`cat /tmp/result_${i}.txt`
		for DEVICE in $z
		do 
			echo -e '\e[40;32m'"\033[1m ==> XDD write to the ${DEVICE}. \033[0m"
			xdd -op write -target /dev/${DEVICE} -reqsize 2048 -mbytes 4096 -dio -verbose -passes 3
			echo -e '\e[40;32m'"\033[1m ==> XDD read to the ${DEVICE}. \033[0m"
			xdd -op read -target /dev/${DEVICE} -reqsize 2048 -mbytes 4096 -dio -verbose -passes 3
			sleep 2m
		done
	done
	echo -e '\e[40;32m'"\033[1m ==> XDD for ${x} device done.\033[0m"
}
function _mount_ata_ext4(){
	_device_ata
	for i in `seq 1 $x`
        do
                echo -e '\e[40;32m'"\033[1m ==> Device: ${i} \033[0m"
                #sed -n "${i}p" /tmp/ata.txt > /tmp/${i}.txt
                head -"${i}" /tmp/ata.txt > /tmp/${i}.txt
                y=`cat /tmp/$i.txt`
                echo "${y:${#y}-4:3}" > /tmp/result_$i.txt
                echo -e '\e[40;32m'"\033[1m ==> `cat /tmp/result_${i}.txt` \033[0m"
                z=`cat /tmp/result_${i}.txt`
                for DEVICE in $z
                do
                        echo -e '\e[40;32m'"\033[1m ==> Format EXT4 and mount to ${DEVICE}. \033[0m"
			parted -s "/dev/${DEVICE}" -- mklabel gpt mkpart primary ext4 1049K 100% && mkfs.ext4 "/dev/${DEVICE}1"
			mkdir /tmp/${DEVICE}1
			mount /dev/${DEVICE}1 /tmp/${DEVICE}1
			touch /tmp/${DEVICE}1/${DEVICE}1.txt && echo "${DEVICE}1" > /tmp/${DEVICE}1/${DEVICE}1.txt
                done
        done
	df -h
}
function _mount_ata_vfat(){
	_device_ata
	for i in `seq 1 $x`
        do
                echo -e '\e[40;32m'"\033[1m ==> Device: ${i} \033[0m"
                #sed -n "${i}p" /tmp/ata.txt > /tmp/${i}.txt
                head -"${i}" /tmp/ata.txt > /tmp/${i}.txt
                y=`cat /tmp/$i.txt`
                echo "${y:${#y}-4:3}" > /tmp/result_$i.txt
                echo -e '\e[40;32m'"\033[1m ==> `cat /tmp/result_${i}.txt` \033[0m"
                z=`cat /tmp/result_${i}.txt`
                for DEVICE in $z
                do
                        echo -e '\e[40;32m'"\033[1m ==> Format VFAT and mount to ${DEVICE}. \033[0m"
                        mkfs.vfat /dev/${DEVICE}
			echo -e "o\nn\np\n1\n\n\nw" | fdisk /dev/${DEVICE}	#Create partion format vfat
			mkfs.vfat /dev/${DEVICE}1
			echo -e '\e[40;32m'"\033[1m ==> Mount to ${DEVICE}. \033[0m"
			mkdir /tmp/${DEVICE}1
                        mount /dev/${DEVICE}1 /tmp/${DEVICE}1
			touch /tmp/${DEVICE}1/${DEVICE}1.txt && echo "${DEVICE}1" > /tmp/${DEVICE}1/${DEVICE}1.txt
                done
        done
	df -h
}
function _umount_ata(){
        _device_ata
        for i in `seq 1 $x`
        do
                echo -e '\e[40;32m'"\033[1m ==> Device: ${i} \033[0m"
                #sed -n "${i}p" /tmp/ata.txt > /tmp/${i}.txt
                head -"${i}" /tmp/ata.txt > /tmp/${i}.txt
                y=`cat /tmp/$i.txt`
                echo "${y:${#y}-4:3}" > /tmp/result_$i.txt
                echo -e '\e[40;32m'"\033[1m ==> `cat /tmp/result_${i}.txt` \033[0m"
                z=`cat /tmp/result_${i}.txt`
                for DEVICE in $z
                do
                        echo -e '\e[40;32m'"\033[1m ==> Umount to ${DEVICE}. \033[0m"
                        umount /dev/${DEVICE}1
                done
        done
        df -h
}
function _device_usb()
{
	ls -l /sys/block/ | grep "usb" > /tmp/usb.txt
	wc -l /tmp/usb.txt > /tmp/numusb.txt
	cut -c1 /tmp/numusb.txt > /tmp/numline.txt
        x=`cat /tmp/numline.txt`
	echo -e '\e[40;32m'"\033[1m ============================== \033[0m"
        echo -e '\e[40;32m'"\033[1m ==> Total device USB: ${x} HDD   <== \033[0m"
        echo -e '\e[40;32m'"\033[1m ============================== \033[0m"
}

###############
# USB TESTING #
###############
function _mount_usb(){
        _device_usb
        for i in `seq 1 $x`
        do
                echo -e '\e[40;32m'"\033[1m ==> Device: ${i} \033[0m"
                sed -n "${i}p" /tmp/usb.txt > /tmp/${i}.txt
                # head -"${i}" /tmp/usb.txt > /tmp/${i}.txt 
                y=`cat /tmp/$i.txt`
                echo "${y:${#y}-3:3}" > /tmp/result_$i.txt
                echo -e '\e[40;32m'"\033[1m ==> `cat /tmp/result_${i}.txt` \033[0m"
                z=`cat /tmp/result_${i}.txt`
                for DEVICE in $z
                do
                        echo -e '\e[40;32m'"\033[1m ==> Format VFAT for ${DEVICE}. \033[0m"
                        mkfs.vfat /dev/${DEVICE}
			echo -e "o\nn\np\n1\n\n\nw" | fdisk /dev/${DEVICE}	#Create partion format vfat
			# Create the first partion as FAT32 LBA, bootable, with something like 64 Megabytes
			# echo -e "o\nn\np\n1\n\n+64M\na\n1\nt\nc\nw\n" | sudo fdisk /dev/MYDISK ; sudo fdisk /dev/MYDISK -l
			mkfs.vfat /dev/${DEVICE}1
			echo -e '\e[40;32m'"\033[1m ==> Mount to ${DEVICE}. \033[0m"
			mkdir /tmp/${DEVICE}1
                        mount /dev/${DEVICE}1 /tmp/${DEVICE}1
			touch /tmp/${DEVICE}1/${DEVICE}1.txt && echo "${DEVICE}1" > /tmp/${DEVICE}1/${DEVICE}1.txt
                done
        done
        df -h
}

function _umount_usb(){
        _device_usb
        for i in `seq 1 $x`
        do
                echo -e '\e[40;32m'"\033[1m ==> Device: ${i} \033[0m"
                sed -n "${i}p" /tmp/usb.txt > /tmp/${i}.txt
                # head -"${i}" /tmp/usb.txt > /tmp/${i}.txt 
                y=`cat /tmp/$i.txt`
                echo "${y:${#y}-3:3}" > /tmp/result_$i.txt
                echo -e '\e[40;32m'"\033[1m ==> `cat /tmp/result_${i}.txt` \033[0m"
                z=`cat /tmp/result_${i}.txt`
                for DEVICE in $z
                do
                        echo -e '\e[40;32m'"\033[1m ==> Umount to ${DEVICE}. \033[0m"
                        umount /dev/${DEVICE}1
                done
        done
        df -h
}
##################
# IOZONE TESTING #
##################
function _iozone_ata(){
    _device_ata
	for i in `seq 1 $x`
        do
                echo -e '\e[40;32m'"\033[1m ==> Device: ${i} \033[0m"
                #sed -n "${i}p" /tmp/ata.txt > /tmp/${i}.txt
                head -"${i}" /tmp/ata.txt > /tmp/${i}.txt
                y=`cat /tmp/$i.txt`
                echo "${y:${#y}-4:3}" > /tmp/result_$i.txt
                echo -e '\e[40;32m'"\033[1m ==> `cat /tmp/result_${i}.txt` \033[0m"
                z=`cat /tmp/result_${i}.txt`
                for DEVICE in $z
                do
                        echo -e '\e[40;32m'"\033[1m ==> IOZONE LINUX TO ${DEVICE}. \033[0m"
			iozone -I -i 0 -i 1 -i 2 -r 64K -s 1G -t 1 -F /dev/${DEVICE}
                done
        done
}
###############
# FIO TESTING #
###############
function _fio_ata(){
	echo -e '\e[40;32m'"\033[1m ==> Don't support testing FIO. \033[0m"
	#device_ata
	#mdadm --create --assume-clean --run /dev/md5 --chunk=64 --level=5 --raid-devices=4 /dev/sda /dev/sdb /dev/sdc /dev/sdd
	#mdadm --create --verbose /dev/md0 --level=$2 --raid-devices=$3 /dev/sda1 /dev/sdb1 /dev/sdc1 /dev/sdd1 /dev/sde1
	#mdadm --misc -D /dev/md0 
}
#####################
# DATE-TIME TESTING #
#####################
function _date_t(){
	#Set the Hardware Clock to the current System Time.
	hwclock --systohc  # or hwclock -w
	#Set the System Time from the Hardware Clock.
	hwclock --hctosys # or hwclock -s
	echo -e '\e[40;32m'"\033[1m#========================================================================================#\033[0m"
	echo -e '\e[40;32m'"\033[1mSystem Time: \033[0m"
	date
	echo -e '\e[40;32m'"\033[1mHardware Clock: \033[0m"
	hwclock -r
	
	echo -e '\e[40;32m'"\033[1m#========================================================================================#\033[0m"
	echo -e '\e[40;32m'"\033[1mSet the time to System Time: 2050-06-25 12:00:56 \033[0m"
	date -s '2050-06-25 12:00:56'
	#echo -e '\e[40;32m'"\033[1mSystem Time: \033[0m"
	#date
	echo -e '\e[40;32m'"\033[1mHardware Clock: \033[0m"
	hwclock -r
	
	echo -e '\e[40;32m'"\033[1m#========================================================================================#\033[0m"
	echo -e '\e[40;32m'"\033[1mSet the Hardware Clock to the current System Time\033[0m"
	hwclock --systohc
	sleep 3
	echo -e '\e[40;32m'"\033[1mSystem Time: \033[0m"
	date
	echo -e '\e[40;32m'"\033[1mHardware Clock: \033[0m"
	hwclock -r
	
	echo -e '\e[40;32m'"\033[1m#========================================================================================#\033[0m"
	echo -e '\e[40;32m'"\033[1mSet the System Time from the Hardware Clock.\033[0m"
	hwclock --set --date="2013-7-31 09:30"
	sleep 1
	hwclock --hctosys
	sleep 2
	echo -e '\e[40;32m'"\033[1mHardware Clock: \033[0m"
	hwclock -r
	echo -e '\e[40;32m'"\033[1mSystem Time: \033[0m"
	date

  	echo -e '\e[40;32m'"\033[1m#========================================================================================#\033[0m"
	echo -e '\e[40;32m'"\033[1mStop NTP \033[0m"
	/etc/init.d/S49ntp stop
	echo -e '\e[40;32m'"\033[1mUpdate System Time: time.nist.gov  \033[0m"
	ntpdate time.nist.gov
	date
	echo -e '\e[40;32m'"\033[1mUpdate Hardware Clock Time  \033[0m"
	hwclock -w
	sleep 3
	hwclock -r
	echo -e '\e[40;32m'"\033[1m#========================================================================================#\033[0m"

}
function _inf(){
	echo -e '\e[40;32m'"\033[1m \t Information\033[0m"
	echo -e "\n"
	cat /proc/version
	lscpu
	# lscpu | grep "CPU(s):" | cut -d':' -f2 > cores.txt
	free -t -m 
	vmstat -s
}
function _help(){
	echo -e '\e[40;32m'"\033[5m#======================================#\033[0m"
	echo -e '\e[40;32m'"\033[5m#---------------OPTIONS----------------#\033[0m"
	echo -e '\e[40;32m'"\033[5m#--------------------------------------#\033[0m"
	echo -e '\e[40;32m'"\033[1m#    1)      MOUNT HDD-EXT4	       #\033[0m"
	echo -e '\e[40;32m'"\033[1m#    2)      MOUNT HDD-VFAT	       #\033[0m"
	echo -e '\e[40;32m'"\033[1m#    3)      UMOUNT HDD		       #\033[0m"
	echo -e '\e[40;32m'"\033[1m#    4)      MOUNT USB-VFAT	       #\033[0m"
	echo -e '\e[40;32m'"\033[1m#    5)      UMOUNT USB	               #\033[0m"
	echo -e '\e[40;32m'"\033[1m#    6)      XDD-HDD	               #\033[0m"
	echo -e '\e[40;32m'"\033[1m#    7)      IOZONE-HDD	               #\033[0m"
	echo -e '\e[40;32m'"\033[1m#    8)      FIO-HDD		       #\033[0m"
	echo -e '\e[40;32m'"\033[1m#    9)      DATE		       #\033[0m"
	echo -e '\e[40;32m'"\033[1m#    10)     INFO-CPU	               #\033[0m"
	echo -e '\e[40;32m'"\033[1m#    11)     Exit		       #\033[0m"
	echo -e '\e[40;32m'"\033[5m#--------------------------------------#\033[0m"
	echo -e '\e[40;32m'"\033[5m#======================================#\033[0m"
}
# function progress {
#         let progress=(${1}*100/${2}*100)/100
#         let done=(${progress}*4)/10
#         let left=40-${done}
#         fill=$(printf "%${done}s")
#         empty=$(printf "%${left}s")
#         printf "\rProgress : [${fill// /#}${empty// /-}]# ${progress}%%"
# }
# function runprogress(){
# 	_start=1
# 	_end=100
# 	for number in $(seq ${_start} ${_end})
# 	do
# 	    sleep 0.1
# 	    progress ${number} ${_end}
# 	done
# 	printf '\nFinished!\n'
# }

function _exit(){
    echo -ne '#####                     (33%)\r'
    sleep 1
    echo -ne '##########################(100%)\r\n'
    echo -ne "Exit done. \n"		
    echo -ne '\n'
}

function _usage()
{
cat << EOF

	Usage:  ./amcc-ver2.sh [options]

        Options:
                [-v | --version]			Script version to use
                [-mhe | --mhddetx4]			Mount SATA format EXT4
                [-mhv | --mhddvfat]			Mount SATA format VFAT
                [-uh | --uhdd]				Unmount SATA
		[-muv | --musbvfat]			Mount USB format VFAT
		[-uu | --uusb]				Unmount USB
		[-xdd | --xdd]				XDD SATA
		[-ioz | --iozone]			IOZONE SATA
		[-fio | --fio]				FIO SATA
		[-date | --date]			Date system 
		[-inf | --info]				Info CPU/Memory

	Note:
		Please contact hule@apm.com if have issue.

EOF
}


###############
# MAIN SCRIPT #
###############
main() 
{

while [ ! -z "$1" ]
do	
	case "$1" in
                -h | --help)
			_usage
			exit 0
			;;
		-mhe | --mhddetx4)
			_mount_ata_ext4
			exit 0
			;;
		-mhv | --mhddvfat)
			_mount_ata_vfat
			exit 0
			;;
		-uh | --uhdd)
			_umount_ata
			exit 0
			;;
		-muv | --musbvfat)
			_mount_usb
			exit 0
			;;
		-uu | --uusb)
			_umount_usb
			exit 0
			;;
		-xdd | --xdd)
			_xdd_ata
			exit 0
			;;
		-ioz | --iozone)
			_iozone_ata
			exit 0
			;;
		-fio | --fio)
			_fio_ata
			exit 0
			;;
		-date | --date)
			_date_t
			exit 0
			;;
		-inf | --info)
			_inf
			exit 0
			;;
                -v | --version)
			echo "Version: $VERSION"
			exit 0
			;;
                *)
                _usage
                exit 0
                ;;
        esac
done
	_help
	echo -ne '\e[40;32m'"\033[5m=> SelectOption: \033[0m"
	read case

	case $case in
	    1)
		_mount_ata_ext4
		;;
	    2)
		_mount_ata_vfat
		;; 
	    3)
		_umount_ata
		;;
	    4)
		_mount_usb
		;;
	    5)
		_umount_usb
		;;
	    6)
		_xdd_ata
		;;
	    7)
		_iozone_ata
		;;
	    8)
		_fio_ata
		;;
	    9)
		_date_t
		;;
	    10)
		_inf
		;;
	    11) 
		echo -ne "\n"
		_exit
		;;
	    *)
		echo -e '\e[40;32m'"\033[1m=> Not selected exit now!!! \n\033[0m"
	esac

}
main $*
