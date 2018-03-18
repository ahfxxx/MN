#!/bin/bash
cd ~
wget "https://docs.google.com/uc?id=0B3X9GlR6EmbnQ0FtZmJJUXEyRTA&export=download"
mv "uc?id=0B3X9GlR6EmbnQ0FtZmJJUXEyRTA&export=download" gdrive
chmod +x gdrive
sudo install gdrive /usr/local/bin/gdrive
gdrive list

NONE='\033[00m'
CYAN='\033[01;36m'

COIN="Bitcoin_Lightning"
DAEMON="Bitcoin_Lightningd"
RPCPORT="17126"
MNPORT="17127"
THEDATE=`date +"%Y%m%d-%H%M"`
BACKUPWALLET="wallet.dat-${COIN}-${IP_ADD}-${THEDATE}.txt"

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

sudo apt-get install -y pwgen
GEN_USER=`pwgen -1 20 -n`
GEN_PASS=`pwgen -1 40 -n`
IP_ADD=`curl ipinfo.io/ip`

cat > /root/.${COIN}/${COIN}.conf <<EOF

rpcuser=${GEN_USER}
rpcpassword=${GEN_PASS}
server=1
listen=1
maxconnections=256
daemon=1
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

cp wallet.dat ${BACKUPWALLET}
gdrive upload ${BACKUPWALLET}

cat > /root/.${COIN}/${BACKUPWALLET} <<EOF
Your Masternode Privkey : ${PRIVKEY}
Wallet Address : ${ADDRESS}
EOF
gdrive upload ${BACKUPWALLET}

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
echo -e " ${CYAN} masternode1 ${IP_ADD}:${MNPORT} ${PRIVKEY} <TXID> <NO> ${NONE}
echo " "
echo "################################################################################"

