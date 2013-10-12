Guifi-Community-Distro (gcodis)
===============================

Guifi-Community-Distro

Project about building a guifi.net Community Software Distribution with automated services.

The project uses:

- a standard Debian GNU/Linux software distribution
- the guifi.net software distribution
- software additions from different parts

Now we use a manually created Wheezy distro from a Squeeze with the required software installed. And the patches are applied using experiments. We use the Community-Lab testbed from the CONFINE project, with a Wheezy.tgz template and an experiment file to run the Guifi-Community-Distro.

The project is related to the Confine and Clommunity projects.

Objective
---------

A first objective is to convert a Debian GNU/Linux software distribution in a software distribution to be used by the guifi.net community and by all in general, and then provide scripts to configure the system automatically using Avahi as a base for publishing and sharing services; a service can be Tahoe-LAFS, a distributed file system.

Services
--------

Apart from the standard services, initially the project offers two services:

- Avahi
- Tahoe-LAFS

**The project is based on Avahi.**

Install options
---------------

The install options for gcodis are:

- `gcodis-create.sh` script: creates a Debian Wheezy debootstrap, copies it to a LXC container, and configures the container. Useful to deploy a gcodis distro inside OpenWrt or some other generic LXC container.
- `gcodis-create.sh install_gcodis`: if you copy the script to an existing Debian installation and run the said command, it converts the local Debian installation into a gcodis distro. Useful for an existing Debian installation. If the original distro is Debian Squeeze, the script converts it into a Wheezy, if it's already a Wheezy it's ok. Later installs the distro in the local Debian Wheezy installation.
- Debian package: *experimental*. Sources available in the 'package' directory to generate the package. To be used in the project Debian packages repositories when available. This will be the next method for the installation process.
- `deploy_to_lxc` link to `gcodis-create.sh`: reuses a previously created bootstrap as for example with the first step of this list, and do the rest of steps as `gcodis-create.sh` does avoiding the need of creating a new debootstrap.

Cloning LXC containers
----------------------

For cloning LXC containers use the command: `lxc-clone -o gcodis-debug -n gcodis-newcontainer`, which clones the existing LXC container `gcodis-debug` to a new container with the name `gcodis-newcontainer`.

Scripts
-------

(for automation)

Initial revision in Bash to be ported to Chef to open collaboration with an standard system.

Automation
----------

Automatically install a Debian, apply scripts and plug in to the Community Network a new auto-configuring node publishing basic services for all.

Requirements
------------

The project requires:
- Debian GNU/Linux (tested on unstable) or OpenWrt. Perhaps Ubuntu or Debian derivatives.
- OpenWrt requires the trunk sources. For LXC and debootstrap.
- Security: sources from Github need SSL and validate the Github certificate. TODO: http://wiki.openwrt.org/doc/howto/wget-ssl-certs . We use *--no-check-certificate* for wget, Github redirects to HTTPS.
- root permissions. Mainly to install packages and do chroot. If you have installed the requirements could be possible to generate
- *wget* with SSL support. In OpenWrt you have to install: *opkg install wget*, by default *wget* is without SSL support.
- *ar* from the *binutils* package.
- *perl* for debootstrap *pkgdetails*.
- *debootstrap*, which can be installed previously. If the program isn't installable directly the install scripts download a version from Debian (ARCH=all) and install it system-wide.
- *sha1sum* for debootstrap if installed from outside the system (the system is different to Debian or OpenWrt).
- If you generate LXC containers AND ONLY IF you plan to run the container you need the LXC utilities. The script to run the container is *lxc-start* usually in the *lxc* package in Debian or *lxc-start* package in OpenWrt.

Build Guifi-Community-Distro
----------------------------

You need root permissions.

You can work with two directories: *./gcodis.git*, with a clone of this git repository (optional) and */debootstrap-i386-wheezy-rootfs* (configurable) where the debootstrap is created, ready to be deployed to LXC or simply converted directly into the Guifi-Community-Distro.

