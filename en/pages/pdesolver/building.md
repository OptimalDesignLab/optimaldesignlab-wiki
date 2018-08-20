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
