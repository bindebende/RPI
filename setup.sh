#!/bin/sh

file_change_line_or_add()
{
$file_name = $1
$line_substing = $2
$new_line = $3

echo "file_name: $file_name; line_substing: $line_substing; new_line:$new_line"



# If a line containing $line_substring
if grep -Fq $line_substring $file_name
then
        # Replace the line
        sed -i $new_line $file_name
else
        # Create the new line if not existed before
        echo $new_line >> $file_name
fi
}




# stop if error was raised https://stackoverflow.com/a/2871034/4109273
set -eux

echo "start"


# source: https://core-electronics.com.au/tutorials/create-an-installer-script-for-raspberry-pi.html


#################################### Install packages ####################################

PACKAGES="python-pip htop tcptrack ncdu speedtest-cli trash-cli"
apt-get update
apt-get upgrade -y
apt-get install $PACKAGES -y


#################################### Enable SSH ####################################
sudo systemctl enable ssh
sudo systemctl start ssh



#################################### Change Config Files ####################################
$boot_file_path = "boot.txt"


file_change_line_or_add $boot_file_path "gpu_mem" "/gpu_mem/c\gpu_mem=128"



echo "Install complete, rebooting."
#reboot


