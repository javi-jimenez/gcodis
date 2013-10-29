Guifi-Community-Distro packages and metapackages
================================================

*Experimental, requires Debian Wheezy*

This directory contains the packages and metapackages for the entire Guifi-Community-Distro community-cloud software system.

Metapackages
------------

Description of the metapackages.

- `gcodis`: Installs the entire distribution in a single machine. Depends on (installs): *gcodis-server* and *gcodis-client*.
- `gcodis-base`:   Installs the base system for gcodis. Required by `gcodis-server` and `gcodis-client`.
- `gcodis-server`: Installs all the server packages.
- `gcodis-client`: Installs all the client packages.
- `gcodis-server-tahoe-introducer`: Installs the Tahoe-LAFS Introducer, a service hub to form a GRID with client and storage nodes.

At the moment the nodes are not configured, we plan to do it using a web interface.

Build
-----

If you don't want to sign the packages, you can build the packages with the command:

        dpkg-buildpackage -uc -us

or build all with:

	../gen_pkgs.sh

resulting generation will be in `gcodis.git/build/packages/`

Github repository: http://www.github.com/javi-jimenez/gcodis
Project page: http://clommunity-project.eu

