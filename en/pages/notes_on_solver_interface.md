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
  * 2D arrays for state vector info; however, **data in these 2D arrays is stored contiguously like it would be in 3D arrays**.  This means, for example, that for CG implementations there are duplicated values at coincident nodes.  This is important for coloring-based AD.
  * Sharing functions between nested physics ---> physics modules nest one another?
  * CG versus DG

The version of `calcStateResidual!` below is basically a wrapper, taking `qvec` as a 1D array (actually, the array is stored inside the `StateVector` type), copying it into 2D array format, and then calling the `calcStateResidual!` for the 2D format.  
```
function calcStateResidual!(solver::Solver,
                            qvec::StateVector,
                            resvec::StateVector)
  # parallel communicate qvec here?

  # copy qvec into 2D arrays, get residual, and move back into 1D format
  copyStateVectorTo2DArray!(solver, qvec, solver.q)
  calcStateResidual!(solver, solver.q, solver.res)
  copy2DArrayToStateVector!(solver, solver.res, resvec)
end
```

The function below works on 2D array types and does the heavy lifting for the residual calculation, looping over elements and faces.
```
function calcStateResidual!(solver::Solver,
                            q::AbstractArray{Tsol,2},
                            res::AbstractArray{Tres,2}) where {Tsol,Tres}
  # zero the residual, and get a shallow copy of the dudx array
  fill!(res, 0.0)
  dudx = solver.dudx

  # flux is an array large enough to hold data for all the nodes on largest
  # element
  flux = solver.element_work

  # loop over elements and evaluate the volume integrals
  for nodes, fem in getElement(solver) # <-- returns an iterator
    # compute derivatives for viscous terms
    for di = 1:mesh.ndim
        calcDerivatives!(solver.physics, fem,
                         sview(q_elem,:,nodes),
                         sview(dudx,:,di,nodes))
    end
    calcVolumeFlux!(solver.physics, sview(q_elem,:,nodes),
                    sviw(dudx,:,:,nodes),
                    sview(flux,:,1:length(nodes)))
    weakDifferentiateElement!(fem, sview(flux,:,1:length(nodes)),
                              sview(reselem,:,nodes))
  end

  # internal face integrals

end
```


The `copyStateVectorTo2DArray!` function moves data from 1D array storage in a `StateVector` to 2D array storage in `u`.  The code uses ideas from sparse matrix storage.
```
function copyStateVectorTo2DArray!(solver::Solver, uvec::StateVector{Tsol},
                                   u::AbstractArray{Tsol,2}) where {Tsol}
  nPDE = solver.mesh.ndof_per_node
  for elem = 1:solver.mesh.num_elem # <-- total number of elements of all types
    for node in get2DArrayNodeRange(solver.mesh, elem)
      for var = 1:nPDE
        u[var, node] = uvec[nPDE*(solver.mesh.node_idx[node]-1)+var]
      end
    end
  end
end
```

The function below returns the range needed inside `copyStateVectorTo2DArray`
```
function get2DArrayNodeRange(mesh::AbstractMesh, elem::Int)
    return mesh.node_start[elem]:mesh.node_start[elem+1]-1
end
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
