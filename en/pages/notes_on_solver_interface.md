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
# This needs to size euler.work
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

## Evaluating the residual

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

  # work is a 3D array.  The first index is for variables; the second index must
  # be large enough to hold the data for the element type with the most nodes;
  # the third index is for the number of work arrays.
  work = solver.element_work

  # loop over elements and evaluate the volume integrals
  for nodes, fem in getElement(solver) # <-- returns an iterator
    dxidx_elem = sview(solver.mesh.dxidx, :, nodes)
    q_elem = sview(q, :, nodes)
    res_elem = sview(res, :, nodes)
    calcElementWeakForm!(solver.physics, solver.fem, dxidx_elem, q_elem,
                         work, res_elem)
  end

  # internal face integrals

end
```


```
function calcElementWeakForm!()
  # loop over flux types?

  # calcFirstOrderTerms!(physics.iflux, physics, fem, dxidx, uquad, work, res)
  
  prepData(physics, fem, work)
  for flux in physics.fluxes
    calcFlux(physics, flux, dxidix, uqaud, work, res)
  end
end
```


The function below performs the element-level weak-form calculation when the physics are hyperbolic PDE; this is dispatched based on `!Is2ndOrderPDE`.
```
function calcElementWeakForm!(solver::Solver, fem::AbstFE,
                              dxidx::AbstractArray{Tmsh,3},
                              u::AbstractArray{Tsol,2},
                              work::AbstractArray{Tres,3},
                              res::AbstractArray{Tres,2}
                              ) where {AbstFE,Tmsh,Tsol,Tres,Is1stOrdPDE{Tphys}}
  # flux = sview(work, :, :, 1)
  uquad = interpToQuadPts(fem, u, sview(work, :, :, 2:2+physics.nvar))
  calcFirstOrderTerms!(physics, fem, dxidx, uquad, work, res)
end
```

```
function calcElementWeakForm!(solver::Solver, fem::AbstFE,
                              dxidx::AbstractArray{Tmsh,3},
                              u::AbstractArray{Tsol,2},
                              work::AbstractArray{Tres,3},
                              res::AbstractArray{Tres,2}
                              ) where {AbstFE,Tmsh,Tsol,Tres,Is2ndOrdPDE{Tphys}}
  # flux = sview(work, :, :, 1)
  uquad = interpToQuadPts(fem, u, sview(work, :, :, 2:2+physics.nvar))
  for di = 1:physics.ndim
    differentiateElement!(fem, di, u, sview(dudx,:,:,di))
  end
  calcSecondOrderTerms!(physics, fem, dxidx, uquad, work, res)
end
```


The function below performs the element-level weak-form calculation when the physics involve a 2nd-order PDE; this is dispatched based on `Is2ndOrderPDE`.
```
function calcElementWeakForm!(physics::Tphys, fem::AbstFE,
                              dxidx::AbstractArray{Tmsh,3},
                              u::AbstractArray{Tsol,2},
                              work::AbstractArray{Tres,3},
                              res::AbstractArray{Tres,2}
                              ) where {AbstFE,Tmsh,Tsol,Tres,Is2ndOrdPDE{Tphys}}
  dudx = sview(work, :, :, 1:3) # need a better way to handle work index  
  flux = sview(work, :, :, 4)
  uquad = interpToQuadPts(fem, u, sview(work, :, :, 5:5+physics.nvar))
  for di = 1:physics.ndim
    differentiateElement!(fem, di, u, sview(dudx,:,:,di))
  end
  for di = 1:physics.ndim
    fill!(flux, 0.0)
    addInviscidFluxes!(fem, di, dxidx, u, flux)
    addViscousFluxes!(fem, di, dxidx, u, dudx, flux)
    weakDifferentiateElement!(fem, di, flux, res, Subtract(), transpose=true)
  end
end
```

The function below is for two-point flux calculations.  The trait `IsTwoPoint` is used to determine dispatch.
```
# !!!!!!!!!!!!!!!!!!  Under Construction
function calcAndDifferentiateFluxes!(physics::Tphys, fem::AbstFE,
                                     u::AbstractArray{Tsol,2},
                                     dudx::AbstractArray{Tres,3},
                                     work::AbstractArray{Tres,3},
                                     res::AbstractArray{Tres,2}
                                     ) where {AbstFE,Tsol,Tres,!IsTwoPoint{Tphys}}
  flux = sview(work,:,:,1)
  for di = 1:physics.ndim
    calcVolumeFlux!(physics, di, q, dudx, flux)
    weakDifferentiateElement!(fem, di, flux, res, Subtract(), transpose=true)
  end
end                              
```



### Helper functions for evaluating the residual

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

Returns either `u` if collocation or `elem_work` if not.
```
function interpToQuadPts(fem::AbstFE, u::AbstractArray{Tsol,2},
                         elem_work::AbstractArray{Twrk,2}) where {Tsol,Twrk,IsCollocation{AbstFE}}
    return u
end

function interpToQuadPts(fem::AbstFE, u::AbstractArray{Tsol,2},
                         elem_work::AbstractArray{Twrk,2}) where {Tsol,Twrk,!IsCollocation{AbstFE}}
    interpToQuadPts(fem, u, elem_work) # change name
    return elem_work
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
