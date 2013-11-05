#!/bin/sh
# Script name: gcodis-client-tahoe-mgmt.sh
# Package: gcodis-client-tahoe
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
# Description: Management of the Tahoe Client service, 
#   a client for some Tahoe GRID.

# items needed:
# resource file with introducer list, pairs as: introducer_name introducer_url
# directories, one for each introducer in the resource list

# service_name: name of the service, the same name as the init script /etc/init.d/
service_name="gcodis-client-tahoe"
# resources dir
resources_dir="/home/gcodis/"
# resource file
introducer_list="$resources_dir/introducer.list"
# debug
debug=true

# Work with introducer_url and a name for the resource
# create a dir for the resource introducer
# start/stop with -C dir_name
# store dirnames in resource introducer config file

# internal functions
name_exists () {
  # in: name
  name=$1
  # check if resource name exists
  if [ -f "$introducer_list" ] ; then
    if cat $introducer_list | cut -f1 -d ' ' | grep ^$name$
    then
      return 0
    fi
  fi
  return 1
}

configure () {
  # in: name url
  # empty, nothing to do
  [ $debug ] && echo "Nothing to do"
}

add () {
  [ $# != 2 ] && usage && exit 1
  name=$1
  url=$2
  [ $debug ] && echo "Add"
  # if exists name or url
    # info: update first
    # conflicting values, show
  if ( name_exists $name ) ; then
    echo "$name exists, update it first or choose a new name"
    exit 1
  fi
  echo "More than one name for the same introducer allowed."
  #if [ -f "$introducer_list" ] ; then
  #  if cat $introducer_list | cut -f1 -d ' ' | grep ^$url$
  #  then
  #    echo "$url exists, update it first or choose a new url"
  #    exit 1
  #  fi
  #fi
  # add: name url
  [ $debug ] && echo "Adding '$name $url' to the file '$introducer_list'"
  # Create name dir
  tahoe create-node -i $url -C $resources_dir/$name/
  # add dir to pool start config file
  echo $name $url >> $introducer_list
  # Start as newly created
  auto_start $name
}

auto_start () {
  # in: name
  name=$1
  tahoe start -C $resources_dir/$name/
}

# delete a configured introducer using its name only
delete () {
  [ $debug ] && echo "Delete $1"
  # in: name #url
  name=$1
  #url=$2
  # check if exists: grep name in resources file
    # if not exists, cat resources file (to see existing resources), then exit
  #echo $(name_exists $name)
  if ( name_exists $name )
  then
    # stop dir
    tahoe stop -C $resources_dir/$name
    # delete entry from pool config file
    tmp_file=`mktemp`
    cat $introducer_list | grep -v "^$name " > $tmp_file
    /bin/cp $tmp_file $introducer_list
    # ? delete dir ? !!, better manually, indicate it
    echo "Directory '$resources_dir/$name/' not empty, delete it manually."
  else
    echo "$name not exists, can't delete it."
    exit 1
  fi
}

# change  the line of the resource config file for a name
update () {
  # in: old_name new_name url
  # overwrites line old_name in config file with new_name+url
  # if published: 
    # unpublish old_name
  # publish new_name
  echo "Update"
  echo "Update: Yet not implemented"
}

# adds entry to /etc/avahi/services/resource_name.service
publish () {
  # overwrite publish file
  echo "Publish: this kind of client don't publish services."
}
  
unpublish () {
  # deletes publish file: /etc/avahi/services/resource_name.service
  echo "Unpublish: this kind of client don't publish services."
}

usage () {
  echo "$service_name gcodis management script."
  echo "Usage: $0 [OPTION]"
  echo ""
  echo "OPTION:"
  echo "  add <name> <url>: Add service."
  echo "  delete <name>:    Delete service."
  echo "  update:           Update service."
  echo "  publish:          Publish service."
  echo "  unpublish:        Unpublish service (not publish)."
  echo "  info:             Info, aliased as status."
  echo "  help:             Help, aliased as usage."
  echo ""
  echo "Example: ./gcodis-client-tahoe-mgmt.sh add guifinet-publictest pb://cporo6rrozvkzu5ux6qkzdt5pqbynvkb@10.139.40.59:60730/introducer"
}

help () {
  usage $*
}

status () {
  # query client web interface
  echo "Check http://127.0.0.1:3456 for a Tahoe client status."
  echo "List of configured introducers (name, url):"
  [ -f "$introducer_list" ] && cat $introducer_list
}

info () {
  status $*
}

$*

