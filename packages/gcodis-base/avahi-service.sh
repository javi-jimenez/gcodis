#!/bin/sh
# gcodis-base: /etc/gcodis/gcodis-base/avahi-service.sh

# creating a permanent avahi service
avahi_permanent_service () {

[ $# != 4 ] && echo "Usage: $0 <name> <type> <port> <txt>\nCreates a permanent service for Avahi." && exit 1

name="$1"
type="$2"
port="$3"
txt="$4"

cat > /etc/avahi/services/$name.service << EOF
<?xml version="1.0" standalone='no'?><!--*-nxml-*-->
<!DOCTYPE service-group SYSTEM "avahi-service.dtd">

<service-group>
  <name replace-wildcards="yes">%h</name>

  <service>
    <type>$type</type>
    <port>$port</port>
    <txt-record>$txt</txt-record>
  </service>
</service-group>
EOF

}

$*
