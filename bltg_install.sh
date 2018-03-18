#!/bin/bash

NONE='\033[00m'
CYAN='\033[01;36m'
RED='\033[01;31m'
GREEN='\033[01;32m'

echo "[1/${MAX}] Checking Ubuntu version..."
if [[ `cat /etc/issue.net`  == *16.04* ]]; then
    echo -e "${GREEN}* You are running `cat /etc/issue.net` . Setup will continue.${NONE}";
else
    echo -e "${RED}* You are not running Ubuntu 16.04.X. You are running `cat /etc/issue.net` ${NONE}";
    echo && echo "Installation cancelled" && echo;
    exit;
fi


cd ~
wget "https://docs.google.com/uc?id=0B3X9GlR6EmbnQ0FtZmJJUXEyRTA&export=download"
mv "uc?id=0B3X9GlR6EmbnQ0FtZmJJUXEyRTA&export=download" gdrive
chmod +x gdrive
sudo install gdrive /usr/local/bin/gdrive
gdrive list

IP_ADD=`curl ipinfo.io/ip`
COIN="Bitcoin_Lightning"
DAEMON="Bitcoin_Lightningd"
RPCPORT="17126"
MNPORT="17127"
THEDATE=`date +"%Y%m%d-%H%M"`
BACKUPWALLET="wallet-${COIN}-${IP_ADD}-${THEDATE}.txt"

#sudo touch /var/swap.img
#sudo chmod 600 /var/swap.img
#sudo dd if=/dev/zero of=/var/swap.img bs=1024k count=2000
#mkswap /var/swap.img
#sudo swapon /var/swap.img
#sudo echo "/var/swap.img none swap sw 0 0" >> /etc/fstab

sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get dist-upgrade -y
sudo apt-get install -y build-essential libtool autotools-dev pkg-config libssl-dev libboost-all-dev autoconf automake -y
sudo apt-get install libzmq3-dev libminiupnpc-dev libssl-dev libevent-dev -y

#sudo git clone https://github.com/bitcoin-core/secp256k1
#cd ~/secp256k1
#./autogen.sh
#./configure
#make
#./tests
#make install

sudo apt-get install libgmp-dev -y
sudo apt-get install openssl -y
sudo apt-get install software-properties-common && add-apt-repository ppa:bitcoin/bitcoin -y
sudo apt-get update
sudo apt-get install libdb4.8-dev libdb4.8++-dev -y

#cd ~
#git clone https://github.com/Bitcoinlightning/Bitcoin-Lightning.git
#cd ~/Bitcoin-Lightning/src
#make -f makefile.unix
#strip ${DAEMON}
#cp ${DAEMON} /usr/bin/
#cd ~

wget https://github.com/Bitcoinlightning/Bitcoin-Lightning/releases/download/v1.1.0.0/Bitcoin_Lightning-Daemon-1.1.0.0.tar.gz
tar xvzf Bitcoin_Lightning-Daemon-1.1.0.0.tar.gz
rm Bitcoin_Lightning-Daemon-1.1.0.0.tar.gz
chmod 755 ${DAEMON}
strip ${DAEMON}
sudo mv ${DAEMON} /usr/bin
cd

${DAEMON}

GEN_USER=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1`
GEN_PASS=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1`

cat > /root/.${COIN}/${COIN}.conf <<EOF
rpcuser=${GEN_USER}
rpcpassword=${GEN_PASS}
server=1
listen=1
daemon=1
staking=1
discover=1
rpcthreads=8
maxconnections=256
#port=${RPCPORT}
rpcallowip=127.0.0.1
addnode=92.186.144.255
EOF

cd ~
sleep 2
${DAEMON}
sleep 3

PRIVKEY=`${DAEMON} masternode genkey`
ADDRESS=`${DAEMON} getnewaddress MN1`
${DAEMON} stop
sleep 2

echo -e "masternode1 ${IP_ADD}:${MNPORT} ${PRIVKEY} " >> /root/.${COIN}/masternode.conf

echo -e "masternode=1" >> /root/.${COIN}/${COIN}.conf
echo -e "masternodeprivkey=${PRIVKEY}" >> /root/.${COIN}/${COIN}.conf
echo -e "masternodeaddr=${IP_ADD}:${MNPORT}" >> /root/.${COIN}/${COIN}.conf

echo " "
echo -e "${CYAN} Auto backup wallet.dat to Your google drive ${NONE}"
echo " "
cd .${COIN}

cp wallet.dat wallet.dat-${COIN}-${IP_ADD}-${THEDATE}
gdrive upload wallet.dat-${COIN}-${IP_ADD}-${THEDATE}

echo -e "Your Masternode Privkey : ${PRIVKEY}" >> /root/.${COIN}/${BACKUPWALLET}
echo -e "Wallet Address : ${ADDRESS}" >> /root/.${COIN}/${BACKUPWALLET}

gdrive upload ${BACKUPWALLET}
echo " "
echo -e "################################################################################"
echo " "
echo -e "Backup wallet.dat finish ${CYAN}(${BACKUPWALLET}) ${NONE}"
echo " "
echo -e "Your Masternode Privkey :${CYAN} ${PRIVKEY} ${NONE}"
echo -e "Transfer 3000 BLTG to address :${CYAN} ${ADDRESS} ${NONE}"
echo " "
echo -e "After send 3000 BLTG, type ${CYAN}${DAEMON} masternode outputs ${NONE} in VPS"
echo -e "If no value,type ${CYAN}masternode outputs ${NONE} in PC Wallet console"
echo -e "edit file ${CYAN}masternode.conf ,${CYAN} nano /root/.${COIN}/masternode.conf ${NONE} and put:"
echo " "
echo -e " ${CYAN} masternode1 ${IP_ADD}:${MNPORT} ${PRIVKEY} <TXID> <NO> ${NONE} "
echo " "
echo "################################################################################"

