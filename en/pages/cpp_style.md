# C++ Style Guide

## General Formatting Considerations

* Each line of text in your code should be at most 80 characters long.

* Put function calls on one line if it fits; otherwise, wrap arguments at the parenthesis.

## Naming conventions

All names should be descriptive and "readable".

* **Variables** are all lowercase, with words separated by an underscore: `cfd_mesh`
* **Function Parameters** follow the same convention as variables.
* **Functions** are lower [camel case]((http://en.wikipedia.org/wiki/CamelCase)): `setInitialCondition()`, `jacobiPoly()`
* **Member Functions** follow the same convention as functions.
* **Classes** are upper [camel case]((http://en.wikipedia.org/wiki/CamelCase)): `AdvectionIntegrator`, `AbstractSolver`.
<!-- * **Instances** of classes follow the same convention as variables. -->

## Indentation

Spaces should be used for indentation. Use three (3) spaces for indentation.

Indent every time there is a new scope created, except for the following exceptions: content inside of a namespace, preprocesser directives, and the private, protected, and public class labels. Ex:

<!-- ```c++
namespace mach
{

AbstractSolver::AbstractSolver(const string &opt_file_name)
{
   . . .
}

} // namespace mach
``` -->

```c++
void u0_function(const Vector &x, Vector& u0)
{
   u0.SetSize(1);
   double r2 = pow(x(0) - 0.5, 2.0) + pow(x(1) - 0.5, 2.0);
   r2 *= 4.0;
   if (r2 > 1.0)
   {
      u0(0) = 1.0;
   } 
   else
   {
      // the following is an expansion of u = 1.0 - (r2 - 1.0).^5
      u0(0) = 2 - 5*r2 + 10*pow(r2,2) - 10*pow(r2,3) + 5*pow(r2,4) - pow(r2,5);
   }
}
```

## Conditionals

Put a space between the "if", "while", or "switch" keyword and the condition. Avoid putting spaces between the parentheses and the condition.

When comparing a variable with a constant, put the constant on the left of the "==". This will generate a compiler error if you forget an equals sign, making debugging of this problem fairly trivial. Ex:

```c++
if (1 == x)
{
    // do stuff
}
else
{
    // do other stuff
}
```

## Braces

Put both the opening brace and closing braces on their own lines.

Always use braces for `if`, `for`, `while`, and the like, even if the content is only one statement. This helps prevent bugs when introducing more statements later on. Case blocks in switch statements do not require braces. Ex:

```c++
for (int i = 0; i < 10; ++i)
{
   for (int j = 0; j < 10; ++j)
   {
      // do something
   }
}
```

## Whitespace

Never put trailing whitespace at the end of a line.

Use one space on each side of binary operators.

Use spaces after keywords, but not functions and not keywords that act like functions. Do not add spaces inside parenthesized expressions. Ex:

This:

```c++
solver.setInitialCondition(u0_function);
```

**Not** this:

```c++
solver.setInitialCondition( u0_function );
```
