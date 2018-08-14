# Python Style Guide

Pythonistas primarily follow the [PEP-8 style guide](http://legacy.python.org/dev/peps/pep-0008/) from Python.org.  It isn't strictly necessary to read it entirely, but skimming the document is helpful.

Python follows a slightly different jargon than what we are used to from C++. It's closer to Java.

Instead of **objects**, Python has **classes**. These classes have member **attributes** and **methods**. These are equivalent to member variables and functions of C++ objects. 

**Variables** are generally considered to be free-floating ''instances'' of classes. For example, `x = 2.0` is an instance of the class `float` that is built into Python by default. That makes it an object of type "float" by C++ standards. 

Instead of **libraries**, Python has **modules**. Just like C++ libraries and header files, these modules contain pre-defined variables, functions, classes (and their member attributes and methods) that the user can take advantage of in their own code. For example, `solver = template.Simple(2)` is an instance of the class `Simple` that belongs to the **module** called `template`, created by the user. Here, `template.Simple()` is how the **namespace** of the module is called. Please refer to the Python documentation online on how these namespaces can be changed when importing a module into the source code.

## Naming Conventions

All names should be descriptive and ''readable''. One of Python's founding principles is to be understandable in plain text. It is effectively "pseudo code" that works. Keep this in mind when developing your code.

* **Variables** are `var_name`. They're always lowercase, and spacing is accomplished through underscores. ''Do not use'' `varName`. 
* **Attributes** can be made private by adding an underscore at the beginning, like `_var_name`. For attributes that have to be extra private, use two underscores. Otherwise, they follow the same convention as variables.
* **Functions** follow the same naming guide as variables. 
* **Methods** can be made private by adding an underscore at the beginning, like `_function_name`. Unlike variables, you should ''never'' use two underscores for functions.
* **Classes** are `ClassName`. This is called [Camel Case](http://en.wikipedia.org/wiki/CamelCase). 
* **Instances** of these classes follow variable naming conventions, and are always lower case, separated by underscores.

## Formatting Conventions

* **Indentations at the beginning of a line have meaning.** Do ''not'' use them for visual formatting. They are how Python distinguishes parent-member relationships.
* **Tabs are evil!** Always use four (4) spaces for indentation. Most advanced text editors allow you to configure the "tab" keystroke to register as four (4) spaces automatically.
* **Line breaks are line endings!** Unlike C++, Python has no special character for end-of-line. Simply hitting "Enter" will terminate your line. If you want to continue to the next visual line without a line break, use the backward-slash character `\` before hitting "Enter".
* **Keep each line under 80 characters.** Most advanced text editors will let you place a visual "ruler" at a particular column character.
* **Minimize vertical spaces.** They're only allowed to separate class and function/method definitions from each other.
* **Use horizontal spacing liberally.** Remember, Python code is supposed to be "pseudo code" that works. Make each line of your code easy to read in plain text.

## Commenting Conventions

We use the [NumPy/SciPy documentation standard](https://github.com/numpy/numpy/blob/master/doc/HOWTO_DOCUMENT.rst.txt) which is then automatically processed by [Sphinx](http://sphinx-doc.org/) into a searchable HTML manual. GitHub has the capability of publishing this online, and therefore all Python code should be hosted on our [GitHub team page](https://github.com/OptimalDesignLab).

### Files

Each Python file should start with a standard `__docstring__` as follows:

```python
"""This is a brief summary of the contents of this file."""
```

It should contain at a bare minimum a summary, but it can be expanded to include additional information about the file contents, such as inheritance information, dependencies and examples on how to use the file.

### Classes

Each Python class has its own `__docstring__` structured in accordance with the NumPy/SciPy conventions. This `__docstring__` should always include a list of the class' member attributes.

The parameters required to create an instance of this class can either be documented in the class `__docstring__` directly, or it can be documented inside the initialization method `__init__`. Our Python code so far has documented this in the class `__docstring__`, but the choice is yours. Sphinx is capable of processing either alternative, and produces the same output.

An example is given below:

```python
class Constrained(Simple):
    """Base class for analytical, constrained objective functions.

    Attributes
    ----------
    x : numpy.array
        Current design vector.
    obj : float
        Objective function value evaluated at x.
    cons : numpy.array
        Vector of constraint residuals.
    grad_d : numpy.array
        Gradient of the objective function with respect to the design point x.
    ceqjac_d : numpy.matrix
        Constraint jacobian with respect to design variables.

    Parameters
    ----------
    nDv : int
        Number of design variables.
    nCeq : int
        Number of equality constraints.
    """

    def __init__(self, nDv, nCeq):
        Simple.__init__(nDv)
        self.cons = np.zeros(nCeq)
        self.ceqjac_d = np.zeros((nCeq, nDv))
```

### Functions and Methods

Free-floating functions and class methods also have their own `_docstring_`. The structure of this is very similar to commenting classes. The only difference is that they do not have attributes, and instead can have outputs or exceptions. These are defined as `Returns` for outputs and `Raises` for exceptions.

```python
class Constrained(Simple):

    def axpby(self, a, x, b, y):
        """User-defined linear algebra method for scalar multiplication and vector addition.

        .. math:: a\mathbf{x} + b\mathbf{y}

        Parameters
        ----------
        a, b : float
            Multiplication coefficients.
        x, y : numpy.array
            Vectors to be operated on.

        Returns
        -------
        numpy.array : Linear combination of the given vectors.
        """
        return (a*x + b*y)
```

### Variables and Instances

These do not have their own `_docstring_`, and therefore any comments necessary for them should be standard in-line code comments. An example is given below:

```python
x = 2.0 # This is the comment for variable "x"
out = foo.bar(x) # This is the comment for a class method call
```


