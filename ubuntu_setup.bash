#!/bin/bash 

###################################################################################
# This Dockerfile is also used to generate the official image install ssh 
# script. (see desktop_update folder in amd-clmc/official_images)
# The [BASH IGNORE*]  [/BASH IGNORE*] ; [SSH ONLY*] [/SSH ONLY*] tags are here to indicate
# what will go in the official ssh install script and what will not
###################################################################################

# [/BASH IGNORE]

##########################################################
# Clean the apt cache to always have up to date packages #
##########################################################

apt-get clean
apt-get -y update
apt-get -y upgrade

###############################################################################
# We add all other repositories.
###############################################################################

########################################################
# Install basic download tools
########################################################
apt-get update
apt-get -y install curl # command line tool for transferring data with URL syntax
apt-get -y install wget # command line tool for retrieving files using HTTP, HTTPS, FTP and FTPS

####################################################
# Install Git and Git Large File Storage: git-lfs
# (use here for installation of CUDA, for example)
####################################################
curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash

apt-get -y update 
apt-get install -y git-lfs git-svn

####################################################
#             ROS INSTALLATION
##
#under ubuntu 16.04 the following changes are made:
#the following packages don't exist in ros kinetic:
#-driver-common 
#-keyboard
####################################################

# enable kernel sources
# this is necessary for the ros package librealsense in 16.04
apt-get install -y sudo              # Provide the sudo rights, required for the enable_kernel_sources.sh script file below
wget -O enable_kernel_sources.sh http://bit.ly/en_krnl_src
bash ./enable_kernel_sources.sh
apt-get update && apt-get install -y software-properties-common

# Get the ROS PPA
echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list && \
wget http://packages.ros.org/ros.key -O - | apt-key add -

# install ros
apt-get -y update
apt-get install -y ros-kinetic-desktop-full

# Install the ros packages
apt-get install -y \
    python-catkin-tools \
    python-rosdep \
    python-rosinstall \
    python-rospkg \
    python-wstool \
    ros-kinetic-audio-common \
    ros-kinetic-catkin \
    ros-kinetic-cmake-modules \
    ros-kinetic-control-toolbox \
    ros-kinetic-ecto \
    ros-kinetic-gazebo-ros-control \
    ros-kinetic-gazebo-ros-pkgs \
    ros-kinetic-joint-state-publisher \
    ros-kinetic-joy \
    ros-kinetic-kdl-parser \
    ros-kinetic-moveit \
    ros-kinetic-moveit-core \
    ros-kinetic-octomap \
    ros-kinetic-octomap-msgs \
    ros-kinetic-octomap-rviz-plugins \
    ros-kinetic-ompl \
    ros-kinetic-openni-* \
    ros-kinetic-pcl-conversions \
    ros-kinetic-qt-build \
    ros-kinetic-realtime-tools \
    ros-kinetic-robot-state-publisher \
    ros-kinetic-ros-control \
    ros-kinetic-ros-controllers \
    ros-kinetic-tf-conversions \
    ros-kinetic-tf-conversions \
    ros-kinetic-robot-self-filter \
    ros-kinetic-xacro \
    ros-kinetic-tf2-bullet \
    ros-kinetic-realtime-tools 

# !!! does not work on docker, without clear error message
#RUN apt-get install -y \
#    ros-kinetic-turtlebot-* 

rosdep init

###################################################################################################
# Install robotpkg dependencies and other dependencies for dynamic graph
###################################################################################################

#[BASH UPDATE]
# Add the robotpkg ppa. This contains the LAAS laboratory code base.
# Typically: pinocchio, dynamic-graph, gepetto-viewer, sot-core, ...
echo "deb [arch=amd64] http://robotpkg.openrobots.org/wip/packages/debian/pub $(lsb_release -sc) robotpkg" > /etc/apt/sources.list.d/ros-latest.list
echo "deb [arch=amd64] http://robotpkg.openrobots.org/packages/debian/pub $(lsb_release -sc) robotpkg" >> /etc/apt/sources.list.d/ros-latest.list
curl http://robotpkg.openrobots.org/packages/debian/robotpkg.key | sudo apt-key add -

# Install the packages

apt-get -y update --fix-missing

apt-get install -y robotpkg-dynamic-graph-v3      # The dynamic graph
apt-get install -y robotpkg-py27-dynamic-graph-v3 # The dynamic graph python bindings
apt-get install -y robotpkg-tsid                  # Andrea Delprete Task Space Inverse Dynamics
apt-get install -y robotpkg-gepetto-viewer        # LAAS 3D robot viewer

apt-get install -y robotpkg-pinocchio             # Eigen based rigid body dynamics library
apt-get install -y robotpkg-hpp-fcl               # collision detection for pinocchio
apt-get install -y robotpkg-libccd                # not sure
apt-get install -y robotpkg-octomap               # not sure
apt-get install -y robotpkg-parametric-curves     # Spline and polynomes library
apt-get install -y robotpkg-simple-humanoid-description # Simple humanoid robot_properties package
apt-get install -y robotpkg-eigen-quadprog        # QP solver using eigen

