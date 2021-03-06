\name{MultiCCA}
\alias{MultiCCA}
\alias{print.MultiCCA}
\title{Perform sparse multiple canonical correlation analysis.}
\description{
Given matrices $X1,...,XK$, which represent K sets of features on the same
set of samples, find sparse $w1,...,wK$ such that $sum_(i<j) (wi' Xi' Xj wj)$ is large. If the
columns of Xk are ordered (and type="ordered") then wk will also be
smooth. For $X1,...,XK$, the
samples are on the rows and the features are on the columns. $X1,...,XK$
must have same number of rows, but may (and usually will) have different
numbers of columns. 
} 
\usage{
MultiCCA(xlist,  penalty=NULL, ws=NULL,
niter=25, type="standard", ncomponents=1, trace=TRUE, standardize=TRUE)
\method{print}{MultiCCA}(x,...)
}
\arguments{
  \item{xlist}{A list of length K, where K is the number of data sets on
    which to perform sparse multiple CCA. Data set k should be a matrix
    of dimension $n x p_k$ where $p_k$ is the number of features in data set
    k.}
  \item{penalty}{The penalty terms to be used. Can be a single
    value (if the same penalty term is to be applied to each data set)
    or a K-vector, indicating a different penalty term for each data
    set. There are 2 possible interpretations for the penalty terms: If
    type="standard" then this is an L1 bound on wk, and it  must be between 1 and
  $sqrt(p_k)$ ($p_k$ is the number of features in matrix Xk). If type="ordered" then
this is the parameter for the fused lasso penalty on wk. }
    \item{type}{Are the columns of $x1,...,xK$ unordered (type="standard") or
      ordered (type="ordered")? If "standard", then a lasso penalty is
      applied to v, to enforce sparsity. If "ordered" (generally used
      for CGH data), then a fused
      lasso penalty is applied, to enforce both sparsity and
      smoothness. This argument can be a vector of length K (if
      different data sets are of different types) or it can be a single
      value "ordered"/"standard" (if all data sets are of the same type).}
    \item{ncomponents}{How many factors do you want? Default is 1.}
  \item{niter}{How many iterations should be performed? Default is 25.}
  \item{ws}{A list of length K. The kth element contains the first ncomponents columns of the v matrix of the SVD of Xk. If
    NULL, then the SVD of $X1,...,XK$ will be computed inside the MultiCCA function. However, if
    you plan to run this function multiple times, then save a copy of
    this argument so that it does not need to be re-computed.}
  \item{trace}{Print out progress?}
  \item{standardize}{Should the columns of $X1,...,XK$  be centered (to have mean zero)
    and scaled (to have standard deviation 1)? Default is TRUE.}
  \item{x}{ not used.}
  \item{\dots}{ not used. } 
}
\value{
  \item{ws}{A list of length K, containg the sparse canonical variates
    found (element k is a $p_k x ncomponents$ matrix).}
  \item{ws.init}{A list of length K containing the initial values of ws used, by default these are the v
    vector of the svd of matrix Xk.}
}
\references{Witten, DM and Tibshirani, R and T Hastie (2008) A penalized
  matrix decomposition, with applications to
  sparse principal components and canonical correlation
  analysis. Submitted. <http://www-stat.stanford.edu/~dwitten>}
\author{Daniela M. Witten and Robert Tibshirani}
\seealso{\link{MultiCCA.permute},\link{CCA}, \link{CCA.permute}}
\examples{
# Generate 3 data sets so that first 25 features are correlated across
# the data sets...
u <- matrix(rnorm(50),ncol=1)
v1 <- matrix(c(rep(.5,25),rep(0,75)),ncol=1)
v2 <- matrix(c(rep(1,25),rep(0,25)),ncol=1)
v3 <- matrix(c(rep(.5,25),rep(0,175)),ncol=1)

x1 <- u\%*\%t(v1) + matrix(rnorm(50*100),ncol=100)
x2 <- u\%*\%t(v2) + matrix(rnorm(50*50),ncol=50)
x3 <- u\%*\%t(v3) + matrix(rnorm(50*200),ncol=200)

xlist <- list(x1, x2, x3)

# Run MultiCCA.permute w/o specifying values of tuning parameters to
# try.
# The function will choose the lambda for the ordered data set.
# Then permutations will be used to select optimal sum(abs(w)) for
# standard data sets.
# We assume that x1 is standard, x2 is ordered, x3 is standard:
perm.out <- MultiCCA.permute(xlist, type=c("standard", "ordered",
"standard")) 
print(perm.out)
plot(perm.out)
out <- MultiCCA(xlist, type=c("standard", "ordered", "standard"),
penalty=perm.out$bestpenalties, ncomponents=2, ws=perm.out$ws.init)
print(out)
# Or if you want to specify tuning parameters by hand:
# this time, assume all data sets are standard:
perm.out <- MultiCCA.permute(xlist, type="standard",
penalties=cbind(c(1.1,1.1,1.1),c(2,3,4),c(5,7,10)), ws=perm.out$ws.init)
print(perm.out)
plot(perm.out)

# Making use of the fact that the features are ordered:
out <- MultiCCA(xlist, type="ordered", penalty=.6)
par(mfrow=c(3,1))
PlotCGH(out$ws[[1]], chrom=rep(1,ncol(x1)))
PlotCGH(out$ws[[2]], chrom=rep(2,ncol(x2)))
PlotCGH(out$ws[[3]], chrom=rep(3,ncol(x3)))
}

