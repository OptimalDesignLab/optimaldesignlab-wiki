# The Julia Programming Language

Julia is a new programming language intended for technical and scientific computing.  It aims to achieve the efficiency of statically typed languages such as C++ while retaining the flexibility of dynamically typed languages such Python.  It attempts to implement the most useful features of a many other programming languages including C++, Python, Ruby, and Lisp, while retaining a Matlab like interface.  This is achieved through the combination of a Just In Time (JIT) compiler and dynamic typing of variables.  Type declarations are not required when declaring a variable (although they can be optionally supplied); the type is inferred from the value assigned to it.  By default, the arguments of a function do not have a specific type, so Julia functions are Generic Functions in the terminology of C++.   Each time a Julia function is called, it is passed parameters that have known type, so the JIT compiles a version of the function with arguments of the specified types.  This enables Julia to have efficiency near that of statically compiled languages because every time a function is compiled, the types of its arguments are known, just like a statically compiled language.  Although compiling a function takes some time, it only needs to be done once for each version of the function.  After that, the function can just be executed.  This is the heart of Julia’s efficiency and guides style of programming in Julia.


The Julia homepage can be found [here](http://julialang.org/)

The Julia documentation can be found [here](http://julia.readthedocs.org/en/latest/manual/types/)

A convenient pdf of the latest documentation build can be found [here](https://media.readthedocs.org/pdf/julia/latest/julia.pdf)

The Julia documentation provides good explanations of the fundamental ideas behind Julia and demonstrates the basics, but does not document every feature of the language.  Reading from the beginning of the documation up through the Parallel Computing section provides a good overview of Julia's capabilities. Additionally, the Performance Tips section has some useful information on how to write code that will run fast.  Reading this before starting any big projects is quite helpful.

## Obtaining Julia
There are two versions of Julia available the Release version and the Experimental version.  The Release version is more thoroughly tested, but the Experimental version has more recent bugfixes and new features.  Julia is being developed rapidly, so sometimes it is necessary to use the Experimental version because of bugs in the Release version. 

### Precompiled Binaries
Precompiled binaries of the Release version are available for Windows, Mac OS X, and several Linux distributions.  The Julia homepage has instructions for obtaining them.

### Building Julia from Source

In order to run the Experimental version or to run the Release version on a machine that cannot download the precompiled versions (such as the clusters or the supercomputer), it has to be built from source.  The Julia Github page has general instructions for doing so, but there are a few additional considerations for building on a cluster.  The Julia Github page can be found [here](https://github.com/JuliaLang/julia) 

#### Preparing the Build Environment 
Julia downloads and builds all its dependencies automatically, so the only programs that need to be installed before Julia are the tools Julia needs to build its dependencies.  A full list of dependencies is on the Github page, but for the DRP and RSA Clusters it is important to have a version of GCC >= 4.6 available.  The default compiler on RSA is not recent enough, so a newer version must be installed and added to the `PATH` and `LD_LIBRARY_PATH` variables before the default compiler so the new compiler and its associated libraries are used.
Also, the version of binutils on RSA is too old to built OPENBLAS, one of the dependencies built by Julia (see Possible Errors section).  A more recent version is located in `~/barn-shared/binutils-2.23.2/binutils-2.23.2_installed`.

Also, cmake must be available.  On RSA, it is in the default PATH, so you don't have to do anything.  On DRP, it has been installed in  `~/barn-shared/DURIP/cmake/2.8.12`.  Adding the `./bin` directory to your `$PATH` will enable the Julia build system to find it.

#### Downloading Dependencies
The clusters do not allow internet connects to be initiated from within the cluster, so all the parts of the build that require an internet connection must be done on your local computer and then copied to the cluster.  First, download the source code to your local computer using the <code>git clone </code> command described on Github.  This will create a new folder ./julia and download the files into it.  Second, download the dependencies using

``` 
cd ./julia
make –C deps getall
```

Now you can copy the files to the cluster because all actions requiring internet access are finished.  Compressing the files using tar will make the copy go much faster.

#### Performing the Build
When Julia is built it automatically detects the hardware configuration of the computer that executes the <code> make </code> command and customizes the build for it.  For RSA, this makes things easy because the head node has the same hardware as the compute nodes , so using the automatic settings is correct.  For DPR, you might need to override some of the default settings.

At this point you are ready to build Julia and all of its dependencies using the command

```
make –j 8 > fout 2> errout
```

where the `–j 8` switch tells the make command to use 8 processors for the build, the `fout` redirects the standard output to a file named fout and `errout` redirects the error output to the file errout.  Redirecting the outputs is helpful because there is a lot of both standard and error output in a successful build.  If there is an error, being able to inspect the errout file is helpful to find the cause of the error.  The build takes a long time, upwards of a hour.  It takes so long because it builds all of the dependencies before building Julia itself.  If you have an unstable internet connection or intend to log off before the build finishes, it is a good idea to put the `make` command in a script file (lets call the file `makeit.sh`, and run it like this

```
nohup ./makeit.sh &
```

`nohup` tells the shell to continue executing the command even if the current terminal is closed, and the ampersand tells the shell to run the command as a separate process, so you get control of your terminal back immediately.  You can use the command

```
tail ./fout
```

to view the last 10 lines of the file fout to check the progress of the build.  There will be a steady stream of output.

#### Testing the Build
After installation running the command

```
make testall
```
will run a set of test on Julia to make sure it built correctly.

#### Possible Errors
One of Julia’s of the dependencies that Julia builds is OPENBLAS, which requires a version of binutils newer than the default on Red Hat Enterprise Linux (RHEL). Using the default binutils gives an error such as

```
no such instruction: vpermpd
```

## General Julia Programming

Here are a few points that are mentioned in the documentation but are worth repeating.

First, all arguments to a function are passed by reference.  This means that a function can modify *all* of the variables that are passed to it as parameters (not just arrays like in C++).  The convention is that if a functions name ends in an exclamation point (!), then it modifies its arguments, otherwise it does not.  In order to maintain a [sane](https://en.wikipedia.org/wiki/Sanity_check) programming environment, following this convention in all of your code is important.

```array1 = [1,2,3]```

vs 

```array1[1:3] = [1,2,3]```

This first line of code assigns a new value to the name `array1`.  The second line of code reassigns the values of the first three elements of array1, which is a much more memory efficient operation, and is the way to use arrays that are passed by reference to a mutating function (a function that modifies its arguments).

Julia does not have classes like C++.  Julia has Types, which are a collection of variables (data members to C++ programmers) and constructors, but not functions.  Because of dynamic multiple dispatch, when a function is called, all its methods must be evaluated to determine the best match to the function call based on the parameters passed to the function.  For this reason, it does not make sense to attach one method of a function to a particular Type and another method of the same function to another Type.  Because of the smart Type Inference system employed in Julia, implementing the state of on object using a Type and its behavior through a set of functions that are not attached to the Type results in fairly easy generic programming.  Modules provide a way to bundle the Type declaration and related methods together, so if one is available, so is the other.

Functions are first class objects in julia, just like arrays and regular variables, and have type `Function`.  There can be a variable `func1` that is assigned to the name of a function, so it can be used to access that function.  For example, `func1 = sin; func1(0)` gives zero.  `func1` is assigned to the `sin` function, so calling `func1` with the argument zero is just another way of calling `sin` with the argument zero, and `sin(0) = 0`.  This can be useful to associate a function with a Type.  If a Type has a member of type Function, and that member is assigned a value during construction, the use of that function with that Type is indicated.  This somewhat emulates a C++ class.

Type declarations are optional in Julia, but are sometimes useful as a means of documentation.  Julia defines two kinds of types, Abstract and Concrete.  Together, they define a hierarchy of types.  Abstract types are used to create the hierarchy, while Concrete types are those at the end of a branch, those that can be instantiated.  The center of Julia's type hierarchy is the type Any.  It has many subtypes, such as String and Number.  Number has subtypes Real and Complex.  Real has subtypes Integer and Floating Point, which themselves have more subtypes, until we get to the Concrete types Float64, Int64, Unsigned Int64 etc.  Even though Abstract types cannot be instantiated, they can be used in type declaration to ensure the type of the variable is a subtype of its Abstract type.  For example, declaring a variable of type Integer ensures that whatever value is assigned to it is an integer of some kind, and is definitely not a FloatingPoint.  This gives very granular control over the types of variables, and is particularly useful for function declarations to document what kind of arguments the function expects, and to make sure Julia throws an error if the function is called with an argument that would cause a problem.

Julia is intended for generic programming.  The only major way to cause errors in Julia code is to perform an operation on a Type that does not support the operation.  Adding two numbers works, but not adding two strings.  This lends itself to generic programming, that is, programming without considering the exact Type of the objects being operated on.  The Julia syntax was created so that Types that support similar operations have similar syntax.  This too makes it easy to write a single function that performs a set of operations on both Arrays and Dictionaries, for example.

Unlike Matlab, Julia has separate Vector and Array types.  They have similar syntax, but are different in a few ways.  For example, calling `size()` on a vector gives a tuple with one component, not two like an array.  In this sense, a vector is not an m x 1 array.

Note that there are (at least) two ways to index matrices.  The first is the standard `array1[row,column]`.  The second is array1[index], where index is the element number.  Julia arrays are stored in column major order (like Fortran, unlike C++ built-in arrays), so index counts down the first column, then starts again from the top of the second column etc.

Julia's arrays are stored in memory exactly like Fortran arrays.  Therefore, there is zero overhead to calling linear algebra functions that are implimented in Julia's Fortran dependencies (Julia calls those functions directly whenever possible).  Julia's Fortran dependencies include OpenBlas and LinPack, which provide good coverage of linear algebra.

Unlike Matlab, a 1x1 array of type T is not the same as a variable of type T.  For example, a 1x1 array that contains a Float64 is not the same as a variable of type Float64.  Trying to use one in place of the other causes errors.

## Running Julia in Parallel
When Julia is running, it can create additional Julia processes, called functions on workers, and assign work to them.  This enables Julia to use multiple processors.  The number of Julia processes need not be the same as the number of processors.  Julia will attempt to assign a process to a particular CPU, although the operating system may move it around.  If there are more processes than processors, Julia assigns multiple processes to a CPU.  There are two ways to create additional processes, depending on whether the new processes are to be created on the same machine as the original Julia process or on a different machine.

### Local Machine
To create worker processes on the local machine, launching Julia with the `–p n switch`, where `n` is a number, will launch Julia an immediately create `n` additional processes on the local machine.  Alternatively, from within an interactive Julia session or a source file, the command `addprocs(n)` can be used to achieve the same effect.

### Cluster
To create Julia processes on other machines, addprocs need additional information.  The command `addprocs(machines)` where `machines` is either a vector containing strings that are the hostnames of the machines on which the new processes will be created.  This works even if the hostname is the hostname of the machine the Julia master process is running on.  
In order for this to work, the machine running the Julia master process must be able to access all the other machines using passwordless ssh.  This can be done by using wildcards in the known_hosts and authorized_keys files in `~/.ssh.`

### SLURM and Julia
SLURM provides two methods for running jobs, `srun` and `sbatch`.  `srun –N 2 –n 16 /path/to/julia/executable ./Main_script.jl` is intended to run a Julia script on 2 nodes using a total of 16 processors.  What it actually does is run `Main_script.jl` once on each node, running it a total of twice in this example.  While this might be the desired behavior for a programing using MPI for parallel communication, it is not for Julia, which creates its own processes , rather than having SLURM create one process on each node.  Using `sbatch` creates a single Julia process.   

Here is an example of using scripts to submit a job using `sbatch`.  This method requires two scripts.  The first script is called `slurm_run.sh`:

```
 #!/bin/bash
 # slurm_run.sh
 
 # create hostnames file
 srun hostname -s > ./hostnames
 
 # write job allocation info to file
 echo "SLURM job id = $SLURM_JOB_ID" > job."$SLURM_JOB_ID"
 echo "SLURM tasks per node = $SLURM_TASKS_PER_NODE" >> job."$SLURM_JOB_ID"
 echo "SLURM number of nodes = $SLURM_JOB_NUM_NODES" >> job."$SLURM_JOB_ID"
 echo "SLURM nodelist = $SLURM_JOB_NODELIST" >> job."$SLURM_JOB_ID"
 
 # run the job
 ~/scratch-shared/julia_DRP/julia_1_14_15/julia ./Main_script_parallel.jl
```

The second script is called slurm_submit.sh:
```
 #/bin/bash
 # slurm_submit.sh
 
 # user defined variables
 ntasks=1		# total number of tasks to create
 nnodes=1		# number of nodes
 partition="drp"	# name of partition (drp or rsa)
 
 timelimit=2100		# time limit for job (only required for drp)
 outfile=stdout.log	# redirect standard output to this file
 errfile=errout.log	# redirect error output to this file
 threads=2       # number of logical cpus per task (=2 to ameliorate hyperthreading
 
 ./cleantest		# user created script to delete any output files from previous runs (optional)
 
 module load gcc/4.9.1_1		# enable julia to dynamically link to libstdc++
 
 sbatch  -N "$nnodes" -n "$ntasks" -p "$partition" -c "$threads" -o "$outfile" -e "$errfile" -t "$timelimit" ./slurm_run.sh
```

To launch a job, simple execute `./slurm_submit.sh`.  This script lets the user modify the values of commonly used variables and passes them, along with the script `slurm_run.sh` to sbatch.  The adds the job to the SLURM queue.

The standard output and error output files are not written to the working directory until the end of the job, so they are not useful for tracking the progress of the job.  Files written by Julia are written to disk immediately, so can be used for this purpose.

The `./cleantest` line calls another script in the same directory to delete any files that are written by your Julia code before running the job.  It is good practice to do so in order to prevent accidentally appending to a file from a previous job, although it is not required.

Note that this script loads the module `gcc/4.9.1_1`.  This is the compiler used during the Julia build.  Julia dynamically links to the C++ Standard Library, and so it needs to be able to find it at runtime.  Loading the module adds the location of the library to the `$LD_LIBRARY_PATH` environmental variable, which Julia uses to locate libraries.

The script `slurm_run.sh` is passed to `sbatch`, and contains commands to write some job allocation information to a file when the job launches and launches Julia, specifying the path to the Julia executable and passing it the file `Main_script_parallel.jl`.  `slurm_run.sh` must be in the same directory as `Main_script_parallel.jl`.  All file reading and writing happens in this directory.  Note that the path to the Julia executable will be different for RSA and DRP


## Writing Parallel Code

Here is a quick review of Julia’s parallel features as described in the documentation, as well as some additional features that are not mentioned in the documentation.

Julia documentation suggests a master/slave parallel structure, with the master process using `remotecall` to assign work to a slave process and the slave process returning the result with a RemoteRef.  However, `remotecall` and `RemoteRef` provided a robust enough framework for other organization, such as lateral communication between workers, which tends to be more efficient.

Each julia process has its own namespace and memory that cannot be directly accessed by other processes.  In order to make a variable accessible to other processes it must be put inside a new special kind of a variable called a RemoteRef.  The command `rref1 = RemoteRef(i)` creates a `RemoteRef` that is stored on process i.  If the variable `rref1` is passed to another process somehow, perhaps as the argument to a function (more on that in a minute), the other process can access the contents of `rref1`.  

A `remotecall` tells a specific process to execute a function.  The function name must be known to the process executing it, and the arguments are passed from the calling process to the called process.  A `remotecall` returns a RemoteRef, and returns it immediately, before the function finishes executing.  Calling wait on a `RemoteRef` will wait for a value to be put in the RemoteRef, either by a function returning a value or through `put!` command.  `fetch` and `take!` Automatically wait before performing their operations.

Now for some important behavior of `RemoteRef` and `remotecall` that are not mentioned in the documentation.  Attempting to use `put!` on a `RemoteRef` that is already storing a value result in the `put!` command waiting until the value is removed from the `RemoteRef` before performing the `put!`.  The only way to remove a value from a `RemoteRef` is by using `take!`.  This provides a way to reuse a RemoteRef.  For example, a time stepping method could `take!` a value from a `RemoteRef` at the beginning of every iteration, relying on another process to `put!` a value into it at the end of every iteration.  Because of the automatic waiting behavior of `put!` and `take!`, the iterations of both processes will remain synchronized.  This happen because each process will wait for a value to be `put!` before performing the `take!` at the beginning of the iteration, and the other process supplying the value will wait for the `take!` to finish to `put!` a new value into the RemoteRef.  Therefore, every value is used without skipping any.  This provides a good model for lateral communication between worker processes.  The only additional requirement is passing the correct  RemoteRefs to the worker processes so they send to and receive from the right processes.

### Threading

Threading, also called Tasks or Coroutines, are a mechanism to run separate lines of execution *on a single processor core*.  This is fundementally different from parallelism, which uses Remotecalls and RemoteRefs to run separate lines of exeuction *on different processor cores*.  Additionally, a single processor core can only run one thread at a time, whereas parallelism involes multiple processor cores, each of which can be executing a different line of execution at the same time.  These are the fundemental difference between threading and parallelism.  Threading and parallelism are different mechanisms, although they are often used together to perform communication with other processes.

The benefit to threading is that it can be used to avoid wasting CPU time waiting for non computationally intensive tasks to complete.  Each Julia process has a Scheduler that decides which task to run and when to switch tasks.  When a process calls the `wait` function, it automatically tells the Scheduler to run a different task.  In other words, rather than just waiting, another Task is run, so CPU time is not wasted waiting.  A common use of this is for interprocess communication.  As an example, lets a process needs to fetch values from 4 other processes.  Making each fetch a separate tasks will enable the tasks to run any order, avoiding waiting.  If the fetches were all in the same task, they would  be executed in order.  If the value fetched from the first process is not ready yet, `fetch` will wait until it is ready, fetch it, and then fetch the remaining 3 values.  If they are in separate tasks, as soon as the first fetch calls `wait`, it will run other tasks until the first value is ready and then fetch it.  The time spent waiting if the all fetches are in the same task is used to do the other three fetch when they are in separate tasks.

The code to do this uses two macros, `@async` and `@sync`.  The `@async` macro takes and expression and launches a task to execute it, and returns immediately.  The `@sync` macro followed by a block of some kind (a for loop, a let block, anything that contains code within it), waits for all tasks launched within the block to finish before continuing.  The code for the example described above is:

```
@sync for i=1:4
  @async fetched_values[i] = fetch(remoteref_array[i])
end
```

This code fetches the values from RemoteRefs stored in the array `remoteref_array` and stores the values in the array `fetched_values`.  Because `@async` return immediately (does not wait for the task it launches to complete), all 4 tasks are launched, but because of `@sync`, the program waits for all tasks to finish before executing any code after the for loop.