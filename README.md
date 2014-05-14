### Introduction

This second programming assignment will require you to write an R
function that is able to cache potentially time-consuming computations.
For example, taking the mean of a numeric vector is typically a fast
operation. However, for a very long vector, it may take too long to
compute the mean, especially if it has to be computed repeatedly (e.g.
in a loop). If the contents of a vector are not changing, it may make
sense to cache the value of the mean so that when we need it again, it
can be looked up in the cache rather than recomputed. In this
Programming Assignment you will take advantage of the scoping rules of
the R language and how they can be manipulated to preserve state inside
of an R object.

### Example: Caching the Mean of a Vector

In this example we introduce the `<<-` operator which can be used to
assign a value to an object in an environment that is different from the
current environment. Below are two functions that are used to create a
special object that stores a numeric vector and caches its mean.

## makeVector

The first function, `makeVector` creates a special "vector", which is
really a list containing a function to

1.  set the value of the vector
2.  get the value of the vector
3.  set the value of the mean
4.  get the value of the mean

<!-- -->

    makeVector <- function(x = numeric()) {
            m <- NULL
            set <- function(y) {
                    x <<- y
                    m <<- NULL
            }
            get <- function() x
            setmean <- function(mean) m <<- mean
            getmean <- function() m
            list(set = set, get = get,
                 setmean = setmean,
                 getmean = getmean)
    }

## An explanation of makeVector - added by ian
    
And here is how it is used

    inThisEnvironment <- makeVector()

makeVector returns a list of four functions.  

    names(inThisEnvironment)
    [1] "set"     "get"     "setmean" "getmea

We can access each of these functions using the $ notation:

    inThisEnvironment$set(1:10)

Importantly, all of these functions were created inside the same function; as a result, they all have the same environment.  That means that free variables in these functions will be searched for in this environment (which I have called "inThisEnvironment".  This is just a variable name - it could just as well be called "foo" or "a").

    inThisEnvironment$get()
    [1]  1  2  3  4  5  6  7  8  9 10
    
We can set up multiple versions of the same four functions, each with its own unique environment.

    inAseparateEnvironment <- makeVector()
    inAseparateEnvironment$set(11:20)
    inAseparateEnvironment$get()
    [1] 10 11 12 13 14 15 16 17 18 19 20

Finally, there are two other functions in each of these environments. We can set the mean

    inThisEnvironment$setmean(5.5)
    
And we can get the mean from that environment

    inThisEnvironment$getmean()
    5.5

We can take a closer look at how the variables are set in this environment.  I use `set` without the brackets to look at the function.

    > inThisEnvironment$set
    function(y) {
        x <<- y
        m <<- NULL
    }
    <environment: 0x7fa8f3043ff8>

The value of y (passed as a parameter to this function) will be assigned to x.
Importantly, the double arrow assignment operator is used.

You can find out more about an operator by using

    ?`<<-`
    
From the resulting manual page:


`"The operators <<- and ->> are normally only used in functions, and cause a search to made through parent environments for an existing definition of the variable being assigned. If such a variable is found (and its binding is not locked) then its value is redefined, otherwise assignment takes place in the global environment."`

In our case, the line `x <<- y` means that a search for x in the parent environment is performed before assignment.  The parent environment was created by the makeVector function and we can see that a variable called `x` is an argument to this function.  So it is this specific `x` variable whose value will be redefined by `y`.  I say "specific" because this value of `x` has a specific environment that is shared by all of the other functions created by the same call to the makeVector function.  This means that if any of these functions make a reference to `x`, then `x` will take on the value that was set by `y` (unless the function itself redefines `x`). 

This environment is referred to by R using an internal identifier: `<environment: 0x7fa8f3043ff8>` - that is part of the above function definition.

So, when we call the get function which looks like this:

    inThisEnvironment$get
    function() x
    <environment: 0x7fa8f3043ff8>

all it does is return the value of x that defined by the `set` function in the same environment.

The same principals apply to the explanation of the `setmean` and `getmean` functions.

# end explanation added by ian

## cachemean

The following function calculates the mean of the special "vector"
created with the above function. However, it first checks to see if the
mean has already been calculated. If so, it `get`s the mean from the
cache and skips the computation. Otherwise, it calculates the mean of
the data and sets the value of the mean in the cache via the `setmean`
function.

    cachemean <- function(x, ...) {
            m <- x$getmean()
            if(!is.null(m)) {
                    message("getting cached data")
                    return(m)
            }
            data <- x$get()
            m <- mean(data, ...)
            x$setmean(m)
            m
    }
    
    
## An explanation of cachemean - added by ian

Here is how cachemean would be used (following on with the above example)

    cachemean(inThisEnvironment)
    [1] 5.5

In this case, we already defined the value of the mean associated with this environment.  So this value is retuned to us using the lines

            m <- x$getmean()
            if(!is.null(m)) {
                    message("getting cached data")
                    return(m)
            }

    
Here, `x` is `inThisEnvironment` that we passed to the function.

But what if we had not defined the mean of our vector.  Lets start with a new vector in its own environment.

    > inAnewEnvironment <- makeVector(100:150)
    > cachemean(inAnewEnvironment)
    [1] 125

What happened here was that we created the vector `100:150` in its own private environment.  The function call to

    x$getmean()
    
will query this environment and find a NULL value.  The next few lines will then calculate the mean (in this environment) and return it to us. 


Subsequent calls to `cachemean(inAnewEnvironment)` will find this value (using the line `x$getmean()`) since it is now effectively cached in this environment as variable `m`.

# end explanation added by ian


### Assignment: Caching the Inverse of a Matrix

Matrix inversion is usually a costly computation and there may be some
benefit to caching the inverse of a matrix rather than computing it
repeatedly (there are also alternatives to matrix inversion that we will
not discuss here). Your assignment is to write a pair of functions that
cache the inverse of a matrix.

Write the following functions:

1.  `makeCacheMatrix`: This function creates a special "matrix" object
    that can cache its inverse.
2.  `cacheSolve`: This function computes the inverse of the special
    "matrix" returned by `makeCacheMatrix` above. If the inverse has
    already been calculated (and the matrix has not changed), then
    `cacheSolve` should retrieve the inverse from the cache.

Computing the inverse of a square matrix can be done with the `solve`
function in R. For example, if `X` is a square invertible matrix, then
`solve(X)` returns its inverse.

For this assignment, assume that the matrix supplied is always
invertible.

In order to complete this assignment, you must do the following:

1.  Fork the GitHub repository containing the stub R files at
    [https://github.com/rdpeng/ProgrammingAssignment2](https://github.com/rdpeng/ProgrammingAssignment2)
    to create a copy under your own account.
2.  Clone your forked GitHub repository to your computer so that you can
    edit the files locally on your own machine.
3.  Edit the R file contained in the git repository and place your
    solution in that file (please do not rename the file).
4.  Commit your completed R file into YOUR git repository and push your
    git branch to the GitHub repository under your account.
5.  Submit to Coursera the URL to your GitHub repository that contains
    the completed R code for the assignment.

### Grading

This assignment will be graded via peer assessment.
