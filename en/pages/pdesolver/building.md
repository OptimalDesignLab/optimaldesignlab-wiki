# Building PDESolver on a fresh machine

Fresh means that you have a non-existent or empty `JULIA_PKGDIR` (usually `~/.julia/v0.6`) directory.

Launch Julia, and at the prompt:
```
julia> Pkg.clone("git@github.com:OptimalDesignLab/PDESolver.jl.git")
```
Then exit Julia.

Navigate to `$JULIA_PKGDIR/PDESolver/deps`, then run
```
julia build.jl
```
It'll take a few minutes while it downloads and builds all dependencies.

Before running cases, you must source some PUMI things. 
Go to `$JULIA_PKGDIR/PumiInterface/src` and run
```
source use_julialib.sh
```

You should be ready to run PDESolver cases.

# Building on Scorec RHEL7 Workstations

The general installation instructions are [here](http://www.optimaldesignlab.com/PDESolver.jl/build.html).

Before installing, run the shell commands

```
module load cmake
module load ODL_common/pdesolver_deps
```

The second command loads the proper compilers, MPI, PUMI, and PETSc, and Julia.
Then cd into `JULIA_PKGDIR` (or `~/.julia/v0.6/` if `JULIA_PKGDIR` is not set), and run the shell commands:

```
  git clone https://github.com/OptimalDesignLab/PDESolver.jl.git PDESolver
  cd ./PDESolver
  git checkout branchname
  cd ..
  julia -e 'Pkg.resolve()'
  julia -e 'Pkg.build()'
```

This will download and install PDESolver and all of its dependencies.
Lines 2-4 are only required if you wish to build a different branch than
`master.  Note that different branches might require different versions
of dependencies, so you must checkout the branch before installing.
The `Pkg.resolve()` step installs all dependencies that are registered
package, and usually takes around 2 minutes.
The `Pkg.build()` step installs all dependencies that are
not registered packages (or dependencies that require patches), and
takes 10 to 15 minutes.  This process takes approximately 500 MB of disk
space.


## Debian 6 and RHEL7 Compatability

It *may* be possible to run the same Julia packages for both the Debian 6
and RHEL7 systems, although this is not supported (note that user's
home directories are shared between the two system, so if you build
PDESolver on one system the files will be visible on the other system,
but may not run correctly).  The best thing to do is use either
the RHEL7 or Debian 6 machines exclusively.  If you must switch back
and forth for some reason, here are some hints on what to do (keeping in
mind that this is not supported, is not tested, and may break at any time):

 * Any Julia package that has binary dependencies (ie. depends on a C/C++/Fortran shared library) will need to be rebuilt each time you switch from one system to another.  Currently this include:

  * MPI
  * PumiInterface
  * PETSc2

  * The module `ODL_common/pdesolver_deps` is available on the Debian 6 systems, but does not load all the same software as on RHEL7.  In particular it does not load PETsc.  The PETSc package should attempt to install PETSc if it is not present.  This will take additional time and disk space




