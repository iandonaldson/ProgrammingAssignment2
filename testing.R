

source("cachematrix.R")



#testing - makeCacheMatrix

a.matrix <- matrix(c(4,3,3,2), nrow=2, ncol=2)
a.matrix
##      [,1] [,2]
##[1,]    4    3
##[2,]    3    2

this.matrix.cache <- makeCacheMatrix()
this.matrix.cache
names(this.matrix.cache)
##[1] "set"         "get"         "setinverted" "getinverted"

this.matrix.cache$set(a.matrix) 
this.matrix.cache$get()
##      [,1] [,2]
##[1,]    4    3
##[2,]    3    2

an.inverted.matrix <- solve(a.matrix)
an.inverted.matrix
##      [,1] [,2]
##[1,]   -2    3
##[2,]    3   -4

this.matrix.cache$setinverted(an.inverted.matrix)

this.matrix.cache$getinverted()
##      [,1] [,2]
##[1,]   -2    3
##[2,]    3   -4


#testing - cacheSolve

cacheSolve(this.matrix.cache)

another.matrix.cache <- makeCacheMatrix()

another.matrix.cache$set(a.matrix) 
another.matrix.cache$get()
##      [,1] [,2]
##[1,]    4    3
##[2,]    3    2


another.matrix.cache$getinverted()
##NULL

cacheSolve(another.matrix.cache)
##      [,1] [,2]
##[1,]   -2    3
##[2,]    3   -4
