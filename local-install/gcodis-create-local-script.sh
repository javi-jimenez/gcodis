#!/bin/sh

# Install gcodis itself (this is the default option)

# Simply install gcodis locally Debian Wheezy (at least)
# Can be run inside a chroot
# Usually called to run inside a chroot when deploying the gcodis distro
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
  # Add gcodis user with: user: gcodis, pass: ! (locked)
  useradd -m -s /bin/bash -d /home/gcodis gcodis
  # Alternatively for the password: echo -n 'gcodis:newpasswd' | chpasswd
  # BEGIN guifi.net distro
  # Source: http://es.wiki.guifi.net/wiki/Configurar_Repositorio_APT_guifi
  # Repositorio oficial de Guifi.net
  echo 'deb http://serveis.guifi.net/debian guifi/' > /etc/apt/sources.list.d/guifi.net-stable.list
  # Una vez añadida esta línea, como el repositorio está firmado, se tiene que introducir la clave pública la primera vez que lo uséis, para hacerlo se tiene que ejecutar este comando:
  #apt-key adv --keyserver pgp.mit.edu --recv-keys 2E484DAB
  # Algunas veces este "keyserver" no responde, así que si da algun otro error, probad con este otro:
  #apt-key adv --keyserver pgp.rediris.es --recv-keys 2E484DAB
  apt-key adv --keyserver pgp.mit.edu --recv-keys 2E484DAB || apt-key adv --keyserver pgp.rediris.es --recv-keys 2E484DAB
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
  # Extra packages
  apt-get -y install ifupdown locales libui-dialog-perl dialog isc-dhcp-client netbase net-tools iproute openssh-server w3m links2
  # BEGIN generate random hostname for: tahoe, tinc
  apt-get install pwgen
  randhostname=`pwgen -1`
  # END   generate random hostname for: tahoe, tinc
  # BEGIN gcodis-tahoe-client
  su gcodis -c "tahoe create-node -i pb://cporo6rrozvkzu5ux6qkzdt5pqbynvkb@10.139.40.59:60730/introducer -n $randhostname"
  # END   gcodis-tahoe-client
  # END   some tools
  # BEGIN Autostart services
  # delete existing /etc/rc.local
  echo "" > /etc/rc.local
  echo 'su testuser -c "tahoe start"' >> /etc/rc.local
  echo "exit 0" >> /etc/rc.local
  # END   Autostart services
  # Start now the services without reboot
  su testuser -c "tahoe start"
  # Info
  echo "* Generic user: 'gcodis' user created, password locked for security reasons, but can log using SSH (keys) or similar, the user can run Guifi-Community-Distro programs. You don't need to change or assign password to the 'gcodis' user. Assign a password if you want with 'passwd gcodis'. If you installed gcodis previously in this system, you can disable or delete the previous versions user 'testuser' doing 'userdel testuser', we don't use the user 'testuser' anymore."
  echo "* Tahoe-LAFS public guifi.net GRID: You can see your Tahoe-LAFS connections with a web browser going to your local address 127.0.0.1:3456, try now with the command 'w3m http://127.0.0.1:3456' use 'q' key to exit the text browser."
  echo "* The Guifi-Community-Distro has been deployed."
  #### gcodis END   ####
