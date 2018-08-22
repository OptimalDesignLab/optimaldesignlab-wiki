# Julia Concepts and Performance

This page describes some features of Julia that are particularly important
for writing the kind of code this lab writes.  Studying these examples
should give you a better understand of Julia itself, and how to write
faster code.

Each example in this page can be copied into a source file and run in Julia
Readers are encouraged to do so and to experiment with these examples to
make sure they understand the concepts.



## Mutable vs immutable
```julia
println("\n\nMutable vs Immutable")

struct Foo  # immutable
  a::Int
end

mutable struct Bar # muable
  a::Int
end

function sumit(arr::AbstractVector)

  val = 0
  for i=1:length(arr)
    val += arr[i].a
  end

  return val
end


N = 100000
arr_foo = Array{Foo}(N)  # this is an array of Foo objects stored contiguously
                         # in memory
arr_bar = Array{Bar}(N)  # this is an array of pointers to Bar objects
for i=1:N
  arr_foo[i] = Foo(i)  # uses the space in the array for the new Foo object
  arr_bar[i] = Bar(i)  # allocates a Bar object on the heap writes the pointer
                       # array
                       # each object is allocated individually, and is likely
                       # not near the any of the other objects in memory
end

println("\nWarm up time:")
@time sumit(arr_foo)
@time sumit(arr_bar)

println("\nFinal time:")
@time sumit(arr_foo)
@time sumit(arr_bar)

# around 8-10x slower for the mutable struct
```

## Array allocation

```julia
println("\n\nArray Allocation")
using ArrayViews

function calcEulerFlux(q::AbstractVector, flux::AbstractVector)

  const gamma = 0.4  # const has no effect, but is helpfuler for other readers
  p = 0.4*(q[3] - 0.5*(q[2]*q[2] + q[3]*q[3])/q[1])

  flux[1] = q[2]
  flux[2] = q[2]*q[2]/q[1] + p
  flux[3] = q[2]*q[3]/q[1]
  flux[4] = (q[4] + p)/q[1]

  return nothing
end


function calcFlux1(q::AbstractArray, weights::AbstractVector, res::AbstractArray)

  # verify arrays are the right size
  @assert size(q, 1) == 4
  @assert length(weights) == 4
  @assert size(res, 1) == 4
  @assert size(q, 2) == size(res, 2)

  for i=1:size(q, 2)
    q_i = unsafe_aview(q, :, i)
    flux = Array{Float64}(4)  # new array is allocated inside the loop
    calcEulerFlux(q_i, flux)

    for j=1:4
      res[j, i] = weights[j]*flux[j]
    end
  end

  return nothing
end

function calcFlux2(q::AbstractArray, weights::AbstractVector, res::AbstractArray)

  # verify arrays are the right size
  @assert size(q, 1) == 4
  @assert length(weights) == 4
  @assert size(res, 1) == 4
  @assert size(q, 2) == size(res, 2)

  flux = Array{Float64}(4)  # new array is allocated outside the loop
  for i=1:size(q, 2)
    q_i = unsafe_aview(q, :, i)
    calcEulerFlux(q_i, flux)

    for j=1:4
      res[j, i] = weights[j]*flux[j]
    end
  end

  return nothing
end

N = 10000
q = rand(4, N)
weights = rand(4)
res = zeros(4, N)

println("\nWarm up time:")
@time calcFlux1(q, weights, res)
@time calcFlux2(q, weights, res)

println("\Final time:")
@time calcFlux1(q, weights, res)
@time calcFlux2(q, weights, res)

# first version is 3.6x slower than the second
```


## Slices allocate a temporary

```julia
println("\n\nSlice Allocation")

function copy1(arr_in::AbstractArray, arr_out::AbstractArray)

  @assert size(arr_in, 1) == size(arr_out, 1)
  @assert size(arr_in, 2) == size(arr_out, 2)

  for i=1:size(arr_in, 2)
    arr_out[:, i] = arr_in[:, i]  # using slices allocates a temporary array
  end

  return nothing
end

function copy2(arr_in::AbstractArray, arr_out::AbstractArray)

  @assert size(arr_in, 1) == size(arr_out, 1)
  @assert size(arr_in, 2) == size(arr_out, 2)

  for i=1:size(arr_in, 2)
    for j=1:size(arr_in, 1)  # extra for loop instead of arr[:, i]
      arr_out[j, i] = arr_in[j, i]
    end
  end

  return nothing
end


N = 10000
q_in  = rand(4, N)
q_out = rand(4, N)

println("\nWarm up time:")
@time copy1(q_in, q_out)
@time copy2(q_in, q_out)

println("\nFinal time:")
@time copy1(q_in, q_out)
@time copy2(q_in, q_out)

# first version is 25x slower
```

