# Compiling MISO

To build `MISO`, the MISO directory should be in the same directory as the other MISO build dependencies which includes `mfem`, `Adept`, and `core`. This can be confirmed by using the command ```ls /path/to/packages/``` to list all files and subdirectories in that directory. The output of this command should include mfem, Adept, and core, among others that may be present. 

**Note:** `/path/to/packages/` is used to describe the root directory/folder containing these packages. For me, `/path/to/packages/` corresponds to `/lore/idrish/Developer/motor/` which is what I will be using for the remainder of this documentation.

**Note:** `Adept`, `mfem`, and `core` must be built before building MISO.

## Clone MISO repository from GitHub
Navigate to the packages directory then clone MISO from GitHub using these commands
```
cd /lore/idrish/Developer/motor/
git clone https://github.com/OptimalDesignLab/MISO.git
```
Depending on the MISO branch you will be working with, checkout the appropriate commit hash. See example below
```
cd /lore/idrish/Developer/motor/MISO
git checkout cd7e53714ae3d3c6d4256d66a2ee67562224f47e
git pull
```
`git pull` ensures you are up to date with the branch you switched to.

## Load the required modules module

Ensure you have your python environment enabled and load the following modules. Adding to library and shared library paths may not be necessary but this helped me fixed some problems. The specific paths to add may differ depending on versions and updates made on SCOREC. These packages may as well be installed on local machines.

```bash
module use /opt/scorec/spack/rhel9/v0201_4/lmod/linux-rhel9-x86_64/Core
module load gcc/12.3.0-iil3lno
module load python/3.10.10-fy3aixq 
module load py-pip py-wheel py-setuptools 
module load mpich metis cmake 
module load doxygen swig hypre/2.28.0-dljbagf
module load netlib-lapack openblas 
module load gdb/13.1-z4rrapk

# Adding to library path
export LIBRARY_PATH=/opt/scorec/spack/rhel9/v0201_4/install/linux-rhel9-x86_64/gcc-12.3.0/netlib-lapack-3.11.0-b22mgwgxwwyajomdudwwbhewg6ulam7m/lib64/:$LIBRARY_PATH
export LIBRARY_PATH=/opt/scorec/spack/rhel9/v0201_4/install/linux-rhel9-x86_64/gcc-12.3.0/openblas-0.3.23-wqm7iudhdwsidvto7nddxjyi7ow2lhwy/lib/:$LIBRARY_PATH
export LIBRARY_PATH=/opt/scorec/spack/rhel9/v0201_4/install/linux-rhel9-x86_64/gcc-12.3.0/hypre-2.28.0-dljbagffd2rfhfkwt74jbi3q66maayyo/lib/:$LIBRARY_PATH

# Adding to shared library path
export LD_LIBRARY_PATH=$VIRTUAL_ENV/lib
export LD_LIBRARY_PATH=/lore/idrish/Developer/motor/OpenCASCADE-7.4.1/lib/:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=/lore/idrish/Developer/motor/EngSketchPad/lib/:$LD_LIBRARY_PATH 
export LD_LIBRARY_PATH=/opt/scorec/spack/rhel9/v0201_4/install/linux-rhel9-x86_64/gcc-12.3.0/hypre-2.28.0-dljbagffd2rfhfkwt74jbi3q66maayyo/lib/:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=/opt/scorec/spack/rhel9/v0201_4/install/linux-rhel9-x86_64/gcc-12.3.0/metis-5.1.0-65szzoyrtgauis34eop3w5zu6v6uarer/lib:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=/opt/scorec/spack/rhel9/v0201_4/install/linux-rhel9-x86_64/gcc-12.3.0/mpich-4.1.1-xpoyz4tqgfxtrm6m7qq67q4ccp5pnlre/lib/:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=/opt/scorec/spack/rhel9/v0201_4/install/linux-rhel9-x86_64/gcc-12.3.0/openblas-0.3.23-wqm7iudhdwsidvto7nddxjyi7ow2lhwy/lib/:$LD_LIBRARY_PATH


```

You will need to load all these each time you open a new terminal. Hence, it is strongly adviced to add these to a `.sh` file and `source` each time a new terminal is launched.

## Build MISO
Navigate to MISO directory, create build subdirectory, then add/create a config file for building MISO

```
cd /lore/idrish/Developer/motor/
cd MISO
mkdir build

```

Dowload MISO configuration file [config_miso.sh](config_miso.sh) and move it to `/lore/idrish/Developer/motor/MISO/build/`. The default build type is "Release" (`-DCMAKE_BUILD_TYPE=Release`) which run much faster than "Debug". The option should be chamged from `Release` to `Debug` if MISO needs to be compiled with Debug flag. **Note:** The config file is also set to locate adept-install, mfem, and core in the same directory as MISO (i.e /lore/idrish/Developer/motor/)

Finally, build or compile MISO using the commands below:

```bash
cd /lore/idrish/Developer/motor/MISO/build/
source config_miso.sh
make -j 4
make install
```

These commands configure `MISO` using the configuration seetings in the config file and compile `MISO` in parrallel using 4 processors. This is faster than compiling in series with just `make`. 

*This page is being worked on...*