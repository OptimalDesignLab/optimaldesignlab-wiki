# C++ Documentation Guide

We use [Doxygen](http://www.doxygen.nl/) to document C++ code.  In addition to the official website, here is a great quick reference if you forget a command:

http://mitk.org/images/1/1c/BugSquashingSeminars%242013-07-17-DoxyReference.pdf

Since Doxygen is very flexible with how it can be used (i.e. many different syntaxes will work), it is important to stick to one format or our code will be difficult to read.  The following sections provide examples of how to format your Doxygen comments for code developed in the lab.  But first, here are the general guidelines:

* Use `///` to indicate a Doxygen comment.  Do not use `/**` or `/*!`.
* Like the code, keep you comments within 80 characters.

**Note:** In the following code snippets, I use `...` to denote arbitrary code that is not important to the discussion.

## Class declarations

Provide a one line explanation of what the class is for.

```c++
/// Serves as a base class for specific PDE solvers
class AbstractSolver
{
   ...
}
```

## Functions (regular and member)

You will probably spend most of your documentation time on functions.

* Start function documentation with a single line explanation of what the function does.  
* Provide a description of each input parameter using the `\param[in]` keyword.
* Provide a description of each output parameter using the `\param[out]` keyword.
* If a parameter is needed as both an input and output, use `\param[in,out]`.
* If the function returns a value, use the `\returns` command to document that value.
* Add additional comments after the `\param`s if needed.
* Use `\note` or `\warning` commands if you want to bring something important to the user's attention.

Here is an example:

```c++
   /// Write the mesh and solution to a vtk file
   /// \param[in] file_name - prefix file name **without** .vtk extension
   /// \param[in] refine - if >=0, indicates the number of refinements to make
   /// \todo make this work for parallel!
   /// \note the `refine` argument is useful for high-order meshes and
   /// solutions; it divides the elements up so it is possible to visualize.
   void printSolution(const std::string &file_name, int refine = -1);
```

If the function has template parameters, document them as shown in the example below:

```c++
/// Pressure based on the ideal gas law equation of state
/// \param[in] q - the conservative variables
/// \tparam xdouble - either double or adouble
/// \tparam dim - number of physical dimensions
template <typename xdouble, int dim>
inline xdouble pressure(const xdouble *q)
```

## Class data member attributes

Document class members on the line preceding their declaration in the class.

```c++
class AbstractSolver
{
public:
   ...
protected:
#ifdef MFEM_USE_MPI
   /// communicator used by MPI group for communication
   MPI_Comm comm;
#endif
   /// process rank
   int rank;
   /// print object
   std::ostream *out;
   ...
};
```

## Files

If you think you need to document a file, let me (Prof. Hicken) know, because we do not have a guideline for this yet.
