# Getting PDESolver working on DRP

Before you start, make sure your module environment is set up properly.
Navigate [here](../systems.md#CCI) and follow the instructions.


## Recommended method

Navigate [here](http://www.optimaldesignlab.com/PDESolver.jl/deps_readme.html#Offline-Installation-1) and follow the instructions.
This is Jared's recommended way of getting PDESolver running on DRP, and one would be wise to follow his instructions.

## Alternate method

This method is only if you know what you're doing. It could be helpful if you're flipping between versions of packages or git branches in repositories.

NOTE: all of the following commands and shell scripts are written for my account. You *will* have to make changes - at minimum, you'll have to change the username from `ODLCasan` to whatever your CCI username is.

First, get PDESolver working on SCOREC systems. Run tests to make sure.
You'll need these packages to be working: 
* `MPI`
* `PumiInterface`
* `SummationByParts`
* `ODLCommonTools`
* `PDESolver`
* (and the dependencies of all of these)

Once these are all working on SCOREC, tar each of them up and copy each over to DRP into your `$JULIA_PKGDIR`. For example, on SCOREC:
```
cd ~/.julia/v0.6
tar cvf ODLCommonTools.tar ODLCommonTools/
scp ODLCommonTools.tar ODLCasan@lp01.ccni.rpi.edu:/gpfs/u/barn/ODLC/ODLCasan/drp/v0.6/
```

ssh over to DRP, and unpack all of the tarballs in your `$JULIA_PKGDIR`. For example,
``` 
cd ~/barn/drp/v0.6
tar xvf ODLCommonTools.tar
```
It's ok to delete these tarballs now, both on SCOREC and DRP, if you'd like.

Here's what the contents of my `$JULIA_PKGDIR` looks like on DRP:
```
[ODLCasan@drpfen01 v0.6]$ ls -1
ArrayViews
BinDeps
Compat
FactCheck
META_BRANCH
METADATA
MPI
ODLCommonTools
PDESolver
PETSc2
PkgFix
PumiInterface
REQUIRE
SHA
SummationByParts
URIParser
```

Next, all of these will have to be built. To do this, you must perform a step before compilation. Create a shell script with these contents:
```
#!/bin/bash

# set environmental variables to force cmake to use the current set of compilers

export FC=`which gfortran`
export CC=`which gcc`
export CXX=`which g++`
```

Jared and I named this `force_compilers.sh`, so source it with:
```
source force_compilers.sh
```

Load the necessary modules:
```
module load pdesolver/new_0.6
```

The output of `module list` should now look something like this:
```
[ODLCasan@drpfen01 ~]$ module list

Currently Loaded Modules:
  1) gcc/5.4.0_1 (S)   3) openmpi/2.0.2_1 (S)   5) parmetis/4.0.3   7) cmake/3.3.2 (S)   9) openblas/current    11) pdesolver/new_0.6
  2) julia/0.6         4) metis/5.1.0           6) zoltan/3.8       8) pumi/core        10) petsc/gnu/3.7.6_64

  Where:
   S:  Stable
```

Now, enter the julia REPL by running `julia`. In the REPL, run:
```
Pkg.build("ODLCommonTools")
Pkg.build("SummationByParts")
Pkg.build("MPI")
Pkg.build("PumiInterface")
Pkg.build("PDESolver")
```

You should be ok to run a PDESolver case.

# Example of how to run a PDESolver case on DRP

You'll need a suitable input file for PDESolver, and two shell scripts for running tasks on SLURM on DRP.

I'll call the two shell scripts `job.sh` and `slurm_job.sh`.
Here's the contents of `job.sh`:
```
#!/bin/bash
module load pdesolver/new_0.6

start_dir=`pwd`

export JULIA_PKGDIR="/gpfs/u/home/ODLC/ODLCasan/barn/drp/"

TSTAMP=$(date +%Y%m%d-%H%M%S)
cp arg_dict_output.jl "arg_dict_output-${TSTAMP}.jl"

echo "initial ${TSTAMP}" >> ZZ_runtimes.txt

export OPENBLAS_NUM_THREADS=1

mpirun -hostfile hosts.$SLURM_JOB_ID -np $1 --bind-to core julia --handle-signals=no $JULIA_PKGDIR/v0.6/PDESolver/src/solver/euler/startup.jl "input_naca0012_inviscid.jl"

# for restart
# mpirun -hostfile hosts.$SLURM_JOB_ID -np $1 --bind-to core julia $JULIA_PKGDIR/v0.4/PDESolver/src/solver/euler/startup.jl "input_vals_restart"
```
Here's the contents of `slurm_job.sh`:
```
#!/bin/bash

# RUN WITH: sbatch -N 4 --time=02:00:00 slurm_job.sh

# NOTE: make tasks divided by nodes equal to 16.
# nodes=1
# tasks=16
nodes=4
tasks=64

# WORKS 20190210 - this is for normal partition
srun -t 06:00:00 -N $nodes -n $tasks hostname > hosts.$SLURM_JOB_ID

# WORKS 20190210 - this is for debug partition
# run with:
#   sbatch -p debug -N 1 --time=01:00:00 slurm_job.sh
# srun -p debug -t 01:00:00 -N $nodes -n $tasks hostname > hosts.$SLURM_JOB_ID

./job.sh  $tasks
```
You'll probably have to make these executable with `chmod u+x job.sh slurm_job.sh`.

Now, with a suitably partitioned mesh, run it with:
```
sbatch -N 4 --time=06:00:00 slurm_job.sh
```

If you wish to run on the debug partition, you'll have to change down to 1 node and 16 tasks, and limit yourself to 1 hour, as you can see in the comments in `slurm_job.sh`. Run this case with:
```
sbatch -p debug -N 1 --time=01:00:00 slurm_job.sh
```




