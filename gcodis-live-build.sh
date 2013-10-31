#!/bin/sh
# Generate ISO-Hybrid images and local LXC deployment of the
# conf/*/server and conf/*/client elements, one for each

echo "First check the requirements, we need to build gcodis with 'live-build' a Debian (or related system) and the next packages: live-build. Press [Enter] to continue or [CTRL+C] if not."
read continue

if [ -d "build/" ] ; then
  # clean build?
  echo "Clean build/ dirctory?"
  rm -r -i build/
else
  mkdir build/
fi

  ./gen_pkgs.sh \
&& \
  ./live-build.sh

echo "Build using 'live-build' complete."
echo "If you used the default configuration, built packages are in 'build/gcodisdefault/live-build-gcodisdefault-client/' and 'build/gcodisdefault/live-build-gcodisdefault-server/'"
echo "Now you can do: ./deploy_to_lxc_clean gcserver build/gcodisdefault/live-build-gcodisdefault-server/chroot /var/lib/lxc/gcserver AND/OR ./deploy_to_lxc_clean gcclient build/gcodisdefault/live-build-gcodisdefault-client/chroot /var/lib/lxc/gcclient/ to deploy the example config to LXC and do tests."
