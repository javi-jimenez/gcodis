#!/bin/sh
# Generate packages from source, usually in $git/packages/

echo "First check the requirements, we need to build the gcodis packages a Debian (or related system) and the next packages: dpkg-dev debhelper. Press [Enter] to continue or [CTRL+C] if not."
read continue

# Packages to compile recopilation
for cloud in `find conf/* -maxdepth 0 -type d`
do 
    for pkg in `cat $cloud/*.packages | sort -u`
    do
	echo $pkg
	# Copy package to build
	mkdir -p build/packages/$pkg/ ; cp -dpa packages/$pkg/ build/packages/
    done
done

# Build copied packages
for build_pkg in `find build/packages/* -maxdepth 0 -type d`
do
    cd $build_pkg/ ; dpkg-buildpackage -us -uc ; cd -
done

echo "Generated packages are in the build/packages/ directory."
