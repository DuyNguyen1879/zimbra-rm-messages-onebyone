
#!/bin/bash

clear
# Reset
Color_Off='\033[0m'       # Text Reset

# Regular Colors
Black='\033[0;30m'        # Black
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Blue='\033[0;34m'         # Blue
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan
White='\033[0;37m'        # White

# Bold
BBlack='\033[1;30m'       # Black
BRed='\033[1;31m'         # Red
BGreen='\033[1;32m'       # Green
BYellow='\033[1;33m'      # Yellow
BBlue='\033[1;34m'        # Blue
BPurple='\033[1;35m'      # Purple
BCyan='\033[1;36m'        # Cyan
BWhite='\033[1;37m'       # White

# /* Variable for bold */
ibold="\033[1m""\n===> "
ebold="\033[0m"


echo -e $Red"########################################################################"$Color_Off
echo -e $Red"# Name          : rm-messages-onebyone-zcs.sh"$Color_Off
echo -e $Red"# Version       : 0.1"$Color_Off
echo -e $Red"# Date          : 2019-01-05"$Color_Off
echo -e $Red"# Author        : ZIMBRA FORUMS"$Color_Off
echo -e $Red"# Modifycation  : Vu Van Than - Linux System Engeneer Updated 05-01-2019"$Color_Off
echo -e $Red"# Modifier      : SStrutt"$Color_Off
echo -e $Red"# Compatibility : Centos7 LTS, Zimbra 8.7.x"$Color_Off
echo -e $Red"# Purpose       : DELETING ALL EMAILS OLDER THAN X DAYS."$Color_Off
echo -e $Red"# Exit Codes    : (if multiple errors, value is the addition of codes)"$Color_Off
echo -e $Red"#   0 = success"$Color_Off
echo -e $Red"#   1 = failure"$Color_Off
echo -e $Red"########################################################################"$Color_Off

################ CHANGE LOG ############################################
# DATE       WHO WHAT WAS CHANGED
# ---------- --- ----------------------------
# 2019-01-05 Vu Van Than Updated script.
# 2019-01-05 Updated script to run on Centos 7 LTS, Zimbra 8.7.x
# 2019-01-05 Updated script Deleting messages from account using the CLI to run on Centos 7 LTS, Zimbra
#####################################################################
# TO DO !!
# DELETING ALL EMAILS OLDER THAN X DAYS
# You only can delete like maximum 1000 emails at the same time, the script will ask if you want to execute more times if you have more than 1000 emails
# You need to put the date like mm/dd/yy
# If you want to use Inbox, type inbox (lower case)
# This script will ask for each account, is not very batch, but works one by one
## ~~~~~!!!! SCRIPT RUNTIME !!!!!~~~~~ ##
# Best you don't change anything from here on, 
# ONLY EDIT IF YOU KNOW WHAT YOU ARE DOING

ROOT_UID=0     # Only users with $UID 0 have root privileges.
E_NOTROOT=87   # Non-root exit error.

if [ "$UID" -ne "$ROOT_UID" ]
then
   echo "Must be root to run this script."
exit $E_NOTROOT
fi

ZIMBRA_BIN=/opt/zimbra/bin
echo "Enter the username.:"
read THEACCOUNT

echo "Enter the time that you would like to delete messages up to, in mm/dd/yy format. Example 04/10/09:"
read THEDATE

echo "What folder would you like to delete these messages from?: Example Inbox"
read THEFOLDER

echo "You will now be deleting Messages from the $THEFOLDER folder up to $THEDATE for $THEACCOUNT."
echo "Do you want to continue? (y/N): "
read ADD

themagic ()
{
touch /tmp/deleteOldMessagesList.txt
for i in `$ZIMBRA_BIN/zmmailbox -z -m $THEACCOUNT search -l 1000 "in:/$THEFOLDER date:$THEDATE" | grep conv | sed -e "s/^\s\s*//" | sed -e "s/\s\s*/ /g" | cut -d" " -f2`
do
if [[ $i =~ [-]{1} ]]
then
MESSAGEID=${i#-}
echo "deleteMessage $MESSAGEID" >> /tmp/deleteOldMessagesList.txt
else
echo "deleteConversation $i" >> /tmp/deleteOldMessagesList.txt
fi
done

$ZIMBRA_BIN/zmmailbox -z -m $THEACCOUNT < /tmp/deleteOldMessagesList.txt >> /tmp/process.log
rm -f /tmp/deleteOldMessagesList.txt
echo "Completed. Run again for same user?"
read ADD
}


while expr "$ADD" : ' *[Yy].*'
do themagic
done