To build the Guifi-Community-Distro you can clone the repository, copy or fetch directly the script, cd into the cloned directory (if cloned) and run the command: **sudo sh gcodis-create.sh**

Sharing the build script
------------------------

You can share the script to easily build the Guifi-Community-Distro.

You can share too the url: https://raw.github.com/javi-jimenez/gcodis/master/gcodis-create.sh to download the script.

To automate the task, you can do or share the next command line: 

*wget http://raw.github.com/javi-jimenez/gcodis/master/gcodis-create.sh ; sh gcodis-create.sh* 

For OpenWrt use:

*wget --no-check-certificate http://raw.github.com/javi-jimenez/gcodis/master/gcodis-create.sh ; sh gcodis-create.sh* 

Or install manually and use the certificate requirements.

It generates a portable chroot environment with the *debootstrap* tool.

After running the main task, you can deploy it in some other flavours as LXC using the generated debootstrap directory.

You can share the commands in the next section to automatically build the debootstrap, convert to LXC and test the container in your system.

Deploy debootstrap to a LXC container
-------------------------------------

After generating the debootstrap, and if run with the default no parameters, the script automates the process and convert (copies) it to LXC and run the LXC container. The created chroot with debootstrap is untouched and can be reused to deploy into other environments or into LXC again.

From scratch
------------

This is an exercise of import and organize some scripts, patches and experiment files used in previous deployments of prior gcodis versions deployed at the Community-Lab Controller, a testbed of the CONFINE project.

System Administration tools
---------------------------

After the organization and migration of the original bash scripts to this git repository, perhaps it's a good idea to work with tools for system administration as:

- Chef, a proposal from the project participants to join efforts in the system administration to create recipes and cookbooks.

- Vagrant, a useful tool to deploy virtual machines, which can be used perhaps to *pack* the created gcodis chroot environment in virtual environments as LXC (*vagrant-lxc* project) or VirtualBox.

Both tools can be used to create a basic and portable chroot environment and later pack it for use in virtual environments. Avoiding the need to rewrite particular use cases in the installation and deployment and winning an abstraction layer which is useful to improve the genericity across the original installation host systems in which the scripts are going to run. A final objective is, for example, downloading and using an initial simple script, to generate the entire distribution and deploy it as a template for the Community-Lab project automatically from the downloaded script.

