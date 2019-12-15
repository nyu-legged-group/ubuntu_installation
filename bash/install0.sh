sudo apt-get install python-pip
pip install catkin-pkg
cd
mkdir repos
cd repos
sudo apt install git
git clone https://github.com/ddliugit/humanoid_control.git
git clone https://github.com/ddliugit/humanoid_simulation.git
git clone https://github.com/ddliugit/humanoid_property.git
cd 
cd repos
cd humanoid_control
sudo python ~/repos/humanoid_control/setup.py install --user
cd 
cd repos
cd humanoid_property
sudo python ~/repos/humanoid_property/setup.py install --user
cd 
cd repos
cd humanoid_simulation
sudo python ~/repos/humanoid_simulation/setup.py install --user
python -m pip install -U pip --user
python -m pip install -U matplotlib --user
sudo apt-get install python-tk
pip install ipython --user
cd IntegratedTest
python integratedTest.py --user
