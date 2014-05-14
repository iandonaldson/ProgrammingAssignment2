## 
# A basic description of how caching works is provided in the README.md file
# See the sections added by me:
# An explanation of makeVector - added by ian  
# and
# An explanation of cachemean - added by ian
# The exact same pricipals apply to the two functions below.
# Example usage of these functions (with example output) is shown in the file testing.R


## makeCacheMatrix
## This function returns a list of four functions that can act on 
## a provided matrix (or a NULL matrix if none is provided)
## all stored in a cache.
## set - sets the value of the matrix
## get - returns the matrix
## setinverted - sets the value of the inverted matrix
## getinverted - returns the inverted matrix
makeCacheMatrix <- function(thisMatrix = matrix()) {
  
    thisInvertedMatrix <- NULL

    set <- function(someMatrix) {
      thisMatrix <<- someMatrix
      thisInvertedMatrix <<- NULL
    }
    
    get <- function() thisMatrix
    
    setinverted <- function(someInvertedMatrix) thisInvertedMatrix <<- someInvertedMatrix
    
    getinverted <- function() thisInvertedMatrix
    
    list(set = set, get = get,
         setinverted = setinverted,
         getinverted = getinverted)
}



## cacheSolve
## A cached matrix (someMatrixCache) is passed to this function.  
## The inverse of the matrix is returned from the cache if it exists in the cache.
## Otherwise, the inverse is calculated, cached and returned.
cacheSolve <- function(someMatrixCache, ...) {
    
    ## Return a matrix that is the inverse of 'x'
    
    #look for it in cache
    thisInverseMatrix <- someMatrixCache$getinverted()
    if(!is.null(thisInverseMatrix)) {
      message("getting cached data")
      return(thisInverseMatrix)
    }
    
    #otherwise get the matrix, calculate its inverse and store it
    data <- someMatrixCache$get()
    thisInverseMatrix <- solve(data, ...)
    someMatrixCache$setinverted(thisInverseMatrix)
    return(thisInverseMatrix)

}