## Pass-by-sharing

```julia
println("\n\nPass-by-sharing")

mutable struct FooInner  # mutable object to be stored inside other objects
  i::Int
  j::Int
end

struct Foo1
  a::Int
  inner::FooInner
  arr::Array{Int, 1}
end

mutable struct Bar1
  a::Int
  inner::FooInner
  arr::Array{Int, 1}
end

function test_foo1(obj::Foo1)

  obj.a = 1  # error: cannot mutate Foo1
  obj.inner = FooInner(1, 2)  # error: cannot mutate Foo1.  Mutable objects
                              # are allocated on the heap and pointers to them
                              # are stored inside other object (structs,
                              # mutable structs, and arrays).  Because Foo1
                              # is immutable, the pointer cannot be changed
                              # to point to a different object
  obj.inner.i = 1 # ok: even though Foo1 is immutable, FooInner is mutable

  obj.arr = Array{Int,}(3)  # error: arrays are like mutable structs, the
                            # pointer stored inside Foo1 cannot be changed
                            # to point to a different object
  obj.arr[1] = 2  # assigning to an element of an array mutates that object
                  # just like obj.inner.i mutates FooInner but not Foo1

  return nothing
end

function test_bar1(obj::Bar1)

  obj.a = 1 # ok: Bar1 is mutable, so the value can change
  obj.inner = FooInner(1, 2)  # ok: Bar1 is mutable so the pointer to the
                              # FooInner object can be modified
  obj.inner.i = 1  # ok, FooInner is mutable
  obj.arr = Array{Int}(3)  # ok: creates a new array and assigns it to
                           # obj.arr (updating the pointer to point to a new
                           # object).  The old array will be deallocated if
                           # there are no other references to it
  obj.arr[1] = 1  # ok: arr is mutable

  return nothing
end
```


## Variables are names, best to think about the underlying values

```julia
println("\n\nVariables are names, better to think about the values")

function test_foo2()

  a = Bar1(1, FooInner(1, 2), rand(Int, 2))
  b = a  # b refers to Bar1(1, FooInner(1, 2), rand(Int, 2))
  c = b  # c refers to the Bar1(1, FooInner(1,2), rand(Int, 2))  (there is only 1 object
  b = Bar1(2, FooInner(2, 3), rand(Int, 3))
  # c still points to the Array{Int}(2)
  # this can be verified by printing out c.a and b.a


  # immutables have the same semantics as mutables
  d = Foo1(1, FooInner(1, 2), rand(Int, 2))
  f = d
  g = f
  f = Foo1(2, FooInner(2, 3), rand(Int, 3))
  # c still refers to Foo1(1, FooInner(1, 2), rand(Int, 2))
  # to see this
  d.inner.i = 5
  println("d.inner.i = ", d.inner.i)
  println("g.inner.i = ", g.inner.i)
  println("f.inner.i = ", f.inner.i)

  # as a special case, consider an immutable that contains only immutable fields
  m = FooInner(1, 2)
  n = m
  # do m and n refer to the same FooInner object?  There is no way to know.
  # The only way to find it is to change one of hte fields of m and see if
  # the same field in n also changes.  But that is impossible because
  # m.a = 2 is an error, precisely because FooInner is immutable.
  # Therefore, the compiler is free to do whatever it thinks is fastest.
  # Structs such as FooInner, which are immutable and do not contain mutable
  # fields, either directly or indirectly through one of their fields,
  # are calles "isbits" types, because they are defined completely by the
  # bits they occupy in memory (ie. they do not contain references to
  # objects elsewhere in memory).

  return nothing
end

test_foo2()
```

## Indexing is mutation not assignmnet

```julia
println("\n\nIndexing is mutation, not assignment")

function indexing1(arr_in::AbstractVector, arr_out::AbstractVector)

  for i=1:4
    arr_in[i] = arr_out[i]
  end

  # this is equivalent to
  for i=1:4
    tmp = arr_in[i]
    setindex!(arr_out, tmp, i)
  end

  # which is equivalent to
  for i=1:4
    tmp = getindex(arr_in, i)
    setindex!(arr_out, tmp, i)
  end

  # it is important to understand that assigning to an element of an array
  # is not truely an assignment such as `a = 1` or foo.a = 1`.
  # The expression `arr_in[i] = tmp` should be parsed `arr_in( [i]= ) tmp`,
  # where `[args...]=` is another name for the function setindex!.
  # Index assignment just a function, and has behavior different than
  # regular assignment.  In fact, it is possible to create new array types
  # that have different behavior of setindex!, whereas it is not possible to
  # change the behavior of the assignment operator, which is defined by the
  # language itself.  The behavior of the assignment operator is closely
  # related to the concepts of mutability and immutability described in the
  # test_foo1 and test_bar1 functions.

  return nothing
