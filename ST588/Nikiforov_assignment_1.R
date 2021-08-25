## Authored by Maksim Nikiforov
## August 21, 2021
## NCSU ST558, Fall 2021
## Assignment 1

## Part 1 - Vector practice

# 1. Use the seq or : function to create a vector from 0 to 100 in steps of 5. Save this to an R object called "skip"

skip <- seq(from = 0, to = 100, by = 5)

# 2. Add 8 to each element of the skip vector (just write code to print this to the console).

skip + 8

# 3. Square each element of the skip vector (just write code to print this to the console).

skip**2

# 4. Create a vector that is the skip vector repeated 8 times (hint: try the rep function and help(rep)). Save this to an R object called Repeat (Note that R is case sensitive!)

Repeat <- rep(skip, times = 8)

# 5. Create a vector that is the skip vector with each element repeated 8 times (0,0,0. . . ,0,5,5,. . . ) (check help(rep) again!). Save this to an R object called elementRepeat (Note the case!)

elementRepeat <- rep(skip, each = 8)

# 6. Add the Repeat and elementRepeat vectors together - how does R do addition of vectors? Answer this in a comment below the code.

Repeat + elementRepeat
## R performs element-wise summation for the two vectors. That is, the first element of Repeat is added to the first element of elementRepeat (0 + 0), the second element of Repeat is added to the second element of elementRepeat (5 + 0), and so on. 

# 7. Multiply together the vectors repeat and elementRepeat - how does R do multiplication of vectors? Answer this in a comment below the code.

Repeat * elementRepeat
## Again, the corresponding elements in each vector are multiplied together. The first element of Repeat is multiplied the first element of elementRepeat (0 * 0), the second element of Repeat is multiplied by the second element of elementRepeat (5 * 0), and so on.

# 8. Get every combination of a vector or vectors.

a <- c("a1", "a2")
b <- c("b1", "b2")
c <- c("c1", "c2", "c3")

expand.grid(a, b, c)

## Part 2 - Character vector practice

# 1. Create a character vector (call it adj) of length 4 consisting of adjectives (answers will vary).

adj <- c("enchanting", "whimsical", "auspicious", "scintillating")
## https://randomwordgenerator.com/adjective.php

# 2. Create a second character vector of same length consisting of nouns (call it nouns).

nouns <- c("engine", "science", "organization", "music")
## https://randomwordgenerator.com/noun.php

# 3. The two vectors can be "pasted" together elementwise using the paste() function. Do this and have R print the answer to the console.

paste(adj, nouns)

# 4. Paste them together but change the separator (sep) to be an underscore (see help(paste)). Have R print the answer to the console

paste(adj, nouns, sep = "_")

## Part 3 - Data Frame Practice

# 1. Determine which of our common data structures the ToothGrowth object is. Answer in a comment but give the code used to determine it.

str(ToothGrowth)
# ToothGrowth is a data frame with 60 observations and 3 variables.

# 2. Have R print out just the dose column using three different methods.

ToothGrowth$dose
ToothGrowth[[3]]
ToothGrowth[ , 3]

# 3. The first 30 observations are the VC group. Have R print out just the values of len and dose for the VC observations.

ToothGrowth[1:30, c("len", "dose")]

# 4. In a comment, describe the similarities and major difference between a matrix object in R and a data frame object in R.

## Matrices and data frames are similar in that they're both two-dimensional collections of vectors of the same length. Moreover, we can access their elements using single bracket notation (e.g. x[ , ]). They differ in that everything in a matrix is of the same type, whereas data frames can contain mixed object types (e.g. a mix of character and numeric vectors). 

# 5. Change the row names to be 61, 62, ..., 120 and change the len column of the ToothGrowth data set to length (you can get at the column names using names()). Print the first 10 rows of the data set out using the head function.

attributes(ToothGrowth)$row.names <- 61:120
names(ToothGrowth)[1] <- "length"
head(ToothGrowth, 10)
