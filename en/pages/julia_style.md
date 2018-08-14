# Julia Style Guide

We try to adhere to the [official style recommendations](http://julia.readthedocs.org/en/release-0.3/manual/style-guide/), so read those first.

## Naming Conventions

As always, naming conventions are particularly important, so others can understand your intent from the name itself.

* Function names, variable names, and filenames should be descriptive; **avoid abbreviation**.
* **Filenames** should be all lowercase and can include underscores, unless the file corresponds to a Package name. e.g. `cubature.jl`, `test_cubature.jl`, `SummationByParts.jl` (the latter is a Package)
* **Type names** start with a capital letter and have a capital letter for each new word, with no underscores: `MyExcitingType`.
* **Variables** are all lowercase, **with no underscores** between words, unless needed for clarity.  This applies to fields in user defined types as well.
* **Methods/Functions**: also all lowercase, with underscores used only if necessary.

It is up for debate whether we will allow unicode names (in UTF-8 encoding) in our code.

## Formatting Conventions

The important point regarding formatting is **consistency**.  Project source code is much easier to read if it is consistent.

* Each line of text in your code should be at most 80 characters long.
* Use only spaces, and indent 2 spaces at a time.  **No tabs please!!!**
* Function calls on one line if it fits; otherwise, wrap arguments at the parenthesis.
* For conditionals, avoid parentheses unless they are needed.
* Minimize use of vertical whitespace.
* Never put trailing whitespace at the end of a line.

## Documenting and Commenting Conventions

### Documenting vs. Commenting
There are two kinds of non-code text in source files: Documentation and Comments.  The purpose of documentation is to tell other people (ie. people who did not write the code) how to use it.  The purpose of comments is to explain portions of code to someone who is trying to understand its implementation.

### Documentation
This is perhaps the most important convention: **comment your code!**  This is very important to help your colleagues and future students understand your code.  Moreover, ''comments will help you too''.  I promise that you will write code that, someday, you will return to and not remember what it does.  Without comments, you will have to reverse engineer what you wrote.

Julia's commenting conventions and capabilities are evolving.  At this time, we use the `@doc` macro to document types and function methods using the CommonMark version of the the Markdown language (see [http://en.wikipedia.org/wiki/Markdown]).  This is motivated by the discussions on github that suggest Julia is heading in this way.

An example is the best way to illustrate the conventions.  For a function/method:
```
"""
### Cubature.tetcubature{T}

This high-level function computes and returns the weights and nodes for a
cubature of requested accuracy on the right-tetrahedron.

**Inputs**

* `q`: maximum degree of polynomial for which the cubature is exact
* `tol`: tolerance with which to solve the cubature

**Outputs**

* `w`: cubature weights
* `x`: cubature node coordinates (x,y,z)

"""->
function tetcubature(q::Int, T=Float64; tol=eps(T(10)))
...
```

For a user defined type:
```
@doc """
### SymCubatures.TetSymCub

Used to define symmetric cubature rules on the tetrahedron.  The `params` array
determines the position of the parameterized nodes, and the `weights` array
determines the value of the weight for each symmetric orbit.  Note that boolean
fields are used to activate some degenerate symmetry orbits.  For example,
vertices are a special case of several of the orbits, and should be activated by
setting vertices=true rather than relying on a specific value of a parameter.

**Fields**

* `numparams` : total number of nodal degrees of freedom
* `numweights` : total number of unique weights
* `numnodes` : total number of nodes
* `vertices` : if true, vertices are present in the set of nodes
* `midedges` : if true, edge midpoints are present in set of nodes
* `centroid` : if true, centroid is present in set of nodes
* `facecentroid` : if true, face centroids are present in the set of nodes
* `numedge` : number of unique edge parameters
* `numS31` : number of S31 orbits (vertex to opposite face)
* `params` : the actual values of the orbit nodal parameters
* `weights` : values of the unique weights

"""->
type TetSymCub{T} <: SymCub{T}
...
```

Notes regarding documentation:

* The documentation must be placed just before the function or type.
* The first line after the `@doc """` should be the title, which will be the function/type name (qualified by the module name, if appropriate)
* After the title, provide a description of what the type is for, or what the function does.
* Leave a space between the title and the description.
* After the description, list the function Inputs, Outputs, and In/Outs with short explantions.  In the case of a type, list the fields with short explanations.
* If an input/output or field is mentioned in the description, highlight it using ````.


### Comments
Comments are placed inline with source code or at the top of a function body.  Comments generally fall into one of two categories: comments that explain the algorithm, and comments that explain individual steps in the algorithm. Comments that explain the algorithm are usually at the top of the function body, while comments explaining individual steps are usually in line with the code.

Some things hat are generally commented:

* New variables
* Purpose of loops
* Assumptions used in the code
* How arguments are used (more detailed than in the documentation)

For example:
```
function calcBC(bcs::AbstractArray{BCType, 1}, offsets::AbstractArray{Int, 1}, q::AbstractArray{Float64, 3}, res::AbstractArray{Float64, 3})
# this function applies all of the boundary conditions to the entire mesh
# the boundary condition functions are held in the array bcs
# the solution variables are held in the array q
# the result of the calculation is stored in res, which should be the 
# same size as q
# the array offsets contains the index in q of the start of each BC
# offsets should be length(bcs) + 1, and the last entry should be
#   length(q, 3) + 1

  numBC = length(bcs)
  for i=1:numBC  # loop over all boundary conditions
    start_idx = offsets[i]  # starting index in q for current BC
    end_idx = offsets[i] - 1  # ending index in q for current BC
    qvals_i = view(q, :, : start_idx:end_idx)  # get current q values
    resvals_i = view(res, :, :, start_idx:end_idx)  # get current res_vals
    bc_i = bcs[i]  # get current boundary condition function
    bc_i(qvals_i, resvals_i)
  end

  return nothing
end
```