#!/bin/sh
# Creates a chroot (a Debian with debootstrap)
# Run scripts inside the chroot (useful for creating the base gcodis)
# Deploy a copy to LXC, running the necessary conversions from chroot and generating the config file for the container

# If no parameters are given, creates the bootstrap, deploys to LXC and install the base gcodis inside, and run the deployed LXC container.

#metainstall: packages and admin tasks to create gcodis itself
#create-chroot
#copy-script-to-target (allows the administration and updates)
#metainstall-in-chroot
#metainstall-with-remote-ssh
#convert-chroot-to-lxc
#deploy-lxc
#run-lxc (lxc-start)

#autolink: autogenerate link scripts with its own names

#### Parameters and data

#chroot=
#deploy=
# Script to run inside an environment
# For example we can convert a chroot into a gcodis deployment
#metascript=

#### Initialization

# Not needed
# Source: http://stackoverflow.com/questions/920755/how-to-get-script-file-path-inside-script-itself-when-called-through-sym-link
if [ -L $0 ] ; then
    DIR=$(dirname $(readlink -f $0)) ;
else
    DIR=$(dirname $0) ;
fi
# cd into $DIR and all script calls are local to the script path
cd $DIR


#### Functions

#### # debootstrap

# Requirements:
# wget
# binutils: for ar
# coreutils or coreutils-sha1sum: for sha1sum
#
# This script installs debootstrap on your current filesystem.
# It's useful for use in distributions different to Debian.
# It allows to create the initial chroot in any Linux installation.
# If it's not a debian we have to install packages manually outside
# the script.
# The required packages are 'binutils' (for the 'ar' binary) and 'wget'.
# 'debootstrap' in Debian depends on 'wget'

#### ## functions used by checkinstall_debootstrap_requirements

ar_is_installed() {
  if [ -x "`which ar`" ] ; then
    return 0
  else
    return 1
  fi
}

wget_is_installed() {
  if [ -x "`which wget`" ] ; then
    return 0
  else
    return 1
  fi
}

# Check if 'debootstrap' is installed and in the path
debootstrap_is_installed() {
  if [ -x "`which debootstrap`" ] ; then
    return 0
  else
    return 1
  fi
}

apt_get_is_installed() {
  if [ -x "`which apt-get`" ] ; then
    return 0
  else
    return 1
  fi
}

perl_is_installed() {
  if [ -x "`which perl`" ] ; then
    return 0
  else
    return 1
  fi
}

opkg_is_installed() {
  if [ -x "`which opkg`" ] ; then
    return 0
  else
    return 1
  fi
}

coreutils_sha1sum_is_installed () {
  if [ -x "`which sha1sum`" ] ; then
    return 0
  else
    return 1
  fi
}


install_debootstrap_manually() {
  FICH=debootstrap_1.0.53_all.deb
  #FICH=debootstrap-udeb_1.0.53_all.udeb

  mkdir tmp/
  cd tmp/

  wget http://ftp.debian.org/debian/pool/main/d/debootstrap/$FICH

  ar -x $FICH

  WD=`pwd`
  cd /
  zcat $WD/data.tar.gz | tar xv

  cd ..  

  # TODO
  return 0
}