apt-get install -y robotpkg-sot-core-v3              # Dynamic Graph Utilities
apt-get install -y robotpkg-sot-tools-v3             # Dynamic Graph Utilities
apt-get install -y robotpkg-sot-dynamic-pinocchio-v3 # DG wrapper around pinocchio
# RUN apt-get install -y robotpkg-sot-torque-control       # Andrea dynamic graph entities

apt-get install -y robotpkg-example-robot-data      # Data for LAAS unnitests.

apt-get install -y robotpkg-py27-eigenpy            # Python bindings
apt-get install -y robotpkg-py27-pinocchio          # Python bindings
apt-get install -y robotpkg-py27-parametric-curves  # Python bindings
apt-get install -y robotpkg-py27-sot-core-v3        # Python bindings
apt-get install -y robotpkg-py27-quadprog           # Python bindings
# RUN apt-get install -y robotpkg-py27-sot-torque-control # Python bindings
apt-get install -y robotpkg-py27-sot-dynamic-pinocchio-v3 # Python bindings
apt-get install -y robotpkg-py27-qt4-gepetto-viewer-corba # LAAS 3D robot viewer network client/server

###################################################################################################
#                              BIG HUGE MESS :)
#
# under ubuntu 16.04 the following changes are made:
# -instead of libwxgtk2.8-dev /-dbg, the following packages are installed:
# 	libwxgtk3.0-0v5
# 	libwxgtk3.0-0v5-dbg
# 	libwxgtk3.0-dev
# -libccd-dev is now installed from apt-get instead of adding the repository to sources.list.d
# -libglew-dev instead of liblew1.6-dev
# -libfcl-dev
# 
# the following repositories are no longer supported under 16.04:
# fcl-debs
# libccd-debs
# however, the libraries are intalled with apt-get
##################################################################################################

# here we update once before all the apt-get install
apt-get -y update

# Potentially just os tools, e.g. editor, fancy terminals
apt-get install -y bash-completion     `# Allow bash completion`\
    	    	       alien               `# File conversions`\
		       terminator          `# Fancy terminal`\
		       apt-file            `# Is a software package that indexes`\
                                           `# the contents of packages in your`\
                                           `# available repositories and allows you`\
                                           `# to search for a particular file among`\
                                           `# all available packages.`\
		       autofs              `# Used to automount external device (usb, HD, ...)`\
		       bc                  `# "JrBc", A calculator that can be used from the command-line`\
		       imagemagick         `# Image manipulation (convert)`\
		       f2c                 `# Fortran to C/C++ translator`\
		       libf2c2-dev         `# To be used with f2c (fortran 2 c/c++)`\
		       man                 `# on-line manual pager`\
		       libcairo2-dev       `# 2D Graphics package`\
		       patch               `# Apply a diff file to an original`\
		       picocom             `# minimal dumb-terminal emulation program`\
		       rpm                 `#  Tools to create and apply deltarpms`\
		       scons               `# replacement for make, depends on python... ????`\
		       screen              `# terminal multiplexer with VT100/ANSI terminal emulation`\
		       shellcheck          `# lint tool for shell scripts`\
		       vim                 `# Terminal editor`\
		       swig                `# Generate scripting interfaces to C/C++ code`\
		       tcsh                `# TENEX C Shell, an enhanced version of Berkeley csh`\
		       xmlto               `# XML-to-any converter`

# Development tools
apt-get install -y less                `# Similar to "more", installed by default?`\
                       ccache              `# Optimize the cache during build.`\
                       gdb                 `# code debugger`\
                       iputils-ping        `# Tools to test the reachability of network hosts`\
                       cmake-curses-gui    `# ccmake`\
                       ssh                 `# ssh client+server`\
                       openssh-server      `# ssh server`\
                       sshpass             `# Non-interactive ssh password authentication`\
                       emacs               `# Basic text editor`

