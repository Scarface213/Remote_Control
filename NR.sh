#~ #!/bin/bash
 

result=$(dpkg-query --list geoip-bin | grep geoip-bin | awk '{print $1}')

if [[ $result == 'ii' ]]
then
	echo '[+] geoip-bin is already installed'
else
	echo '[-] geoip-bin not found... Installing'
	sudo apt-get -y -q install geoip-bin > /dev/null
	echo '[+] geoip-bin installation DONE'
fi

result=$(dpkg-query --list sshpass | grep sshpass | awk '{print $1}')

if [[ $result == 'ii' ]]
then
	echo '[+] sshpass is already installed'
else
	echo '[-] sshpass not found... Installing'
	sudo apt-get -y -q install sshpass > /dev/null
	echo '[+] sshpass installation DONE'
fi

result=$(dpkg-query --list nmap | grep nmap | awk '{print $1}')

if [[ $result == 'ii' ]]
then
	echo '[+] nmap is already installed'
else
	echo '[-] nmap not found... Installing'
	sudo apt-get -y -q install nmap > /dev/null
	echo '[+] nmap installation DONE'
fi

result=$(dpkg-query --list whois | grep whois | awk '{print $1}')

if [[ $result == 'ii' ]]
then
	echo '[+] whois is already installed'
else
	echo '[-] whois not found... Installing'
	sudo apt-get -y -q install whois > /dev/null
	echo '[+] whois installation DONE'
fi


result=$(find . -name nipe.pl) > /dev/null
myip=$(curl -s ifconfig.io)
var=$(pwd)
if [[ $result != './nipe/nipe.pl' ]]
then
	git clone --quiet https://github.com/htrgouvea/nipe && cd nipe
	sudo cpan install Try::Tiny Config::Simple JSON
	sudo perl nipe.pl install
	sudo perl nipe.pl start 
	sleep 3
	spoofip=$(curl -s ifconfig.io)
	sleep 3
	spoofcountry=$(geoiplookup $spoofip| awk '{print $5,$6}')
	if [[ $myip != $spoofip ]]
	then
		echo '[*] You are anonymous.. Connecting to the remote Server'
		echo -e '\n'
		echo "[*] Your Spoofed IP address is: $spoofip , Spoofed country: $spoofcountry"
	else
		echo 'Your IP is not spoofed, please exit and restart'
	fi
else
	echo '[+] nipe.pl is already installed' && cd nipe
	sudo perl nipe.pl start && $var
	sleep 3
	spoofip=$(curl -s ifconfig.io)
	sleep 3
	spoofcountry=$(geoiplookup $spoofip| awk '{print $5,$6}')
	if [[ $myip != $spoofip ]]
	then
		echo '[*] You are anonymous.. Connecting to the remote Server'
		echo -e '\n'
		echo "[*] Your Spoofed IP address is: $spoofip , Spoofed country: $spoofcountry"
	else
		echo 'Your IP is not spoofed, please restart the script' && cd nipe
		sudo perl nipe.pl stop 
		sleep 3
		exit
	fi
fi



echo 'Specify a Domain/IP address to scan: '
read targetIP
echo -e '\n'

echo 'Please enter your Remote Server IP:'
read remoteip
echo 'Please enter your Remote Server Password:'
read -s remotepass
echo -e '\n'
echo 'Please enter your Remote Server User:'
read -s remoteuser
echo -e '\n'
echo '[*] Connecting to Remote Server'
export SSHPASS=$remotepass
value=$(sshpass -e ssh $remoteuser@$remoteip 'uptime')
remloc=$(geoiplookup $remoteip | awk '{print $5,$6}')
echo "Uptime:$value"
echo "IP address: $remoteip"
echo "Country: $remloc"
echo -e '\n'

current=$(date +"%a %b %d %r %Z %Y")
sudo touch /var/log/nr.log
sudo chmod 666 /var/log/nr.log


echo '[*] Whoising target address:'
sshpass -e ssh $remoteuser@$remoteip "whois -I '$targetIP' > whois_'$targetIP'.txt"
sshpass -e scp $remoteuser@$remoteip:/home/tc/whois_"$targetIP".txt "$var"
sudo updatedb
x=$(locate -w  whois_"$targetIP".txt)
y=/home/kali/Desktop/whois_"$targetIP".txt

if [[ $x == $y ]]
then
	echo "${current} [*] Whois data collected for: ${targetIP}" >> /var/log/nr.log
	echo "[@] Whois data was saved into ${var}/whois_'$targetIP'"
else
	echo "${current} [-] Whois data NOT collected for: ${targetIP}" >> /var/log/nr.log
	echo "[@] Whois data was NOT saved into ${var}/whois_'$targetIP'"
fi	
echo -e '\n'


echo '[*] Scanning target address:'
sshpass -e ssh $remoteuser@$remoteip "nmap -Pn '$targetIP' > nmap_'$targetIP'.txt"
sshpass -e scp $remoteuser@$remoteip:/home/tc/nmap_"$targetIP".txt "$var"
sudo updatedb
q=$(locate -w  nmap_"$targetIP".txt)
p=/home/kali/Desktop/nmap_"$targetIP".txt
if [[ $q == $p ]]
then
	echo "${current} [*] Nmap data collected for: ${targetIP}" >> /var/log/nr.log
	echo "[@] Nmap data was saved into ${var}/nmap_'$targetIP'"
else
	echo "${current} [-] Nmap data NOT collected for: ${targetIP}" >> /var/log/nr.log
	echo "[@] Nmap data was NOT saved into ${var}/nmap_'$targetIP'"
fi
sudo perl nipe.pl stop



