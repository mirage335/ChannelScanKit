#!/bin/bash
#Uses the w_scan utility to produce a list of valid channels.
#Script will take a long time, produce lots of odd error messages and whatnot, but does carry out an exhaustive search for valid channels with conservative settings.

# Copyright (c) 2012 mirage335

# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


#Import useful functions.
. ubiquitous_bash.sh

#Create useful functions.
timeout() { perl -e 'alarm shift; exec @ARGV' "$@"; } #From http://www.cyberciti.biz/faq/shell-scripting-run-command-under-alarmclock/

#Generate starting configuration file.
echo -n -e "\E[42;37m\033[1mGetting initial channel list." ; tput sgr0 ; echo

#SCAN Channels.
w_scan -o 7 -x -fa -A1 -c US -X > /tmp/AllChannelsList

sed -i s/VSB_8/8VSB/g /tmp/AllChannelsList #the VSB_8 notation is not compatible with at least vlc

#Only permit whitelisted characters that mplayer and other things understand.
echo -n -e "\E[42;37m\033[1mRemoving unusable characters." ; tput sgr0 ; echo
tr -cd '_ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890:\n' < /tmp/AllChannelsList > /tmp/ChannelsWithoutBadChars

#Remove entries with duplicate names.
echo -n -e "\E[42;37m\033[1mRemoving duplicate entries." ; tput sgr0 ; echo
sort /tmp/ChannelsWithoutBadChars | uniq > /tmp/UniqueChannelList

#Give the configuration to mplayer.
cp /tmp/UniqueChannelList "$HOME"/.mplayer/channels.conf

#Start with clean slate.
echo -n -e "\E[42;37m\033[1mInitializing new channels.conf file." ; tput sgr0 ; echo
echo -n "" > channels.conf

currentLine=1
#Get channel.
channelToTest=$(head -n $currentLine /tmp/UniqueChannelList | tail -n 1 | cut -d\: -f1)
while [ "$currentLine" -le "$(wc -l /tmp/UniqueChannelList | cut -f1 -d\  )" ]
do
	echo -n -e "\E[42;37m\033[1mTesting channel $channelToTest..." ; tput sgr0 ; echo

	#Test channel.
	timeout 15 mplayer -vo null -ao null -msglevel all=9 dvb://"$channelToTest" -dvbin file="$HOME"/.mplayer/channels.conf | grep ts_parse > /tmp/mplayerScan.out

	#Do something or nothing with that information.
	if [ "$(grep ts_parse /tmp/mplayerScan.out)" == "" ]
	then
		echo -n -e "\E[41;37m\033[1mWRONG: Useless channel detected, ignoring." ; tput sgr0 ; echo
	else
		echo -n -e "\E[44;37m\033[1mVALID: Found channel!" ; tput sgr0 ; echo
		echo $(head -n $currentLine /tmp/UniqueChannelList | tail -n 1)
		echo $(head -n $currentLine /tmp/UniqueChannelList | tail -n 1) >> channels.conf
	fi
	
	((currentLine++))
	#Get next channel.
	channelToTest=$(head -n $currentLine /tmp/UniqueChannelList | tail -n 1 | cut -d\: -f1)
done

#TODO: remove trailing newline


echo -n -e "\E[42;37m\033[1mAll finished." ; tput sgr0 ; echo
