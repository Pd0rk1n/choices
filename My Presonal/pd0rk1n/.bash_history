ngrub
npacman 
fixkeys
sps nemo nemo-share
cd github/
git clone https://github.com/Pd0rk1n/arcolinux-nemesis.git
cd arcolinux-nemesis/
./give-me-pacman.conf.sh 
update
att
sps xed
ls
./0-current-choices.sh 
chsh
sr
cd arcolinux-nemesis/
./give-me-pacman.conf.sh 
update
att
sps xed
ls
./0-current-choices.sh 
chsh
sr
ls -al ~/.ssh
ssh-keygen -t ed25519 -C "patrick.dorkin@hotmail.com"
Generating public/private ALGORITHM key pair
sudo systemctl start sshd
sudo systemctl enable sshd
sudo systemctl status sshd
ssh-add ~/.ssh/id_ed25173
ssh-keygen -t rsa -b 4096 -C "patrick.dorkin@hotmail.com"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
cat ~/.ssh/id_ed25519.pub
picom
fish'
