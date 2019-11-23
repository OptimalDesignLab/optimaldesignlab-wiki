# Use MFEM on SCOREC

This provides a guide to build/use MFEM on SCOREC systems. The `MFEM` is built with following options irrespective of whether you use `PUMI` or not,

``` MFEM_USE_MPI=YES \
    MFEM_USE_PETSC=YES \
    MFEM_USE_LAPACK=YES \
    MFEM_USE_PUMI=YES (if using `PUMI`)
```

## Already built MFEM

To use already built MFEM on SCOREC, add following to your `.bash_rc/.bash_profile` file.

```if using PUMI with MFEM
 export MFEM_DIR=/lore/kaurs3/ODL_common/mfem_build/install_mfem_pumi
 else
 export MFEM_DIR=/lore/kaurs3/ODL_common/mfem_build/install_mfem
```

 **Note:** It is safe to load following modules before you start using MFEM.

```module load gcc/7.3.0-bt47fwr\
   mpich/3.2.1-niuhmad \
   hypre/2.15.1-int32-uhae7i4 \
   petsc/3.11.0-int32-hdf5+ftn-real-c-264efxj \
   openblas/0.3.5-7miavkp \
   pumi/develop-int32-us33lls (if using `PUMI`)
```

I suggest to add above to your `.bash_rc/.bash_profile` file so that they need not to be loaded manually everytime.

**Note:** The `PETSC` and `hypre` module you use should be compatible to each other, i.e. if using `int32 hypre` use `int32 PETSC`. In fact, this applies to every module you use.

## Build MFEM on SCOREC

In case of building `MFEM` on your `SCOREC` directory:

* ```git clone https://github.com/mfem/mfem.git```
* make an empty directory, say `mfem_build`

* ```if using PUMI with MFEM
  download the configuration file [config_mfem.sh](config_mfem.sh)
  else
  download [config_mfem_pumi.sh](config_mfem_pumi.sh)
  ```

* change the `install path` in the configuration file to your `mfem_build` directory and do `module load cmake`.
* source the given configuration file accordingly. Please see [this](overview.md) for details on installing `mfem`.

**Final Note:** All the `notes` given above are from experience, they can be true/false in different situations.
