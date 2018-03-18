#!/bin/bash
cd ~
wget "https://docs.google.com/uc?id=0B3X9GlR6EmbnQ0FtZmJJUXEyRTA&export=download"
mv "uc?id=0B3X9GlR6EmbnQ0FtZmJJUXEyRTA&export=download" gdrive
chmod +x gdrive
sudo install gdrive /usr/local/bin/gdrive
gdrive list

COIN="Bitcoin_Lightning"
DAEMON="Bitcoin_Lightningd"
RPCPORT="17126"
MNPORT="17127"
THEDATE=`date +"%Y%m%d-%H%M"`

sudo touch /var/swap.img
sudo chmod 600 /var/swap.img
sudo dd if=/dev/zero of=/var/swap.img bs=1024k count=2000
mkswap /var/swap.img
sudo swapon /var/swap.img
sudo echo "/var/swap.img none swap sw 0 0" >> /etc/fstab

sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get dist-upgrade -y
sudo apt-get install -y build-essential libtool autotools-dev pkg-config libssl-dev libboost-all-dev autoconf automake -y
sudo apt-get install libzmq3-dev libminiupnpc-dev libssl-dev libevent-dev -y
sudo git clone https://github.com/bitcoin-core/secp256k1

cd ~/secp256k1
./autogen.sh
./configure
make
./tests
make install

sudo apt-get install libgmp-dev -y
sudo apt-get install openssl -y
sudo apt-get install software-properties-common && add-apt-repository ppa:bitcoin/bitcoin -y
sudo apt-get update
sudo apt-get install libdb4.8-dev libdb4.8++-dev -y

cd ~
git clone https://github.com/Bitcoinlightning/Bitcoin-Lightning.git
cd ~/Bitcoin-Lightning/src
make -f makefile.unix
strip ${DAEMON}
cp ${DAEMON} /usr/bin/
cd ~

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
echo "Auto backup wallet.dat to Your google drive"
echo " "
cd .${COIN}
cp wallet.dat wallet.dat-${COIN}-${IP_ADD}
gdrive upload wallet.dat-${COIN}-${IP_ADD}

cat > /root/.${COIN}/wallet-${COIN}-${IP_ADD}.txt <<EOF
Your Masternode Privkey : ${PRIVKEY}
Wallet Address : ${ADDRESS}
EOF
gdrive upload wallet-${COIN}-${IP_ADD}.txt

echo "################################################################################"
echo " "
echo "Backup wallet.dat finish (wallet.dat-bitcoinlightning-${IP_ADD})"
echo " "
echo "Your Masternode Privkey : ${PRIVKEY}"
echo "Transfer 3000 BLTG to address : ${ADDRESS}"
echo " "
echo "################################################################################"

