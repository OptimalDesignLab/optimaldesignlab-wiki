# Julia and MPI

This page describes how to run Julia in parallel using MPI.

## Regular Computers

If you are on a regular computer (ie. not a cluster with a scheduling system),
you can run Julia like any other MPI program:

```julia
  mpirun -np 4 julia /path/to/script
```

## Clusters

On clusters using SLURM to schedule jobs, an example job submission script
`slurn_job.sh` is

```bash
#!/bin/bash                                                                     

nodes=1  # number of requested nodes
tasks=16  # number of requested tasks

# create the hostname file needed by mpirun on some systems
srun -N $nodes -n $tasks hostname > hosts.$SLURM_JOB_ID
./job.sh  $tasks  # the script to run on the compute nodes
```

The `job.sh` script is

```bash
module load julia/0.6  # this both add Julia to the PATH variable and loads
                       # the compilers that Julia was built with (needed because
                       # Julia dynamically links to libcxx)

mpirun -hostfile hosts.$SLURM_JOB_ID -np $1 --bind-to core julia /path/to/script
```

Some systems use `srun` instead of `mpirun`.  Consult the documentation for your
compute system.  The CCI systems now recommend using `srun` rather than `mpirun`,
however there were some problems using `srun` last time I attempted to use it.

The `slurm_job.sh` script can be submitted to `sbatch` (consult the SLURM
documentation or the documentation for the compute system).
