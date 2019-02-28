#!/bin/bash

##################################
# Variables
##################################

release="1.8.13"
static_build="https://github.com/Bendr0id/xmrigCC/releases/download/1.8.13/xmrigCC-1.8.13-with_tls-gcc7-linux-static-miner_only-x64.tar.gz"

##################################
# Stopping service
##################################

[ -f /etc/systemd/system/xmrigdash.service ] && {
    sudo service xmrigdash stop
    echo "xmrigdash stopped [OK]"
}

# stop xmrigcc
[ -f /etc/systemd/system/xmrigcc.service ] && {
    sudo service xmrigcc stop
    echo "xmrigcc stopped [OK]"
}

if [ -d /etc/xmrigCC/.git ]; then
    git -C /etc/xmrigCC fetch

    ##################################
    # Install gcc7 or gcc8 from PPA
    ##################################

    # Checking lsb_release package
    if [ -z "$(command -v lsb_release)" ]; then
        sudo apt-get -y install lsb-release | sudo tee -a /tmp/nginx-ee.log 2>&1
    fi

    # install gcc-7

    if [ ! -f /etc/apt/sources.list.d/jonathonf-ubuntu-gcc-"$(lsb_release -sc)".list ]; then
        apt-get install software-properties-common -y
        add-apt-repository -y ppa:jonathonf/gcc
        apt-get update
    fi
    if [ ! -x /usr/bin/gcc-7 ]; then
        apt-get install gcc-7 g++-7 -y
    fi
    export CC="/usr/bin/gcc-7"
    export CXX="/usr/bin/gc++-7"

    if [ ! -d /etc/boost ]; then
        cd /etc || exit 1
        curl -sL https://dl.bintray.com/boostorg/release/1.67.0/source/boost_1_67_0.tar.bz2 | /bin/tar xjf - -C /etc
        rm -f boost_1_67_0.tar.bz2
        mv boost_1_67_0 boost
        cd /etc/boost || exit 1
        ./bootstrap.sh --with-libraries=system
        ./b2 --toolset=gcc-7
    fi

    cd /etc/xmrigCC || exit 1

    # get the last release
    git checkout $release

    # compile xmrigcc
    make clean
    cmake . -DCMAKE_C_COMPILER=gcc-7 -DCMAKE_CXX_COMPILER=g++-7 -DBOOST_ROOT=/etc/boost
    make -j"$(nproc)"

else

    cd /etc/xmrigCC || exit 1

    wget -O xmrigcc.tar.gz "$static_build"

    mv config.json c
    /bin/tar -xzf xmrigcc.tar.gz

    rm -f xmrigcc.tar.gz
    rm -f config.json
    mv c config.json

fi


# restart xmrigcc
sudo service xmrigcc start
echo "xmrigcc started [OK]"

if [ -f /etc/systemd/system/xmrigdash.service ]; then
    sudo service xmrigdash start
    echo "xmrigdash started [OK]"
fi
