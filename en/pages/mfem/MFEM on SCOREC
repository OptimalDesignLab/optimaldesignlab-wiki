
# Build MFEM on SCOREC
 
This is a brief tutorial on building MFEM together with GLVis (a visualization software for MFEM) on SCOREC system.
The first step is to download MFEM from [here](https://bit.ly/mfem-3-4).Then download GLVis from [here](https://bit.ly/glvis-3-4). It is desirable to download them in the same working directory.

The second step is to build serial version of MFEM:
```bash
tar -zxvf mfem-3.4.tgz
cd mfem-3.4
make serial -j
```

Then build GLVis:
```bash
tar -zxvf glvis-3.4.tgz
cd glvis-3.4
make MFEM_DIR=../mfem-3.4 -j
```
In order to build the parallel version of MFEM, it is necessary to load several modules,in which metis 5 with 32 bits version is necessary otherwise there will be compile errors.
```bash
module load gcc/*  (gcc/7.3.0 is recommdended)
module load mpich/* (mpich/3.2.1 is recommended)
module load hypre/2.14.0-int64*
module load metis/5.1.0-int32*
```
First get the METIS5 directory:
```bash
cd mfem-3.4
echo $MENTIS_ROOT
```
With the `MFEM_USE_METIS_5` and `METIS_DIR` options, build the parallel version of MFEM:
```bash
make parallel -j MFEM_USE_METIS_5=YES MENTIS_DIR=@MENTIS5_DIR@
```
## Build and run parallel examples
To build the parallel example codes, type `make` in MFEM's examples directory:
```bash
cd mfem-3.4/examples
make
```
Before run the parallel examples, please open another terminal and run `glvis` and visualization will automatically show up when simulation is done:
```bash
cd glvis-3.4
./glvis
```
Run examples as follows:
```bash
mpirun -np 16 -m ../data/star.mesh
```
More details about the examples and different meshes can be found [here ](https://mfem.org/parallel-tutorial/).
