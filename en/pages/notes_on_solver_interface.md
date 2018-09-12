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

## Temporal Discretization/Time Stepping


