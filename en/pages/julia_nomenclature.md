# Julia Nomenclature

Julia has some nomenclature that is useful for describing code and Julia constructs.

## Type
A user defined datatype.  The most commonly used kind are `struct` and
`mutable struct`.
Types contains other data types as its fields.  Types are useful for storing related data together.

## Type Annotation
A specification of the type of a variable.  The operator `::` is used.  For example

```
a::Float64
```

specifies that the variable `a` must have the type `Float64`.  If used in the body of a function or script (i.e. not in a function signature or type declaration) this inserts a run-time check to ensure the variable is of the specified type.

## Immutable (aka. `struct`)
An `struct` is a special kind of type that where the fields are constant.  Recalling that Mutable Types are stored as references, if an Immutable Type has a mutable type as a field, then the reference is constant (will always point to the same Mutable object), but the Mutable object itself is not constant (ie. its fields can still be modified).  For example, if an Immutable type has an array as a field, that field will always point to the same array, but the values in the array can change.
The fields of an Immutable type are potentially faster to access than fields of a Mutable type.

## isbits
An `isbits` type is a type that is completely defined by the bits store in the memory representation of the type.  Simple examples are the `Integer` types andthe `FloatingPoint` types.  The ones and zeros in memory complete describe the value of the object, so the type is `isbits`.  If a type is both Immutable and has only only `isbits` types as fields, than the type is also `isbits`.  Things that are accessed via reference, like arrays and Mutable types can never be `isbits`.  Knowing of something is `isbits` or not is useful when considering interoperability with C code.

## Functions and Methods
A function is a piece of code that is callable.  A function can have multiple methods, which are distinguished the number and types of their arguments.  A method cannot have multiple functions.  The purpose of a function having multiple methods is to allow it to have different implementations of the same behavior that vary depending on the provided arguments, although it is quite possible to have different behavior for different arguments as well.

## Multiple Dispatch
Multiple dispatch refers to using all the arguments to determine which method of a function to call.  Different languages have different rules for determining which method of a function to call.  Julia uses the number and types of all positional arguments.  Keyword arguments are not considered.

## Concrete Type
A general name of a specific type, usually a `struct` or `mutable struct`. The key characteristic is that these types have implementations and can be constructed into objects (that is, variables of the specified type).

## Abstract Type
Abstract types exist to specify the relationships between concrete types.  Abstract Types do not have implementations, they only have subtypes, which can be either abstract or concrete.  Concrete types cannot have subtypes.  A simple example of an abstract type is the Integer.  All the integer types (Int64, UInt64, Int32, UInt32 etc.) are subtypes of it.  More specifically, Integer has abstract subtypes Signed and Unsigned, and they have concrete subtypes that the various kinds of signed and unsigned integers.  Abstract types create the type hierarchy.

## Static Parameter
A static parameter is a parameter that is specified when an object is constructed and is part of the objects type.  For example:

```
type mytype{T}
a::T
end
```

defines a new type called `mytype` that has one field of type `T`, where `T` is a static parameter of `mytype`.
The utility of static parameters is that is allows the construction of many different types of objects, each with a specified value of `T`.
Because the static parameter is part of the type signature, the compiler will be able to specialize on that type.  Essentially, using static parameters
allows variability at run-time without sacrificing speed.  Static parameters are typically data types (ie. Float64, Int32 etc.), although they can be
any recursively immutable object (any immutable object whose fields are all immutable).
