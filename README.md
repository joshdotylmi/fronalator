# fronalator

wg server setup:
sudo adduser wgkeygen
Set a secure password : )

mkdir ~/.ssh
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N ""
cat .ssh/id_ed25519.pub > ~/.ssh/authorized_keys
copy file to hdd putty messes up the formatting somehow.
cat ~/.ssh/id_ed25519
copy genClient.sh to home folder for wgkeygen
make file executable chmod +x ./genClient.sh

sudo sed -i 's/#\?\(Port\s*\).*$/\1 42042/' /etc/ssh/sshd_config
sudo sed -i 's/#\?\(PubkeyAuthentication\s*\).*$/\1 yes/' /etc/ssh/sshd_config

sudo chmod -R 770 /etc/wireguard
sudo chown -R :wgkeygen /etc/wireguard

sudo visudo

add to the end of file
wgkeygen ALL=(ALL) NOPASSWD: /usr/bin/wg syncconf *