end

arr_in = rand(4)
arr_out = zeros(4)
indexing1(arr_in, arr_out)
```



## Infix operations on arrays allocate new arrays

```
println("\n\nInfix operators allocate new arrays")

function infix_arrays()

  A = rand(3,3)  # create an array
  B = A*2  # creates a new array and makes B refer to that new array
  B = B*2  # creates another new array and make B refer to it.  The array
           # B referred to on the previous line will be freed the next time
           # the garbage collector runs.

  return B
end

function infix_arrays2(A::AbstractArray)

  B = A + 1  # add 1 to every element of A and store result in new array
  C = 2*B
  A = C  # this makes A refer to the array C.  It does not change the value
         # of A, which is still a matrix of all zeros.
         # if we wanted to update the matrix A refered to when the function
         # began, we need to mutate it, for example
         # for i=1:length(A)
         #   A[i] = C[i]
         # end

  return nothing
end

A = zeros(3, 3)
infix_arrays2(A)
```

What is the value of `A`?
It is still all zeros.  The third line of the function did not modify
the array created by `zeros(3, 3)`, it made the name `A` refer to a different
array inside the function.  This does not affect what `A` refers to outside
the function



## Compound operations are not first class

```julia
println("\n\nCompound operations are not first class")

function infix_compound1(A::AbstractArray)

  A *= 2  # this is equivalent to A = A * 2.  *= is not a function in Julia,
          # it is a syntax.  As a result, this does not modify the array
          # A referred to when the function began, it creates a new array
          # and makes A refer to it inside the function

  return nothing
end

A = zeros(3, 3) + 1
infix_compound1(A)
# A is still all ones

```

# Closures (aka. lambda functions)


It is possible to define a function inside another function.  This enables
the inner function to access to the local variables of the outer function.
This is particularly useful when working with functions that take other
functions as arguments.  For example, one way to write Newton's method is
to take a user function as an argument that computes the function value and
Jacobian.  In this way, the algorithm of Newton's method is separated from
the computation of the function value and Jacobian.

As an example, this is a *bad* way to write Newton's method:
(for this example we will allocate more memory than required, in order to
 increase code clarity)

```julia
println("\n\nClosures (aka Lambda functions)")

function newton_bad(x::AbstractVector)
# on entry, x contains the initial guess for the solution
# on exit, x contains the actual root

  f_val = compute_f(x)  # compute function value
  while ( norm(f_val) > 1e-13 )
    jac = compute_jacobian(x)
    delta_x = jac\f_val  # solve for update to x

    for i=1:length(x)
      x[i] -= delta_x[i]
    end

    # compute new function value
    f_val = compute_f(x)
  end

  return nothing
end
```

Here is the problem with this function: it can only solve one specific
rootfinding problem, the one defined by `compute_f` and `compute_jacobian`
What if we want to find the root of a different function?  We have to
write a new Newton's method function.
A better way to write this is

```julia
function newton_good(x::AbstractVector, compute_f::Function, compute_jacobian::Function)

  f_val = compute_f(x)  # compute function value
  while ( norm(f_val) > 1e-13 )
    jac = compute_jacobian(x)
    delta_x = jac\f_val  # solve for update to x

    for i=1:length(x)
      x[i] -= delta_x[i]
    end

    # compute new function value
    f_val = compute_f(x)
  end

  println("root found at: ", x)
  println("norm of function at root: ", norm(f_val))

  return nothing
end
```

This is better because now we can solve any rootfinding problem.  We must
pass in the functions `compute_f` and `compute_jac` as arguments.  So we can call
the same `newton_good` function to find the root of many different functions,
depending on the arguments.  With this in mind, we can now describe
lambda functions (also known as closures).  At first glance, one limitation
of `newton_good` is that they take a single argument, the vector `x`.
What if more information is needed to compute the function value of its
Jacobian?  Lets call this other data `other_data`.  It cannot be passed
into `compute_f` or `compute_jacobian` because `newton_good` calls them
with only one argument, the vector `x`.  Instead we define a function
`compute_f` and `compute_jacobian` inside another function:

```julia
mutable struct OtherData
  a::Int
  # any other fields required
