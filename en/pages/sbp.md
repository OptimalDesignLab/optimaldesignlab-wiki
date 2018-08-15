[gimmick: math]()
# Summation-by-parts Operators

The lab develops and uses discretizations based on summation-by-parts (SBP) operators; therefore, the objective of this page is to introduce these operators and describe their salient characteristics.

## Definition of an SBP Operator

### Notation and Conventions

Before defining SBP operators formally, we need to introduce some notation and conventions.

In the following discussion, a quantity in bold font will denote a vector.  Usually, we will use such vectors to represent functions evaluated at specific points in space.  For example, suppose \\(u(x,y)\\) is a function defined for all \\((x,y) \in \Omega \subset \mathbb{R}^{2}\\), and we are interested in the value of \\(u\\) at some subset of points \\(S_{\Omega} \equiv \{(x_{i},y_{i})\}_{i=1}^{n} \subset \Omega\\).  The values of \\(u\\) evaluated at \\(S\\) will be denoted by the vector \\(\mathbf{u} \in \mathbb{R}^{n}\\) where
$$[\mathbf{u}]_{i} = u_i = u(x_i,y_i), \qquad \forall i=1,2,\ldots,n.$$

We will also introduce and use several matrices, which we will denote with san-serif type, e.g. \\(\mathsf{A} \in \mathbb{R}^{n\times n}\\).  Matrices represent the discretization of linear operators acting on functions like \\(u\\).  A relevant example is the partial derivative operator \\(\partial u/\partial x\\) evaluated at the points \\(S_{\Omega}\\), which can be represented as \\(\mathsf{D}_x \mathbf{u}\\).

Finally, in order to precisely define the accuracy of an SBP derivative operator, we need to indicate its action on a polynomial basis.  For example, a particular SBP operator might differentiate all polynomials up to total degree \\(p\\) exactly.  The polynomials of total degree \\(p\\) form a vector space, which we will denote by \\(\mathbb{P}^{p}\\).  There are an infinite number of different polynomials of degree \\(p\\), which would seem to complicate how we indiate the accuracy of derivative operator.  For example, in two spatial dimensions \\(\mathbb{P}^{2}\\) includes any polynomial of the form \\(a + bx + cy + dxy + ex^2 + fy^2\\), where the coefficients \\(a,b,c,d,e,f\\) can take on any values.  Fortunately, since \\(\mathbb{P}^{p}\\) is a finite-dimensional vector space, it has a basis, and it is sufficient to show that the derivative operator is exact for this basis.  

In two spatial dimensions, one possible polynomial basis for \\(\mathbb{P}^{p}\\) is given by the monomial set
$$\{p_{qr}(x,y) \equiv x^q y^r \;|\; q,r \geq 0, q+r \leq p\}$$.
In the defintiion below, it will be convenient to use a single index for the elements in the basis.  This can be achieved by ordering \\(q\\) and \\(r\\) in a particular way:
$$p_{k}(x,y) \equiv x^q y^r,\qquad k = \frac{q}{(q+1)}{2} + r + 1,\quad r \leq q.$$
For example, for \\(\mathbb{P}^{2}\\) we would have the following associations:
$$p_1(x,y) = 1,\quad p_2(x,y) = x, \quad p_3(x,y) = y,\quad
p_4(x,y) = x^2,\quad p_5(x,y) = xy, \quad p_6(x,y) = y^2.$$
Notice that the basis has \\((p+1)(p+2)/2\\) elements in two spatial dimensions.  More generally, in \\(d\\) dimensions the polynomial basis has \\({p+d}\choose{d}\\) elements.

### SBP Operator Defintion

