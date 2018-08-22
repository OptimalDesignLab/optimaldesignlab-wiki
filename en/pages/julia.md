# The Julia Programming Language

Several of the lab's codes are written in Julia.  This page contains
introductory material for new members of the lab.

## Documentation

  The first step is to read the Julia documentation, which can be found
  [here](https://docs.julialang.org/en/v0.6.4/).  As of the time of this writing,
  the lab uses Julia 0.6 for all projects.  The following sections of the
  Julia documentation are useful.

   * Introduction
   * Getting Started
   * Variables
   * Integers and Floating-Point Numbers
   * Mathematical Operations and Elementary Functions
   * Strings (up to but not including the `Regular Expressions` subsection)
   * Complex and Rational Numbers (only the part on complex numbers)
   * Functions
   * Control Flow (skip the `Tasks` subsection)
   * Scope of Variables
   * Types
   * Methods
   * Constructors
   * Conversion and Promotion
   * Interfaces (skip the `Iteration` section)
   * Modules (skip `Module initialization and precompilation` subsection at first,
     but return to it later after you have read the other documentation)
   * Documentation (see PUT SECTION HERE for our lab's documentation standards)
   * Multi-dimensional Arrays
   * Networking and Streams (only the `Working with Files` subsection)
   * Interacting with Julia
   * Performance Tips


  New members of the lab should study the
  the documentation carefully and write short sample programs if any if the
  concepts are not clear (See the `Building Julia` Section below)

  A few sections of the documentation look interesting at first sight but are
  actually not

   * Linear Algebra: this section describes many of the linear algebra functions
     in Julia and is a good place to look up specific factorizations
     or operations, but is not meant to be read like the
     other other sections of documentation.
   * The `Tasks` subsection under Control Flow: tasks are not threads (such as
     pthreads or OpenMP threads) and have very different performance characteristics
     Don't use them.
   * Parallel Computing: our lab does not use Julia's parallel computing features.
     Instead we use the Julia wrappers for [MPI](https://github.com/JuliaParallel/MPI.jl).

  On the Julia documentation page, there is also a Standard Library reference.
  These pages are not meant to be read like the documentation pages, but are
  helpful if you are working on a code that involves one of the listed topics.

## Obtaining Julia

Binaries are available for Windows, Linux, and macOS on the
[Julia website](https://julialang.org/), under the `Downloads` tab.  Make sure
to get the version of Julia the lab is currently using (v0.6 at the time of this
writing).

### Building Julia from source

  It is also possible to build Julia from source.  The Readme on the
  [Julia github](https://github.com/JuliaLang/julia) describes how to do so,
  and will not be repeated here.  The purpose of this page is do describe some
  common problems encountered when building Julia on the machines at RPI.

  #### Internet access

   Some of the machines cannot access the internet (the CCI clusters are not
   allowed to by CCI policy, the Scorec workstations cannot because their
   software is too old).  To avoid this:

  * clone the Julia repository on a machine with internet access
  * checkout the required version of julia (for example `v0.6.4`)
  * run `make -C deps getall` to download all of Julia's dependencies
  * copy the Julia directory to the machine without internet access
  * Proceed to build normally (following the instructions in the Julia readme)


  #### Build Tool Verions

  The Julia build system depends on somewhat recent versions of common build
  tools (precise version numbers are listed in the Julia Readme).
  Some things to verify:

  * Compiler versions: on both the workstations and the CCI clusters, the
    default compiler versions are quite old.  Use the module system to
    load newer ones.  Make sure the the `PATH` environment variable has
    the compiler `bin` directory prepended to it, and `LD_LIBRARY_PATH` has
    the compiler `lib` directory (and `lib64` on 64 bit systems) prepended to it.
    You will also have to have `LD_LIBRARY_PATH` set this way whenever running
    Julia.
    * If you se error such as: `GLIBCXX_3.4.20' not found` when trying to run
      Julia, it is likely `LD_LIBRARY_PATH` is not set correctly.
  * Binutils: loading newer compilers does not load a newer Binutils. Binutils
    2.23.2 should be available in the module system on both the workstations
    and the CCI clusters.  If the default version is older than that (check
    the output of `ld --version`), use module system to load a newere one.
    If a newer one is not available, you will have to build it yourself.
    * If you get errors when building Julia such as: `no such instruction: vpermpd`,
      this is likely caused by an outdated version of Binutils.
  * CMake: Julia requires version 3.4.3 at least.  Use the module system to load
    it if possible, otherwise you will have to build it from source.
  * Python: Julia requires Python 2.7, but some of the machines have 2.6 as the
    default.  Use the module system if possible or build from scratch.
