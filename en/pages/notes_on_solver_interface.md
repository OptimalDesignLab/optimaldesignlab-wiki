# Notes on the future Interface (API)

Place to record ideas for the interface/API we will create for the merged solver.

## Major components

A list of major components (modules/packages) required by a parallel, multi-physics solver

* linear solvers
* nonlinear solvers
* spatial discretization
* temporal discretization/time stepping


## Linear Solvers

List of functions we need:

* `axplusby!(a::T, x::AbstractVector, b::T, y::AbstractVector)`
* `innerprod(x::AbstractVector, y::AbstractVector)`
* `solve!(solver::AbstractLinearSolver, A::AbstractMatrix, M::AbstractMatrix, rhs::AbstractVector, options::Dict)`

Jianfeng: explicit matrices should be construted using sparsity pattern

## Nonlinear Solvers

List of functions we need:

* `solve!(solver::AbstractNonlinearSolver, res::Function, linsolver::AbstractLinearSolver, Jacobian::AbstractMatrix, Precond::AbstractMatrix, options::Dict)` (or make `res` and `Jacobian` types).

Need to worry about duplicating communication when calling/building Jacobian and preconditioner.

Should have call-backs/hooks at the beginning and end of each iteration

## Spatial Discretization

Dimension should be a type parameter

Debate: should we pass the interpolated values or some nodal degrees of freedom.

Jianfeng: paste your notes here (and indicate that these are opinions)

The basic concept: modularization + generic programming + specialization

### Some implementation suggestions###
* Residual and Jacobian calculation should be decomposed into several parts:
       element integral, 
       interface integral, 
       bndryface_integral. 

* Each part should be further decomposed into single entity contribution
   for both efficiency and flexibility. (I think currently ticon and ibm code both do this)

* (This part is mainly about integral)
   We should maximize code reuse. For example, linear advection and Euler problems
   could share the same code, probably with distinct fluxes calculation only. 

* (This part is mainly about numerical fluxes, material properties)
   Some comonly used functions, like Riemann solver, SIPG fluxes, should be shared by multiple physics. 
   eg. put them into a files, and if you include the file you can use them. These functions should 
   be independent of physics (both Euler and Navier-stokes can use Roe's FDS, that means Roe's FDS
   should not exclusively belong to Euler). 
   (this part is about integral)

* We are able to define a set of functions that works for many physics/discretizations. 
   For those physics/specific discretizations beyond these considerations, the user is free
   to define their own versions as specializations. Specialization should be allowed in all hierarchies.
   This requires a lot abstraction.

* Variables should be categarized into: 
        mesh info
        physics agnostic variables(used in solver), like residual, solution, jacobian matrix, solver control variables
        physics property variables, like (γ, Ma, Re, Pr) in case of Navier-Stokes.

* How to deal with intermediate "global" variables, like pressure? I personally don't suggest 
   using "global" physics variables like `face_flux`, `pressure`. 
   But if "global" variables are allowed, where to declare/define them?  

   Option: declare a data manager together with solution variable:
       help_facedata:: type to be defined
       help_elemdata:: type to be defined
           type DataManagement{T}
               opts["name"] -> arra
               data::Array{Array{}}
           end
           # to create data
       add_data(help_elemdata, "pressure", num_dof_per_node=1)
       add_data(help_facedata, "vel",      num_dof_per_node=Tdim)
       initialize(help_elemdata)

       # to access (read and write) data
       press = get_data(help_elemdata, "pressure")


* Spatial dimension should exist as a type parameter if for the same functionality, 
   2D and 3D could be totally different.

* A default approach to compute Jacobian, such as (complex) finite difference using coloring.
   Mainly for debugging purpose since usually it's very slow.

* Define discretizations of comonly used terms,
        ∫ ∇ϕ⋅F⃗(q) dΩ
        ∫ ∇ϕ⋅F⃗(q, ∇q) dΩ
        ∫ [ϕ]F⃗(q)⋅n⃗ dΓ   
        ∫ [ϕ]F⃗(q, ∇q)⋅n⃗ dΓ   
        ∫ [ϕ]G[q] dΓ
        ∫ {ϕ}[F] dΓ
        ......
* supply several sparsity patterns

* Without no significant effort/comlexity, we should leave more options for future developent,
    either due to personal or lab interest.

* solution variable: use 1D or 2D array rather than 3D. Then each element should know or
   have access to its dofs (node indices). This brings little, if no, extra efforts, but 
   has some benifits: 
      easy to extend to mixed element types;
      easy to extend to CG/SUPG;
      able to avoid copying from distributed array to julia array, so we don't need
      assemble, disassemble;

## Temporal Discretization/Time Stepping


