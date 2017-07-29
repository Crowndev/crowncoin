#Stop crownd (in case it's running)
crown-cli stop
#Create swap to help with sync
sudo mkdir -p /var/cache/swap/   
sudo dd if=/dev/zero of=/var/cache/swap/myswap bs=1M count=1024
sudo mkswap /var/cache/swap/myswap
sudo swapon /var/cache/swap/myswap
echo "/var/cache/swap/myswap    none    swap    sw    0   0" | sudo tee --append /etc/fstab > /dev/null
sudo cat /etc/fstab
#Update Repos
sudo DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" update
sudo DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade
#Install Firewall
sudo apt-get install ufw jq
#Fetch the URL of the latest Release
RELEASE=$(curl -s 'https://api.github.com/repos/Crowndev/crowncoin/releases/latest' | jq -r '.assets | .[] | select(.name=="crown-x86_64-unknown-linux-gnu.tar.gz") | .browser_download_url')
#Download and extract latest Release
curl -sSL $RELEASE -o crown.tgz
tar xzf crown.tgz --no-anchored crownd crown-cli --transform='s/.*\///'
sudo mv crownd crown-cli /usr/local/bin/
rm -rf crown*
#Create folder structures and configure crown.conf
#echo "" | sudo tee .crown/crown.conf >> /dev/null
#cat .crown/crown.conf
sudo mv .crown/crown.conf .crown/crown.bak
crownd
IP=$(curl http://checkip.amazonaws.com/)
PW=$(date +%s | sha256sum | base64 | head -c 32 ;)
echo "daemon=1" | sudo tee --append .crown/crown.conf > /dev/null
echo "rpcallowip=127.0.0.1" | sudo tee --append .crown/crown.conf > /dev/null
echo "rpcuser=crowncoinrpc" | sudo tee --append .crown/crown.conf > /dev/null
echo "rpcpassword="$PW | sudo tee --append .crown/crown.conf > /dev/null
echo "listen=1" | sudo tee --append .crown/crown.conf > /dev/null
echo "server=1" | sudo tee --append .crown/crown.conf > /dev/null
echo "externalip="$IP | sudo tee --append .crown/crown.conf > /dev/null
echo "throne=1" | sudo tee --append .crown/crown.conf > /dev/null
echo "throneprivkey="$1 | sudo tee --append .crown/crown.conf > /dev/null
cat .crown/crown.conf
#Configure firewall
sudo ufw allow ssh/tcp
sudo ufw limit ssh/tcp
sudo ufw allow 9340/tcp
sudo ufw logging on
sudo ufw --force enable
#Add cron job to restart crownd on reboot
#echo new cron into cron file
(crontab -l 2>/dev/null; echo "@reboot sudo /usr/local/bin/crownd") | crontab -
#Start Crownd to begin sync
crownd