# Code dependencies 
apt-get install -y autoconf               `# Used to build SNOPT from source`\
		    cmake                  `# C++, Python Project builder`\
		    lsb-release            `# Linux Standard Base version reporting utility `\
		    libconfig++8-dev       `# pkgconfig`\
		    binutils               `# GNU assembler, linker and binary utilities`\
		    build-essential        `# Build tools (gcc, g++, ...)`\
		    gfortran               `# Fortran compiler`\
		    doxygen                `# Main documentation writting used`\
		    freeglut3              `# OpenGL Utility Toolkit`\
		    freeglut3-dev          `# OpenGL Utility Toolkit`\
		    libblas-dev            `# Basic Linear Algebra Subroutines 3, static library `\
		    liblapack-dev          `# Linear algebra subroutines`\
		    libarmadillo-dev       `# Linear algebra and scientific computing`\
		    libeigen3-dev          `# Linear Algebra header library`\
		    libfcl-dev             `# flexible collision library`\
		    libslicot-dbg          `# SNOPT: numerical algorithms from systems and control theory`\
		    libslicot-dev          `# SNOPT: numerical algorithms from systems and control theory`\
		    libslicot0             `# SNOPT: numerical algorithms from systems and control theory`\
		    libncurses5-dev        `# Shell management library`\
		    python-dev             `# python stuff `\
		    python-netifaces       `# python stuff `\     
		    python-pip             `# python stuff `\
		    python-vcstools        `# python stuff `\   
		    python-wstool          `# python stuff `\
		    python-qt4             `# python stuff `\
		    python-empy            `# python stuff `\
		    python-opencv          `# python stuff `\
		    libcereal-dev          `# serialization library, used in the shared_memory `
#[/BASH UPDATE]

############################
# remove unrequired packages
############################
apt-get -y update && apt-get -y upgrade 
apt-get -y autoremove

###############################################################################
# PYTHON MODULES
# new for 16.04:
# pip first has to be installed with apt-get
###############################################################################


#[BASH UPDATE]
apt-get install -y python-pip
sudo -H pip2 install --no-cache-dir --upgrade pip
sudo -H pip2 install --no-cache-dir --upgrade pyopenssl
sudo -H pip2 install --no-cache-dir  --upgrade \
    colorama \
    matplotlib `# Plotting library` \
    seaborn \
    ndg-httpsclient \
    numpy `# Linear algebra library` \
    pyasn1 \
    schedule \
    scipy \
    sklearn \
    virtualenv `# Creation of virtual environment for python2` \
    appdirs \
    h5py \
    keras \
    ipython `# Nice python terminal` \
    ipdb \
    jupyter `# Nice python web interface` \
    treep `# MPI-IS code project manager` \
    sphinx `# Python documentation generator` \
    gcovr `# Compute the code coverage` \
    bs4 `# Install the BeautifulSoup (html parsing)` \
    pybullet `# This the python bindings over the Bullet simulator`

sudo -H pip2 install --no-cache-dir pydot==1.0.28
sudo -H pip2 install --no-cache-dir pyparsing==2.0.1
sudo -H pip2 install --no-cache-dir --upgrade six --target="/usr/lib/python2.7/dist-packages"
sudo -H pip2 install --no-cache-dir --upgrade appdirs
sudo -H pip2 install --no-cache-dir --upgrade protobuf
sudo -H pip2 install --no-cache-dir --upgrade sphinx

# Basic packages required for running python3 with catkin setup.
apt-get install -y python3-pip
sudo -H pip3 install --no-cache-dir --upgrade pip
sudo -H pip3 install --no-cache-dir --upgrade \
    catkin_pkg \
    rospkg 
sudo -H pip3 install --no-cache-dir --upgrade sphinx

# Auto complete treep
sudo activate-global-python-argcomplete

#[/BASH UPDATE]

#############################################################################
# Software Workshop RAI
#############################################################################
# !!! this requires some more configuration, see
# readme.txt for docker clues (works on 14.04, need update for 16.04)
# note : the commands below requires access to DNS, for docker configuration
#        check the readme.txt file in the same folder as this Dockerfile
#[BASH UPDATE]
#RUN cd /tmp && \
#    wget --no-check-certificate https://code.is.localnet/media/artifacts/AMD%20plotting%20library/89163d92f9ee40a10dc76762946babc4/RAI-0.3.tar.gz && \
#    tar -xzf ./RAI-0.3.tar.gz && \
#    cd RAI-0.3 && \
#    sudo -H pip install .
#[/BASH UPDATE]

###############################################################################
# required for the use of snopt 
###############################################################################
#[BASH UPDATE]
wget http://ftp.gnu.org/gnu/autoconf/autoconf-2.69.tar.gz -P /tmp/ && \
    tar -xf /tmp/autoconf-2.69.tar.gz -C /tmp/ && \
    rm /tmp/autoconf-2.69.tar.gz && \
    cd /tmp/autoconf-2.69 && \
    ./configure && \
    make -C /tmp/autoconf-2.69 && \
    make install -C /tmp/autoconf-2.69
#[/BASH UPDATE]

#[BASH IGNORE]
#########################################
# for convenience, to map workspace in it
#########################################
mkdir /workspace
mkdir /ssh
#[/BASH IGNORE]

###############
# Final upgrade
###############
#[BASH UPDATE]
apt-get -y update && apt-get -y upgrade  
#[/BASH UPDATE]

########################
# start ssh agent
########################
eval `ssh-agent -s`

##########################################################
# Clean the apt cache to always have up to date packages #
##########################################################
apt-get clean