end

function solve_newton(x::AbstractVector, other_data::OtherData)

  function compute_f(_x::AbstractVector)
    # this function takes only one argument, as required by newton_good

    x1 = x[1]^2 - other_data.a  # because this function is defined inside
                                # solve_newton, it has access to the local
                                # variables of `solve_newton`, including
                                # other_data
    x2 = x[2]^2 - other_data.a

    return [x1, x2]
  end

  function compute_jacobian(_x::AbstractVector)

    jac = zeros(2,2)
    jac[1, 1] = 2*x[1]
    jac[1, 2] = 0
    jac[2, 1] = 0
    jac[2, 2] = 2*x[2]

    return jac
  end

  # call newton_good, passing in the lambda functions
  newton_good(x, compute_f, compute_jacobian)

  return nothing
end


data = OtherData(2)
x0 = [5.0, 5.0]
solve_newton(x0, data)
```

In this example we have been careful to avoid reusing variable names when
defining lambda functions.  This is not necessary in general, but you should
read the section of the Julia manual on the scope of variables carefully.


# Abstract types as forward declarations


Julia requires types to be defined before they are used.  The statement seems
a bit obvious, but has a few subtle implications.
An obvious way to use types is to define a type and then define a function
that uses the type

```julia
println("\n\nAbstract types as forward declarations")
struct Foo2
  a::Int
  b::Int
end

function sum_foo2(foo::Foo2)

  return foo.a + foo.b
end

obj = Foo2(1, 2)
sum_foo2(obj)  # returns 3
```

Note that we have specified the argument to the function `sum_foo` must be
of type `Foo2`.  A more subtle thing to do is:

```julia
function sum_foo3(foo)  # note: no type annotation for foo

  return foo.a + foo.b
end

struct Foo3
  a::Int
  b::Int
end

obj = Foo3(1, 2)
sum_foo3(obj)  # return 3
```

This is more interesting because at the time `sum_foo3` was defined, the
type `Foo3` did not exist yet.  Never-the-less, the Julia compiler is
able to compile `sum_foo3` for an argument of type Foo3.  Defining a function
that might operate on a given type does not count as a "use" of that type.
So the rule about defining before use does not apply.
An important detail is that the function is compiled the first time it is
run arguments of a particular type.  This is the reason all execution time
measurements in this file have been run twice: the first time to compile the
function, the second time to measure the execution time of the function.

What happens if we want to specify a type annotation for the argument of
`sum_foo3`.  Lets try this again with a new type, Foo4.  Consider the code:

```
function sum_foo4(foo::Foo4)  # this line is an error: Foo4 not defined

  return foo.a + foo.b
end

struct Foo4
  a::Int
  b::Int
end
```

Using the name of a type
in a type annotation is a "use" of the type, so the type must be defined
first.  On way to avoid this limitation is to specify an abstract type and
use it in the type annotation.  The concrete type can then be specified after
the function is defined.

```
abstract type AbstractFoo end

function sum_abstractfoo(foo::AbstractFoo)

  return foo.a + foo.b
end

struct Foo5 <: AbstractFoo  # make Foo5 a subtype of AbstractFoo
  a::Int
  b::Int
end

obj = Foo5(1, 2)
sum_abstractfoo(obj)  # returns 3
```

Because `sum_abstractfoo` requires its argument to be a subtype of
`AbstractFoo`, we can pass `Foo5` to it.  It is important to note that
`AbstractFoo` does not require its subtypes to have fields name `a` and `b`,
yet the function `sum_abstractfoo` will be an error if those fields do not
exist.  There is currently no language feature that requires type to have
certain fields or certain functions defined.  Therefore, it is very important
to document all the fields and functions a type is expected to have if it
is a subtype of an abstract type.
Unlike C++, there is no performance penalty for the type annotations to
function arguments.  In fact, the type annotations on function arguments
have no impact on how the function runs, they only have an impact on how the
compiler selects which method of a function to call (see Additional Details
for Parametric Types).

## Building Abstraction

A benefit to abstract types is that they enable a programmer to write a
single function that can operate on many types, provided all the (concrete)
types support the operations required by the abstract type.
As a simplified example, consider:

```
function mysum(a::Number, b::Number)  # note: abstract argument type annotations

  return a + b + a*b
end

# Number is an abstract type, all different kinds of numbers (real, complex,
# integer, etc.) are subtypes of it.  The function `mysum` works as long as
# the types of `a` and `b` have defined methods for + and * that are able
# to add and multiply the required types.

