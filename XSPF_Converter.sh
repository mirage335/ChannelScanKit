#!/bin/bash
#Converts channels.conf file into XSPF playlist for VLC.
#$1 = inFile
#$2 = outFile

# Copyright (c) 2012 mirage335

# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


inFile="$1"
outFile="$2"

#Header.
echo '<?xml version="1.0" encoding="UTF-8"?>
<playlist xmlns="http://xspf.org/ns/0/" xmlns:vlc="http://www.videolan.org/vlc/playlist/ns/0/" version="1">
	<title>Playlist</title>
	<trackList>' > "$outFile"

currentLine=1
id=0

while [ "$currentLine" -le "$(wc -l "$inFile" | cut -f1 -d\  )" ]
do
	channel=$(head -n $currentLine "$inFile" | tail -n 1 | cut -d\: -f1)
	frequency=$(head -n $currentLine "$inFile" | tail -n 1 | cut -d\: -f2)
	modulation=$(head -n $currentLine "$inFile" | tail -n 1 | cut -d\: -f3)
	program=$(head -n $currentLine "$inFile" | tail -n 1 | cut -d\: -f6)
	
	#echo "$channel,$frequency,$modulation,$program"
	
	echo "	<track>
			<location>dvb://frequency=$frequency</location>
			<title>$channel</title>
			<extension application=\"http://www.videolan.org/vlc/playlist/0\">
				<vlc:id>$id</vlc:id>
				<vlc:option>dvb-adapter=0</vlc:option>
				<vlc:option>dvb-srate=0</vlc:option>
				<vlc:option>dvb-modulation=$modulation</vlc:option>
				<vlc:option>program=$program</vlc:option>
			</extension>
	</track>" >> "$outFile"
	
	
	((currentLine++))
	((id++))
done

#Footer.
echo '	</trackList>
	<extension application="http://www.videolan.org/vlc/playlist/0">
			<vlc:item tid="0"/>
	</extension>
</playlist>' >> "$outFile"