# Notes on the future Interface (API)

Place to record ideas for the interface/API we will create for the merged solver.

## Calling the solver

This is a brief "wish-list" of how the solver would be used.

```
# load options and override if wanted
opts = readOptions("options.json")
# TBD: will options be "flat" or nested?
opts["physics"]["iflux"] = "IRflux"  # set inviscid flux

# define the boundary condition indices
# boundary_patches[opts["bc"][1]] = [1, 2, 3]  Idea?
boundary_patches = Array{Array{Int}}
wall_bc_patches = [1, 2, 3]
farfield_bc_patches = [4, 5, 6]
append!(boundary_patches, wall_bc_patches)
append!(boundary_patches, farfield_bc_patches)

# generate an appropriate mesh
mesh = generatePumiMesh(meshfile="naca_mesh.smb",
                        geofile="naca.dmg",
                        element_type="sbp",
                        patches=boundary_patches,
                        ndof_per_node=5) # ndof_per_node being here is up for debate!
# mesh = generateRectMesh(lenx=1.0, leny=1.0)

# creating an Euler solver
euler = createEulerSolver(mesh, opts)

q = createStateVec(mesh, euler)
solve(euler, q)
getResidual(euler, q)









euler = createEulerPhysics(opts)

solver = createPDESolver(mesh, euler, opts)


```

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

```
solve!(sol::AbstractVector, solver::AbstractNonlinearSolver, residual::Function,
       linsolver::AbstractLinearSolver, Jacobian::AbstractMatrix,
       Precond::AbstractMatrix, options::Dict)
```
Or make `residual` a type?

Need to worry about duplicating communication when calling/building Jacobian and preconditioner.

Should have call-backs/hooks at the beginning and end of each iteration

## Spatial Discretization

Dimension should be a type parameter

Debate: should we pass the interpolated values or some nodal degrees of freedom.

Jianfeng: paste your notes here (and indicate that these are opinions)

## Temporal Discretization/Time Stepping