mysum(1, 2)  # returns an Int with value 3 (requires
             # (+)(::Int, ::Int)  and (*)(::Int, ::Int) be defined
mysum(1, 2.0)  # return a Float64 with value 3.0 (requires
               # (+)(::Int, ::Float64) and (*)(::Float64) be defined)
mysum(Complex128(1.0, 2.0), 2)  # return Complex128(3.0, 2.0), requires
                                # (+)(::Complex128, ::Int) and
                                # (*)(::Complex128, ::Int) be defined)
```

This is a simple example, but it generalizes into a very powerful idea in
programming.  If you know what operations an abstract type supports, it is
possible to write a single function that operates on many different
types, without knowing what the precise types are or what their internal data
is.  This is called generic programming, and there are many books on
the subject.  It is usually best to define a new type and then functions
(such as +, * etc.) that operate on that type first, and then write all
code in terms of those functions, rather than directly accessing the
field of the type.  Of course, some abstract types requires their subtypes
to have certain fields, in which case it is acceptable to access those
field directly.



## Additional details for parametric types

When working with parametric types there are a few additional considerations
that are not thoroughly mentioned in the manual.  Consider:

```julia
println("\n\nAdditional details for parametric types")
struct Foo6{T1, T2}
  a::T1
  b::Array{T2, 1}
end

function func_foo6(obj::Foo6{T1, T2}) where {T1, T2}

  t1 = zeros(T2, length(obj.b))  # must use T2 as the element type of the
                                 # temporary array t1
  for i=1:length(obj.b)
    t1[i] = obj.b[i] + 1  # setindex will convert the result of the right hand
                          # side expression to the element type of array t1
  end

  t2 = zeros(T2, length(obj.b))  # used T2 as element type
  for i=1:length(obj.b)
    t2[i] = obj.b[i] + obj.a  # this assumes that the sum of T1 and T2 can be
                              # converted to T2.  This may not always be
                              # possible, for example if obj.a is a complex
                              # number with non-zero imaginary part, it cannot
                              # be converted to a real number.
  end

  # A better way to do this is
  T3 = promote_type(T1, T2)  # get a type large enough to represent both a
                             # T1 and a T2
  t3 = zeros(T3, length(obj.b))
  for i=1:length(obj.b)
    t3[i] = obj.b[i] + obj.a  # now this is guaranteed to work
  end

  # There is more type conversion machinery in Julia base, such as promote_op,
  # which is beyond the scope of this tutorial.

  return nothing
end

obj = Foo6(1, [1.0, 2.0])
func_foo6(obj)

# this would not work because the sum is not convertable to T2
#obj = Foo6( Complex128(1.0, 2.0), [1.0, 2.0])
#func_foo6(obj)

# Another point which is briefly mentioned in the Julia manual is duck typing.
# When writing a parametric function, it is not necessary to name all the
# type parameters of the argument types.  Any omitted type parameters are
# unconstrained.  For example

function foo6_duck1(obj::Foo6)  # this accepts a Foo6 object with any types as
                                # T1 and T2

  println("method 1 called")
end

function foo6_duck1(obj::Foo6{T1}) where {T1 <: Integer}
  # this accepts any Foo6 object where T1 is some kind of integer.
  # Any Foo6 that has T1 not an integer will go to the first method.

  println("method 2 called")
end

function foo6_duck1(obj::Foo6{T1, T2}) where {T1 <: Integer, T2 <: AbstractFloat}
  # this method accepts any Foo6 object that has T1 as some kind of integer
  # and T2 as some kind of floating point number.  Any call to `foo6_duck1`
  # where T1 is an integer but T2 is not will go to method 2, and any
  # call that does not have T1 as an integer will go to method 1.
  # Consult the Julia manual on how to avoid creating ambiguous methods.

  println("method 3 called")

end

obj = Foo6(1.0, [1.0, 2.0])  # T1 is Float64, T2 is Float64
foo6_duck1(obj)              # prints "method 1 called"

obj = Foo6(1.0, zeros(Complex128, 3))  # T2 is Complex128 (not a subtype of
                                       # AbstractFloat
foo6_duck1(obj)                        # prints "method 1 called"

obj = Foo6(1, zeros(Complex128, 3))  # T1 is Int, T2 is Complex128
foo6_duck1(obj)                      # prints "method 2 called

obj = Foo6(1, zeros(Float64, 3))  # T2 in Float64
foo6_duck1(obj)  # print method 3 called
```
