
#install sublime
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
sudo apt-get install apt-transport-https
echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
sudo apt-get update
sudo apt-get install sublime-text

#install pinocchio
sudo sh -c "echo 'deb [arch=amd64] http://robotpkg.openrobots.org/packages/debian/pub xenial robotpkg' >> /etc/apt/sources.list.d/robotpkg.list"

curl http://robotpkg.openrobots.org/packages/debian/robotpkg.key | sudo apt-key add -
sudo apt-get update

sudo apt install robotpkg-py27-pinocchio

echo 'export PATH=/opt/openrobots/bin:$PATH' >> ~/.bashrc 
echo 'export PKG_CONFIG_PATH=/opt/openrobots/lib/pkgconfig:$PKG_CONFIG_PATH' >> ~/.bashrc
echo 'export LD_LIBRARY_PATH=/opt/openrobots/lib:$LD_LIBRARY_PATH' >> ~/.bashrc
echo 'export PYTHONPATH=/opt/openrobots/lib/python2.7/site-packages:$PYTHONPATH' >> ~/.bashrc 

source ~/.bashrc
cd
mkdir repos
cd repos
sudo apt install git
git clone https://github.com/ddliugit/humanoid_control.git
git clone https://github.com/ddliugit/humanoid_simulation.git
git clone https://github.com/ddliugit/humanoid_property.git




