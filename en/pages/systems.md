# Scorec

Scorect has a number of workstations as well as a small cluster. The workstations are for developing software (ie. writing new code,
running short tests).
The cluster is for running longer simulations.
If more compute resourcers are required, see the `CCI` section.

Scorec is currently transitioning the workstations and cluster from (old) Debian 6 to (new) Red Hat 7 (RHEL7).
Both system use the `module` system to manage software, see [here](https://en.wikipedia.org/wiki/Environment_Modules_(software)) for more information.
The Debian 6 and RHEL7 systems use different module systems and software compiled on one system will not run on the other.
The RHEL7 system uses the [lmod](https://lmod.readthedocs.io/en/latest/) implementation of modules.

The remainder of this section will describe the RHEL7 system, with only brief mentions of the Debian 6 system.
The Scorec wiki has more information on this [page](https://wiki.scorec.rpi.edu/wiki/Red_Hat_Environment).

It is recommended to add the following to your `~/.bash_profile`

```
if [ ! -f /etc/redhat-release ];
then  # debian 6
  source /usr/local/etc/bash_profile
  export MODULEPATH="/users/creanj/ODL_common/modulefiles:$MODULEPATH"
  module load cmake
  module load git/2.1.0
else  # RHEL7
  #setup lmod
  export PATH=/usr/share/lmod/lmod/libexec:$PATH
  #setup spack modules
  unset MODULEPATH
  module use /opt/scorec/spack/lmod/linux-rhel7-x86_64/Core/
  module use /opt/scorec/modules
fi

```

On the RHEL7 system, this lab has space on the shared file system for building software that will be used by all members of the lab.
Software should be built in `/opt/scorec/ODL_common` and lmod modulefiles should be placed in `/opt/scorec/modules/ODL_common`.
See the `README`s in those directories for more information about the organizational structure.
All members of the lab should have read permissions for those directories, although not everyone has write
permissions.
If you need write permissions, email the Scorec systems administration.
Only software used by several members of the lab should be installed here.
 Software used by only one person should be built in your home directory.

After adding the above code to your `~/.bash_profile`, and logging out and logging in again, examine the output of 

```
  module avail
```

If your system is properly configured, you should see modules listed suchas `ODL_common/xyz`, where `xyz` is the name of the module.

For temporary compatability with the RHEL7 systems, a few modules are available on the Debian 6 system in `/users/creanj/ODL_common/modulefiles`,
which is added to the `MODULEPATH` environment variable above.
On a Debian 6 machine, examine the output of `module avail` and look for modules of the form `ODL_common/xyz`.
Not all the same software is available on the Debian 6 systems.

Software should generally be compiled using GCC 7.3.0 and MPICH 3.2.1 on the RHEL7 systems.  Look through the list of available modules for other build tools such as CMake, m4, etc.

# CCI

The CCI has larger compute systems that Scorec, and is useful for running
larger jobs or many jobs simultaneously.

Important links:

 * CCI [Queue](https://secure.cci.rpi.edu/): shows the current job queue for the various compute systems
 * CCI [Wiki](https://secure.cci.rpi.edu/wiki/index.php?title=CCI_Wiki): details the compute systems and software available system-wide

Software used by several members of the lab should be built in `~/barn-shared`.
See the `READ_THIS_FIRST` file for details on the organizational structure.
Software used by a single person should be built in `~/barn`.
The module system is used to manage different versions of software
The following should be added to your `~/.bashrc` to use the modules for software built in `~/barn-shared`:

```
hname=`hostname`
if [[ $hname == "drp"* ]]; then
  export MODULEPATH=~/barn-shared/modulefiles_drp:$MODULEPATH
  export JULIA_PKGDIR=$HOME/barn/drp
fi

if [[ $hname == "bgrs"* ]]; then
  export MODULEPATH=~/barn-shared/modulefiles_bgrs:$MODULEPATH
  export JULIA_PKGDIR=$HOME/barn/bgrs
fi

if [[ $hname == "q"* ]]; then
  export MODULEPATH=~/barn-shared/modulefiles_q:$MODULEPATH
  export JULIA_PKGDIR=$HOME/barn/drp
fi
```


