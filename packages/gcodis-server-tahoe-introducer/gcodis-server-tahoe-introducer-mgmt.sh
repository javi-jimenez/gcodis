#!/bin/sh
# Script name: gcodis-server-tahoe-introducer-mgmt.sh
# Package: gcodis-server-tahoe-introducer
# Depends on gcodis-base: /etc/gcodis/gcodis-base/avahi-service.sh
# REST API:
# - configure
# - add
# - delete
# - update
# - publish
# - unpublish
# - usage/help
# - status/info
# Description: Management of the Tahoe Introducer service, 
#   a hub for a Tahoe GRID.

# name of the service, the same name as the init script /etc/init.d/
name="gcodis-server-tahoe-introducer"
# Where the $name config dir resides
tahoe_introducer_config_dir=/home/gcodis/tahoe-introducer/

# Create the introducer.furl file
configure () {
  echo "Creating introducer."
  echo "Creating tahoe-introducer dir."
  # can exist from a previous uninstall with out deleting the dir.
  # When uninstalling (remove) we don't delete the user dir.
  if [ -d "/home/gcodis/tahoe-introducer/" ] ; then
    echo "OK, continue. Previous installation detected, reusing previous '/home/gcodis/tahoe-introducer/' dir."
  else
    su gcodis -c "mkdir $tahoe_introducer_config_dir" || return 1
  fi

  if [ -f "/home/gcodis/tahoe-introducer/introducer.furl" ] ; then
    echo "Previous introducer.furl detected, reusing it."
  else
    echo "Creating introducer itself."
    su gcodis -c "/usr/bin/tahoe create-introducer /home/gcodis/tahoe-introducer/" || return 1
  fi

  # For configuring the service we need to start the service
  # to introducer.furl be created
  # start the service, creates the furl
  echo "# Starting the introducer service as gcodis user."
  /etc/init.d/gcodis-server-tahoe-introducer start || return 1

  # Minor bug, the introducer creation has a little delay
  # when returning from the start creation call
  sleep 6

  echo "# stop the service, because we start it only if required"
  /etc/init.d/gcodis-server-tahoe-introducer stop || return 1

  # We can get the introducer.furl now, it's already configured
  echo "Tahoe introducer.furl is at /home/gcodis/tahoe-introducer/introducer.furl"

  echo "gcodis info: Tahoe Introducer needs to be configured inside the final running system. Configure it again when running the final system to get the correct IP."

}

add () {
  echo "Adding the $name service."
  # First configure the service
  configure || return 1 # Some unexpected error occurred
  # here the service is configured
  # set init scripts to automatically start
  update-rc.d -f $name defaults || return 1
}

delete () {
  echo "Deleting $name service."
  # stop service
  /etc/init.d/$name stop || service $name stop || return 1
  # remove config dir
  # TODO: DEBUG! delete later the -i parameter
  /bin/rm -r -i $tahoe_introducer_config_dir
  # now the service not exists, we have to unpublish it if published
  unpublish || return 1
}

update () {
  echo "Updating $name service."
  # update introducer configuration, perhaps by new IP
  # TODO: delete and add the service
  delete
  add
}

publish () {
  echo "Publishing $name service."
  # part of tahoe-introducer, depends on gcodis-base (username, libs)
  # configurable ? in
  #   /etc/gcodis/gcodis-server-tahoe-introducer/tahoe_user_home ?
  #   /etc/gcodis/gcodis-server-tahoe-introducer/introducer_dir ?
  tahoe_user_home="/home/gcodis/"
  if [ -f "$tahoe_user_home/tahoe-introducer/introducer.furl" ] ; then 
      echo "OK, introducer.furl exists."
  else
      echo "introducer.furl does not exists."
      return 1
  fi
  tahoe_introducer_ip_port=`cat $tahoe_user_home/tahoe-introducer/introducer.furl | cut -f2 -d '@' | cut -f1 -d ','`
  tahoe_introducer_url_1=`cat $tahoe_user_home/tahoe-introducer/introducer.furl | cut -f1 -d '@'`
  tahoe_introducer_url_full="$tahoe_introducer_url_1@$tahoe_introducer_ip_port/introducer"
  # call to gcodis-base function (lib)
  /etc/gcodis/gcodis-base/avahi-service.sh avahi_permanent_service tahoe-introducer _tahoe-introducer._tcp $tahoe_introducer_ip_port $tahoe_introducer_url_full
}

unpublish () {
  echo "Unpublishing $name service."
  # TODO:
  # /etc/gcodis/gcodis-base/avahi-service.sh unpublish tahoe-introducer
  # delete the service config file
  # DEBUG: remove the -i parameter
  /bin/rm -i /etc/avahi/services/tahoe-introducer.service || return 1
}

usage () {
  echo "$name gcodis management script."
  echo "Usage: $0 [OPTION]"
  echo ""
  echo "OPTION:"
  echo "  -a: Add service."
  echo "  -d: Delete service."
  echo "  -u: Update service."
  echo "  -p: Publish service."
  echo "  -n: Unpublish service (not publish)."
  echo "  -i: Info, aliased as Status."
  echo "  -h: Help, aliased as Usage."
}

status () {
  echo "Status of $name."
  # TODO: status info from commandline, parse web page to txt (w3m url | convert-to-txt)
  echo "Go to http://127.0.0.1:3456 to check status"
}

# alias of status
info () {
  status $*
}

help () {
  usage $*
}

$1 $*

