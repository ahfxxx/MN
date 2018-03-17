#!/bin/bash

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
strip Bitcoin_Lightningd
cp Bitcoin_Lightningd /usr/bin/
cd ~

Bitcoin_Lightningd

sudo apt-get install -y pwgen
GEN_PASS=`pwgen -1 40 -n`
IP_ADD=`curl ipinfo.io/ip`

cat > /root/.Bitcoin_Lightning/Bitcoin_Lightning.conf <<EOF

rpcuser=ffer34sd423@#%dg5g24
rpcpassword=${GEN_PASS}
server=1
listen=1
maxconnections=256
daemon=1
port=17126
rpcallowip=127.0.0.1
masternodeaddr=${IP_ADD}:17127
addnode:92.186.144.255

EOF

cd ~

sleep 2

Bitcoin_Lightningd