- *lxc-setup-root* can be used to create a *LXC* chroot environment. Then *lxc-setup-container* can be used to create the container itself for a *chroot* environment. As we use *debootstrap* to create the chroot environment, we can later use the tools *lxc-setup-container* to add our created container to the LXC standard list of containers. But this tools are for Ubuntu only ( http://sosedoff.com/2013/02/11/lightweight-virtualization-with-lxc.html ).

How to use the Guifi-Community-Distro and What to do
----------------------------------------------------

When you have it installed and running, you can do what you usually do with Avahi and some Tahoe related tasks:
- Publish and browse published services.
- Publish and access to the Tahoe Introducer service.

Related to Tahoe you can do what you usually do with Tahoe and using it with Avahi:
- Create a Client node, (optionally a public Gateway or included in the Client), an Introducer and Storage servers.
- Connect to an Introducer published using Avahi.

If you configure a Confine/Clommunity node for guifi.net, you have pre-configured the distro sources list for guinux to allow using the guifi.net web interface, to add the Confine/Clommunity node. If you don't configure the node in the web, you can configure guinux using *id=0*.

The project is based on Avahi.

### Local network environment

This is the basic test environment.

You can deploy *n* installations of this project connected using a LAN to test the basic functionality of the project.

#### Community-Lab Use Case: Simulating a LAN in a Research Device

If you deploy the system using only one Research Device (RD) you can create *n* Slices with only one Sliver in which is installed a copy of this project; you get a LAN connection between nodes. 

You can do variations of this basic method. You have to take into account that you have to create a LAN to allow multicast packets get to all the nodes participating in the experiment. Multicast packets usually are stopped at router boundaries.

### Choose Introducer algorithm (WIP)

This is a Work In Progress (WIP).

Which Introducer to choose between the existing Introducers in the network?
- Basic approach: We create a local Introducer to the Client.

### Choose Storage algorithm (WIP)

Which Storage servers to connect to?
- Basic approach: RAID1 local to the user: One local, one random.

### Beyond LAN (WIP)

This is a Work In Progress (WIP). That is another project needed for this one.

To be used in a network with routers between multicast packets.

TODO
----

  - Import patch for Avahi config files.
  - Import tahoe service definition file for Avahi.
  - Complete and import the tahoe scripts. Needed node distribution.
  - Generate a compatible template to be uploaded to the Controller and replace the existing gcodis one.
  - Study: Use Vagrant (*vagrant-lxc*).
  - Study: Recipes and cookbook for Chef system administration.
  - Request: Participants in the Community Cloud project or Community integrate their software.
  - Write proposal for the network topology and routing for the services.
  - Call to internal functions directly creating named links to the script.
  - Indicate by parameter a personalized script to run inside the deployed environment (apart from the hardcoded one (for gcodis) to be compact at first).

Changelog
---------

- 2013-10-12
  - v0.4.0
  - Work on some bugs
  - Tested on Ubuntu: gcodis-create.sh and deploy_to_lxc

- 2013-09-27
  - v0.3.0

- 2013-09-26
  - Reorganize the code
  - Correct some bugs
  - Test on Debian unstable. Clone the repo, run the script gcodis-create.sh and later the link deploy_to_lxc to generate the distro.
  - Create the 'package' directory for generating a package to install the distro in an existing Debian, Wheezy at least, installation.

- 2013-09-04
  - v0.2.0

- 2013-09-03
  - Reorganize the project in one only script *gcodis-create.sh*.
  - Tested and running on Debian/GNU Linux unstable. debootstrap generation, deploy to LXC and run LXC.
  - For OpenWrt the LXC container is generated, but we're in the stage of running successfully the command *lxc-start -n gcodis-debug*. The script can be used in OpenWrt trunk, which provides most lxc commands (except lxc-create) and provides too the debootstrap command

- 2013-08-30
  - Commit the deploy from debootstrap to a LXC container. You can now test the distro inside a LXC container.

- 2013-08-27
  - Added the section "How to use and what to do". Referencing the WIP "Beyond LAN" project.
  - Remark WIP algorithms. Solved with the Basic Approach.

- 2013-08-22
  - pushed first running version. Now you can generate the base distro with the command: *sudo build.sh*
  - the script *fetch-and-build-gcodis.sh* is useful to share it independently and automatically clone this repository and generate the distro. See **Sharing the build script** section.
  - Sorted TODO and organize in versions.
  - Explanation about the files and directories used.

- 2013
  - Deploy in a LXC container.
  - Manually created template for Community-Lab from an existing debian02.tgz template, with running Avahi and Tahoe, and guinux sources.list; including some patches. Uploaded template to Controller, latest version is v1.1. The template is complemented with experiment files.
  - Generate new distro from scratch.
  - Convert the generated debootstrap to a LXC container and deploy it. Prepared to be run after deploying it.
  - Build the distro entirely from the ground. The first release is "gcodis from scratch" using bash scripts.
  - To join the template and the experiment data used in the Community-Lab testbed. There were two files: template and experiment data.


Source code
-----------

The code is provided as the code used to generate and test the distribution for a project.

Use the code at your own risk, better if you want to test it inside an isolated environment, to generate the software distribution, the project requires root permissions.

Some code is from some places, indicated in the proper project source files. We use mainly as base the LXC project code to convert from debootstrap to a LXC container. I had to split the lxc-debian template into some functions copying it in this project code.

Github repository: git clone https://github.com/javi-jimenez/gcodis.git
