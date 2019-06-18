# MFEM Overview and Build

The MFEM overview can be found [here](MFEM_Overview.pdf#CCI).

## Build MFEM on SCOREC

This is a brief tutorial on building MFEM with PUMI on SCOREC system. The entire building is about 2GB, so it is recommended to build in `lore` directory.
### 1. Get source code and set up build environment

Go to your home dirctory in `lore` and create a new directory `mfem_develop`, then download `MFEM`, `PUMI` source and `pumi-meshes` as follows:
```bash
cd /lore/yang
mkdir mfem_develop
cd mfem_develop
git clone https://github.com/mfem/mfem.git
git clone https://github.com/SCOREC/core.git
git clone https://github.com/SCOREC/pumi-meshes.git
```
Before building `PUMI` and `MFEM`, we need to load several modules:
```bash
module load cmake \
mpich/3.2.1-niuhmad \
metis/5.1.0-int32-3tycybv \
simmetrix-simmodsuite/11.0-180619-a4mef7a
```
### 2. Build PUMI

First download the configuration file [core-config.sh](core-config.sh#CCI) and put it in `mfem_develop` directory. In `core-config.sh`, change the `DMESHES` to the directory of `pumi-mesh` (In my case it is `/lore/yang/mfem_develop`). Note: The `CMAKE_PREFIX_PATH` (line 2) is pointing to my directory `/lore/yang/build/core-deps`, in which there are the core dependencies required by `PUMI` (ParMetis and Zoltain). You can also copy this dirctory to your own directory and change `CMAKE_PREFIX_PATH` accordingly. Then make a directory `core_build` under `mfem_develop` and source the `core-config.sh` as follows:
```bash
mkdir core_build
cd core_build
source ../core-config.sh ../core on default long off off ON
```
Then install `PUMI` and test it using `ctest`:
```bash
make -j 16
(some output)
make install
(some output)
ctest
(some output)
```
### 3. Build MFEM

Make a directory `mfem_build` under `mfem_develop`. Then download the configuration file [MFEMJessiConfig.sh](MFEMJessiConfig.sh#CCI) under `mfem_develop` directory. In `MFEMJessiConfig.sh`, 1) change the `DPUMI_DIR` to where you build `PUMI` (in my case it is `/lore/(your id)/mfem_develop/core_build/install`), 2) change `DHYPER_DIR` to `/lore/yang/build/hypre-2.11.2/src/hypre`, 3) change `DCMAKE_INSTALL_PREFIX` to directory `mfem_build`. Note: `DHYPRE_DIR` is pointing to my own directory, you can also build it and change the path accordingly. Then configure and build `MFEM` as follows:
```bash
cd mfem_build
source ../MFEMJessiConfig.sh
make -j 16
make install
```

### 4. Build  visualization software GLVIS

Download GLVis from [here](https://bit.ly/glvis-3-4). Build  and run `GLVIS` as follows:
```bash
tar -zxvf glvis-3.4.tgz
cd glvis-3.4
make MFEM_DIR=../mfem_build -j
(some output)
./glvis
```
### 5. Run PUMI mesh samples

I make the pumi mesh samples available in `/lore/yang/mfem_develop/mfem_build/data/pumi`, and please copy it to you own data directory. Then you can run the pumi meshes examples as follows:
```bash
cd /lore/(your id)/mfem_develop/mfem_build/examples/pumi
(serial)
./pumi_ex1 -m ../../data/pumi/serial/Kova.smb -p ../../data/pumi/geom/Kova.smb
(parallel)
mpirun -np 8 ./pumi_ex1p -m ../../data/pumi/parallel/Kova/Kova100k_8.smb -p ../../data/pumi/geom/Kova.dmg
```
If you have another terminal open and running GLVIS, the visualization will show up automatically.
Further work will focus on how to generate geometry and mesh and how to visualize result with paraview.
