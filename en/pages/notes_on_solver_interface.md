# Notes on the future Interface (API)

Place to record ideas for the interface/API we will create for the merged solver.

## Calling the solver

This is a brief "wish-list" of how the solver would be used.

```
# load options and override if wanted
opts["physics"]["iflux"] = "IRflux"  # set inviscid flux
readOptions!("options.json", opts)

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

# create an Euler physics type, and then the solver
euler = createPhysics(opts["physics"], opts)

# when the solver is created, the Jacobian, if needed is created (etc.)
solver = createPDESolver(mesh, euler, opts)  # mesh, euler, opts stored in fields of solver

# solving for the flow
q = createStateVec(solver)  # this may not work for unsteady, unless it is for a point in time
solveState!(solver, q)  # this may be steady or unsteady

# getting the residual
res = createStateVec(solver)
updateMetrics!(solver.mesh)
calcStateResidual!(solver, q, res)

# solving an adjoint
psi = createStateVec(solver)
dJdu = createStateVec(solver)
functional = createObjective(opts["obj"], solver.mesh)
calcdJdu!(functional, solver, q, dJdu)
solveAdjoint!(solver, dJdu, psi)

```

Issues for `calcStateResidual`:

  * 1D arrays at top level (for passing between physics and linear solver)
  * 3D versus 2D arrays for state vector info
  * Sharing functions between nested physics
  * CG versus DG 

```
function calcStateResidual!(solver::Solver,
                            q::StateVector,
                            res::StateVector)
# parallel communicate q here?

# zero out res
fill!(res, 0.0)

# loop over the elements; compute the volume integrals
for elem = 1:mesh.num_elem

  # volume integral


end

# internal face integrals


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
