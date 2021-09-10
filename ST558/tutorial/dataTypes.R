# Data types

# Numeric
x <- 2
x
class(x)
is.numeric(x)

# L means integer, integer is a subset of the numeric 
i <- 5L
class(i)
is.integer(i)
is.numeric(i)

class(4L) # yields "integer"
4L*2.8

5L/2L
class(5L/2L) # yields "numeric"

# Assign character type to variable
x <- "data"
x
class(x) # yields "character"

y <- factor("data")
y

# Check number of characters using nchar 
nchar(x)
nchar("hello")
nchar(3) # 1
nchar(452) # 3

nchar(y) #Error, because nchar does not work on factors

date1 <- as.Date("2012-06-28")
date1
class(date1)
as.numeric(date1) #15,519th day since the UNIX epoch of January 1, 1970

date2 <- as.POSIXct("2012-06-28 17:42")
date2
class(date2)

as.numeric(date2)

#logical, must be capitalized
TRUE # 1
FALSE# 0

TRUE*5 # = 5
FALSE*5 # = 0

k <- TRUE
k
class(k)
is.logical(k)

T
T <- 7
T
class(T)

2 == 3
2 != 3
2 < 3
2 <= 3
2 > 3
"data" == "stats"
"data" < "stats"

2+3