# Check and install debootstrap and its requirements
# Useful for systems which aren't Debian systems
checkinstall_debootstrap_requirements () {

    echo "CAUTION: this installs the package 'debootstrap' and its"
    echo "requirements system wide."
    echo " Installs the required packages 'binutils' and 'wget'"
    echo "which are required for debootstrap."
    echo " If you aren't on a Debian system, you can install previously"
    echo "the packages 'binutils' (to get the binay 'ar')"
    echo "'coreutils' or 'coreutils-sha1sum' to get the sha1sum file"
    echo "and 'wget' with your usual installation system."
    echo
    echo " * Press [enter] if you're on a Debian system."
    echo " * Press [enter] if you're not on a Debian system and you installed"
    echo "   previously the:"
    echo "     - 'binutils' package to get the 'ar' binary"
    echo "     - 'wget' package"
    echo " * Press [ctrl+c] if you aren't on a Debian system AND"
    echo "   you haven't installed the previous mentioned required packages."
    echo "   Then, please install them manually"
    read a

    # install requirements
    # install 'binutils' to get the 'ar' binary
    if ! ar_is_installed ; then
      if apt_get_is_installed ; then
	apt-get -y install binutils
      else # ar is not installed ant we can't install it with apt-get (default)
	if opkg_is_installed ; then
	  opkg install binutils
	else
	  echo "The 'ar' binary is needed. Please, install 'binutils' (or similar) package to get the 'ar' binary."
	  exit 1
	fi
      fi
    fi
    # install wget
    # usually debootstrap depends on wget, 
    # wget is installed automatically with debootstrap
    if ! wget_is_installed ; then
      if apt_get_is_installed ; then
	apt-get -y install wget
      else
	if opkg_is_installed ; then
	  opkg install wget
	else # wget is not installed and We couldn't install wget with default tool
	  echo "Please, install 'wget' with ssl support."
	  exit 1
	fi
      fi
    fi
    # install debootstrap                                
    if ! debootstrap_is_installed ; then                                      
      if apt_get_is_installed ; then           
	apt-get -y install debootstrap                     
      else
	if opkg_is_installed ; then
	  # trunk (2013-09-01) has debootstrap
	  opkg install debootstrap
	else                                                       
	  install_debootstrap_manually                                         
	# exit 0                                
	fi
      fi                                      
    fi                                                                         
    # Requisite for running debootstrap
    if  ! perl_is_installed ; then  
      if apt_get_is_installed ; then 
	apt-get -y install perl             
      else                                
	if opkg_is_installed ; then                   
	  opkg install perl    
	else                   
	  echo "Please install the 'perl' package."                  
	  exit 1
	fi                          
      fi                       
    fi                                                                           
    # Requisite for running debootstrap
    if  ! coreutils_sha1sum_is_installed ; then
      if apt_get_is_installed ; then
	apt-get -y install perl
      else
	if opkg_is_installed ; then
	  opkg install coreutils-sha1sum
	else
	  echo "Please install the 'coreutils' package and provide the file 'sha1sum'."
	  exit 1
	fi
      fi
    fi

    # At this point, we have to have installed 
    # the files: ar, wget, sha1sum and debootstrap
}

#### # create the debootstrap itself

create_debootstrap () {

    # This script installs a wheezy distribution with debootstrap.

    # We need a partition to create the directory without the 'nosuid' option.
    # The openwrt /tmp is mounted with the 'nosuid' option
    # In Debian and OpenWrt the / partition is mounted without 'nosuid' option.
    # The / partition seems a 'good' common place to create the chroot environment.
    # Perhaps a good place could be /root.

    # Parameters
    # You can redefine variables
    # TODO: Redefine variables from the command line
    # Actually we base the development in wheezy i386
    ARCH=i386
    BRANCH="wheezy"
    TARGET="/debootstrap-$ARCH-$BRANCH-rootfs"
    # can be a local media ?
    PACKAGES_URL=http://cdn.debian.net/debian
    
    # Check existence of previous build at $TARGET
    echo "TODO: Check for the existence of a previous build at $TARGET and query for deletion or reuse."
    # If previous build exists, query for deletion or interrupt manually to operate the situation
    # Or reuse the chroot directory
    if [ -d $TARGET ] ; then return 0 ; fi

    # TODO: Here the default build directory doesn't exists, we can continue

    mkdir $TARGET

    echo "If you want to fine tune the installation, you can change the ARCH, BRANCH and TARGET variables inside this script. Now they're:"
    echo " - ARCH=$ARCH"
    echo " - BRANCH=$BRANCH"
    echo " - TARGET=$TARGET"
    echo " If you're ready to install press [enter],"
    echo " otherwise press [crtl+c]."
    read a
    /usr/sbin/debootstrap --arch $ARCH $BRANCH \
	$TARGET/ $PACKAGES_URL
	#default: i386 wheezy /debootstrap-.../ http://cdn.debian.net/debian
}

#### # deploy to LXC

# Some code from lxc-debian script, LXC project

# #### BEGIN functions