In the following definition, \\(\mathbf{p}_{k}'\\) is the \\(x\\)-derivative of the polynomial \\(\mathbf{p}_{k}\\) evaluated at the nodes \\(S_{\Omega}\\).

**Definition: Two-dimensional summation-by-parts operator: Consider an open and
  bounded domain \\(\Omega \subset \mathbb{R}^{2}\\) with a piecewise-smooth boundary \\(\Gamma\\).  The matrix \\(\mathsf{D}_x\\) is a degree \\(p\\) SBP approximation to the first derivative \\(\frac{\partial}{\partial x}\\) on the nodes \\(S_{\Omega}=\left\{(x_{i},y_{i})\right\}_{i=1}^{n}\\) if

1. \\(\mathsf{D}_x \mathbf{p}_{k} = \mathbf{p}_k',\qquad\forall\; k \in \{ 1,2,\ldots,(p+1)(p+2)/2\\)
2. \\(\mathsf{D}_x = \mathsf{H}^{-1}\mathsf{Q}_{x}\\), where \\(\mathsf{M}\\) is symmetric positive-definite; and
3. \\(\mathsf{Q}_x = \mathsf{S}_x + \mathsf{E}_x\\), where \\(\mathsf{S}_x^T = -\mathsf{S}_x^T\\), \\(\mathsf{E}_x = \mathsf{E}_x^T\\), and \\(\mathsf{E}_x\\) satsifies 
$$\mathbf{p}_k^T \mathsf{E}_x \mathbf{p}_{m} = \oint_{\partial \Omega} p_k(x,y) p_m(x,y) n_x \,d\Gamma,\qquad \forall\; k,m \in \{1,2,\ldots,(r+1)(r+2)/2\}$$

where \\(r \geq p\\), and \\(n_x\\) is the \\(x\\) component of the outward pointing unit normal on \\(\partial \Omega\\).

Note: TODO, some notes about the above definition

## Strong and Weak forms of a PDE

One of the distinguishing features of SBP operators is that they are high-order approximations to both the strong and weak forms of a partial differential equation (PDE).  The terminology _strong_ and _weak_ is likely to be new to some readers, so we will review it now.

Note: Another term you may not be familiar with is _high-order_.  In CFD, high-order means that the truncation error depends on the mesh size to a power greater than two, e.g. \\(\mathsf{error} = \text{O}(h^4)\\), where \\(h\\) is some measure of the distance between mesh points, would be high-order accurate.

To discuss the strong and weak forms, we will consider a generic, conservation law defined over some domain \\(\Omega\\):
$$\frac{\partial F_i}{\partial x_i} = 0,\qquad \forall x \in \Omega,$$
where \\(F_i\\) is the flux in the \\(i\\)th coordinate direction \\(x_i\\).  The above equation is called the strong form of the PDE.  It requires that the left-hand side be equal to zero at all points in the domain \\(\Omega\\).  It is called the strong form because it places _strong_ requirements on the differentiability of \\(F_i\\), and, therefore, on the solution to the PDE.

Now, suppose the strong form of the PDE, listed above, is satisfied.  Then we can multiply the left- and right-hand sides by any bounded function \\(v \in L^{\infty}(\Omega)\\) and get
$$v \frac{\partial F_i}{\partial x_i} = 0,\qquad \forall x \in \Omega.$$
If we now integrate the above expression over the domain and integrate by parts, we get the following:
$$-\int_{\Omega} \frac{\partial v}{\partial x_i} F_i \, d\Omega + \int_{\partial \Omega} v F_i n_i \, d\Gamma = 0, \qquad \forall v \in  L^{\infty}(\Omega),$$
where \\(n_i\\) denotes the outward pointing unit normal on the boundary \\(\partial \Omega\\).  

To arrive at the weak form of the PDE, we make a subtle, but important, change to the above integral statement.  Rather than requiring that the function \\(v\\) have a bounded infinity norm, we instead require the _weaker_ condition that \\(v \in H^{1}(\Omega)\\), where \\(H^{1}(\Omega)\\) denotes the Hilbert space of all functions whose first-partial derivatives are bounded in the \\(L^2(\Omega)\\) norm.  That is, a weak solution to the conservation law satisfies
$$-\int_{\Omega} \frac{\partial v}{\partial x_i} F_i \, d\Omega + \int_{\partial \Omega} v F_i n_i \, d\Gamma = 0, \qquad \forall v \in  H^{1}(\Omega).$$

Why go to the trouble of defining the weak form of the PDE?  One reason is to handle discontinous solutions, such as shocks that arise in gas dynamics.  The strong form is not defined at discontinuities, but the weak form is.  More generally, the weak form can accommodate solutions that are less smooth than required by the strong form.

Note: While a solution to the strong form implies a solution to the weak solution, the converse is not true.  A weak solution may exist, e.g. a discontinuous solution, that does not satisfy the strong form of the PDE.

