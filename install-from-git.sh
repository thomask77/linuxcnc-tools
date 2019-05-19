#!/bin/bash
set -o nounset -o pipefail -o errexit

mark() {
    echo -e "\n\e[1;33m$@\n\e[0m"
}

if (( $EUID == 0 )); then
    echo "This script must be run as a normal user!"
    exit
fi

mark ----- Adding apt sources -----

sudo apt install -y software-properties-common
sudo add-apt-repository -y contrib
sudo add-apt-repository -y non-free


mark ----- Installing realtime kernel -----

kernel=$(uname -r)

if [[ "$kernel" == *-rt-* ]];
then
    echo "Already running rt-enabled kernel: $kernel"
else
    sudo apt install -y linux-image-rt-amd64
    read -p "Reboot? [y/N] "
    if [[ "$REPLY" == "y" ]];
    then
        reboot
    fi
fi


mark ----- Installing required packages -----

# output from dpkg-checkbuilddeps + some additional packages

sudo apt update
sudo apt install -y \
    git gitk tig \
    dpkg-dev \
    debhelper dh-python libudev-dev libxenomai-dev \
    tcl8.6-dev tk8.6-dev libreadline-gplv2-dev asciidoc \
    dblatex docbook-xsl dvipng graphviz groff source-highlight \
    texlive-extra-utils texlive-font-utils texlive-fonts-recommended \
    texlive-lang-cyrillic texlive-lang-french texlive-lang-german \
    texlive-lang-polish texlive-lang-spanish texlive-latex-recommended \
    w3c-linkchecker xsltproc asciidoc-dblatex python-dev python-tk \
    libxmu-dev libglu1-mesa-dev libgl1-mesa-dev libgtk2.0-dev \
    intltool autoconf libboost-python-dev libmodbus-dev libusb-1.0-0-dev \
    bwidget libtk-img tclx python-gtk2 python-glade2 python-gtkglext1 \
    libgtksourceview2.0-0 python-pip

# Buster's yapps2 does not install yapps anymore..
#
sudo pip install --system yapps2

if [[ ! -f /usr/local/bin/yapps ]]; then
  sudo ln -s /usr/local/bin/yapps2 /usr/local/bin/yapps
fi

# Buster does not have python-gtksourceview2 at the moment..
#
wget -c http://ftp.debian.org/debian/pool/main/p/pygtksourceview/python-gtksourceview2_2.10.1-3_amd64.deb
sudo dpkg --install ./python-gtksourceview2_2.10.1-3_amd64.deb


mark ----- Compiling LinuxCNC -----

git -C linuxcnc pull || git clone https://github.com/linuxcnc/linuxcnc
(
    cd linuxcnc
    cd src
    ./autogen.sh
    ./configure

    make -j$(nproc)

    sudo make setuid
)


read -p "Run tests (lengthy!) [y/N] "
if [[ "$REPLY" == "y" ]];
then

mark ----- Running Tests -----
(
    cd linuxcnc
    set +o nounset

    source scripts/rip-environment
    runtests
)

fi


mark ----- Finished! -----