# We copy the debootstrap to the containers path location
# to do the conversion and deploy it
#copy_debootstrap_to_containers_path $from $to
copy_debootstrap_to_containers_path () {

  from=$1
  to=$2
  rootfs=$3

  mkdir $to
  mkdir $rootfs
  cp -dpa $from/* $rootfs/
}

# Install extra packages
install_extra_packages () {

  rootfs=$1

  chroot $rootfs apt-get -y install ifupdown locales libui-dialog-perl dialog isc-dhcp-client netbase net-tools iproute openssh-server

}

# Configures Debian rootfs
configure_debian()
{
    rootfs=$1
    hostname=$2

    # squeeze only has /dev/tty and /dev/tty0 by default,
    # therefore creating missing device nodes for tty1-4.
    for tty in $(seq 1 4); do
        if [ ! -e $rootfs/dev/tty$tty ]; then
            mknod $rootfs/dev/tty$tty c 4 $tty
        fi
    done

    # configure the inittab
    cat <<EOF > $rootfs/etc/inittab
id:3:initdefault:
si::sysinit:/etc/init.d/rcS
l0:0:wait:/etc/init.d/rc 0
l1:1:wait:/etc/init.d/rc 1
l2:2:wait:/etc/init.d/rc 2
l3:3:wait:/etc/init.d/rc 3
l4:4:wait:/etc/init.d/rc 4
l5:5:wait:/etc/init.d/rc 5
l6:6:wait:/etc/init.d/rc 6
# Normally not reached, but fallthrough in case of emergency.
z6:6:respawn:/sbin/sulogin
1:2345:respawn:/sbin/getty 38400 console
c1:12345:respawn:/sbin/getty 38400 tty1 linux
c2:12345:respawn:/sbin/getty 38400 tty2 linux
c3:12345:respawn:/sbin/getty 38400 tty3 linux
c4:12345:respawn:/sbin/getty 38400 tty4 linux
p6::ctrlaltdel:/sbin/init 6
p0::powerfail:/sbin/init 0
EOF

    # disable selinux in debian
    mkdir -p $rootfs/selinux
    echo 0 > $rootfs/selinux/enforce

    # configure the network using the dhcp
    cat <<EOF > $rootfs/etc/network/interfaces
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp
EOF

    # set the hostname
    cat <<EOF > $rootfs/etc/hostname
$hostname
EOF

    # reconfigure some services
    if [ -z "$LANG" ]; then
        chroot $rootfs locale-gen en_US.UTF-8 UTF-8
        chroot $rootfs update-locale LANG=en_US.UTF-8
    else
        chroot $rootfs locale-gen $LANG $(echo $LANG | cut -d. -f2)
        chroot $rootfs update-locale LANG=$LANG
    fi

    # remove pointless services in a container
    chroot $rootfs /usr/sbin/update-rc.d -f checkroot.sh remove
    chroot $rootfs /usr/sbin/update-rc.d -f umountfs remove
    chroot $rootfs /usr/sbin/update-rc.d -f hwclock.sh remove
    chroot $rootfs /usr/sbin/update-rc.d -f hwclockfirst.sh remove

    echo "root:root" | chroot $rootfs chpasswd
    echo "Root password is 'root', please change !"

    return 0
}

copy_configuration()
{
    path=$1
    rootfs=$2
    hostname=$3

    grep -q "^lxc.rootfs" $path/config 2>/dev/null || echo "lxc.rootfs = $rootfs" >> $path/config
    cat <<EOF >> $path/config
lxc.tty = 4
lxc.pts = 1024
lxc.utsname = $hostname

# When using LXC with apparmor, uncomment the next line to run unconfined:
#lxc.aa_profile = unconfined

lxc.cgroup.devices.deny = a
# /dev/null and zero
lxc.cgroup.devices.allow = c 1:3 rwm
lxc.cgroup.devices.allow = c 1:5 rwm
# consoles
lxc.cgroup.devices.allow = c 5:1 rwm
lxc.cgroup.devices.allow = c 5:0 rwm
lxc.cgroup.devices.allow = c 4:0 rwm
lxc.cgroup.devices.allow = c 4:1 rwm
# /dev/{,u}random
lxc.cgroup.devices.allow = c 1:9 rwm
lxc.cgroup.devices.allow = c 1:8 rwm
lxc.cgroup.devices.allow = c 136:* rwm
lxc.cgroup.devices.allow = c 5:2 rwm
# rtc
lxc.cgroup.devices.allow = c 254:0 rwm

# mounts point
lxc.mount.entry = proc proc proc nodev,noexec,nosuid 0 0
lxc.mount.entry = sysfs sys sysfs defaults  0 0
EOF

    if [ $? -ne 0 ]; then
        echo "Failed to add configuration"
        return 1
    fi

    return 0
}

# We have to configure the network for the container
# Add network configuration lines to its $to/config file
configure_lxc_network(){
  
  to=$1


  # Generate random mac address
  # Source: http://serverfault.com/questions/299556/how-to-generate-a-random-mac-address-from-the-linux-command-line
  # The FQDN is the hostname for us
  FQDN=$hostname
  macaddr=$(echo $FQDN|md5sum|sed 's/^\(..\)\(..\)\(..\)\(..\)\(..\).*$/02:\1:\2:\3:\4:\5/')

# The default bridge for LXC is 'lxcbr0'. Get dhcp with dnsmasq.
# copied from a generated LXC network configuration
  cat <<EOF >> $to/config
## Network
lxc.network.type                        = veth
lxc.network.flags                       = up
lxc.network.hwaddr                      = $macaddr
# lxc.network.link                        = vmbr
lxc.network.link                        = lxcbr0
lxc.network.name                        = eth0
EOF
}

# Show usage information
usage()
{
    cat <<EOF
$1 -h|--help -p|--path=<path> --clean
EOF
    return 0
}

#### ## BEGIN main lxc

deploy_to_lxc () {

    # debug
    debug=1

    # Input
    # Parameters from the command line:
    # hostname=$1 from=$2 to=$3 rootfs=$path/rootfs
    hostname="$1"
    from="$2/"
    # place where the container will be with its name
    # LXC containers main directory
    # By default its $to=/var/lib/lxc/debug-gcodis
    # $to can be derived from hostname?
    to="$3/"
    rootfs="$to/rootfs/"

    # debug
    if [ $debug ] ; then echo "hostname=$hostname from=$from to=$to rootfs=$rootfs" ; fi

    if [ "$#" != 3 ] ; then
      echo "Usage: $0 hostname from to"
      echo "Parameters:"
      echo "  - hostname: the hostname for the deployed LXC container (will be deployed by default in /var/lib/lxc/hostname)"
      echo "  - from: path for the already generated debootstrap to be deployed"
      echo "  - to: where to deploy the LXC container (by default is /var/lib/lxc)"
      exit 1
    fi

    # main
    # TODO
      mkdir -p $to
    echo "copy_debootstrap_to_containers_path $from $to $rootfs"
    copy_debootstrap_to_containers_path $from $to $rootfs
    echo "install_extra_packages $rootfs $hostname"
    install_extra_packages $rootfs $hostname
    echo "configure_debian $rootfs $hostname"
    configure_debian $rootfs $hostname
    echo "copy_configuration $to $rootfs $hostname"
    copy_configuration $to $rootfs $hostname
    echo "configure_lxc_network $to"
    configure_lxc_network $to
}

#### # Install gcodis itself (this is the default option)

# Simply install gcodis locally Debian Wheezy (at least)
# Can be run inside a chroot
# Usually called to run inside a chroot when deploying the gcodis distro
install_gcodis () {
  #### gcodis BEGIN ####
  # This script suposes a Debian installation
  # This part BEGIN test if squeeze is installed to update to wheezy to install tahoe-lafs
  debian_version=`cat /etc/debian_version | cut -f 1 -d . `
  if [ $debian_version -eq '6' ]
  then
    echo 'deb http://cdn.debian.net/debian wheezy main' > /etc/apt/sources.list.d/wheezy.list
  fi
  # END check for squeeze and update to wheezy
  # From here is supossed to have a Debian Wheezy installed
  apt-get -y update
  apt-get -y install tahoe-lafs avahi-utils
  # extra tools for avahi
  apt-get -y install avahi-daemon avahi-autoipd dbus-x11 geoip-bin avahi-utils
  # Add test user with: user: testuser, pass: testuser
  useradd -m -p '$6$Tc2F3vjG$2FErXS54lz3Xzk3Vy5UnclgPOy2yBFBQ0C9EVzvek8lU/sc/MmsOj9wEtZsdnAWYKgsRcY3gHpG/TS11lqHj8.' -s /bin/bash -d /home/testuser testuser
  # Alternatively for the password: echo -n 'testuser:testuser' | chpasswd
  # BEGIN guifi.net distro
  # Source: http://es.wiki.guifi.net/wiki/Configurar_Repositorio_APT_guifi
  # Repositorio oficial de Guifi.net
  echo 'deb http://serveis.guifi.net/debian guifi/' > /etc/apt/sources.list.d/guifi.net-stable.list
  # Una vez añadida esta línea, como el repositorio está firmado, se tiene que introducir la clave pública la primera vez que lo uséis, para hacerlo se tiene que ejecutar este comando:
  apt-key adv --keyserver pgp.mit.edu --recv-keys 2E484DAB
  # Algunas veces este "keyserver" no responde, así que si da algun otro error, probad con este otro:
  apt-key adv --keyserver pgp.rediris.es --recv-keys 2E484DAB
  # Finalmente actualizaremos el repositorio de nuestro sistema con: 
  apt-get update
  # END   guifi.net distro
  # BEGIN gcodis-init script for initial configuration 
  # TODO: Can include previous steps
  # TODO: Configure guifi.net with id=0, can copy preconfigured files
  # END   gcodis-init script for initial configuration 
  # BEGIN some tools
  # ping hosts: inetutils-ping
  # edit files: vim, nano
  # VPN connections: openvpn
  apt-get -y install openvpn inetutils-ping vim nano
  apt-get -y install openssh-server # or lsh-server
  # END   some tools
  #### gcodis END   ####
}


#### # Installs gcodis inside a previously created chroot

# Install-create a gcodis distro in an existing chroot.
# The target ($to) can be debootstrap or lxc.
# Using the default function and this script we don't use external scripts.
install_gcodis_to_chroot () {

  # Parameters
  to=$1



  # copy the (this) script to the chroot
  /bin/cp -v $0 $to/
  # run the script with the parameter: install_gcodis
  # script name
  script=`basename $0`
  chroot $to/ /bin/sh /$script install_gcodis

}

#### Main Algorithm

echo "Guifi-Community-Distro"

echo "To execute properly this script run it with root permissions. If you have root permissions you can run the command writing \"sh ./$0\" or try with the \"sudo ./$0\" command, please."

if [ "$0" != "gcodis-create.sh" ] ; then 
  `basename $0` $*
  exit 0
fi


#### # Called with parameter install_gcodis
# Install gcodis itself inside the system in which the script was called
if [ "$1" = "install_gcodis" ] ; then
  install_gcodis
  exit 0
fi

#### # Normal execution (called without parameters) ($0=gcodis-create.sh)

# Creates a Debian chroot using debootstrap
checkinstall_debootstrap_requirements
create_debootstrap 

# Deploys the Debian chroot to a LXC container
# TODO:- checkinstall_lxc_requirements -> 'lxc' or 'lxc-start'
# deploy_to_lxc hostname from to
deploy_to_lxc gcodis-debug /debootstrap-i386-wheezy-rootfs/ /var/lib/lxc/gcodis-debug/

# Run metadmin script inside the target environment
# In the default use case, the convert-to-gcodis.sh script does:
#   - convert target environment to gcodis
#   - fetch gcodis from github to $target/rootfs/gcodis.git for updates and extra functionallity
#   - alternativelly, in place of fetch, we can copy the directory
## - metadmin_inside 
##  - 1.1 copy gcodis.git to deployment (this directory)
##  - 2 run metadmin script inside the deployment
#
##- metadmin_inside_gcodis
##  - run this script with the 'install_gcodis' parameter inside the chroot
##    - actually run the function: install_gcodis_to_chroot $to
install_gcodis_to_chroot /var/lib/lxc/gcodis-debug/rootfs/

# Run the deployed environment if called with the default options
#apt-get install lxc
#opkg install lxc-start
#lxc-start -n gcodis-debug
echo "If you run the default script with default options you can test the generate container doing: 'lxc-start -n gcodis-debug'"


# 2013-09-03: Tested on Debian GNU/Linux unstable
# 2013-09-03: WIP on OpenWrt trunk
