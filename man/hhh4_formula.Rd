\encoding{latin1}
\name{hhh4_formula}
\alias{fe}
\alias{ri}

\title{
Specify Formulae in a Random Effects HHH Model
}

\description{
The special functions \code{fe} and \code{ri} are used to specify 
(unit-specific) effects of covariates and a random intercept term, 
respectively, in formulae used in the function \code{\link{hhh4}}.
}

\usage{
  fe(x, unitSpecific = FALSE, which = NULL, initial = NULL)

  ri(type = c("iid","car"), corr = c("none", "all"),
     initial.fe = 0, initial.var = -.5, initial.re = NULL)
}

\arguments{
  \item{x}{an expression like \code{sin(2*pi*t/52)} involving the time
    variable \code{t}, or just \code{1} for an intercept.
    In general this covariate expression might use any variables
    contained in the \code{control$data} argument of the parent
    \code{\link{hhh4}} call.}
  \item{unitSpecific}{logical indicating if the effect of \code{x}
    should be unit-specific. This is a convenient shortcut for
    \code{which = rep(TRUE, nUnits)}, where \code{nUnits} is the number
    of units (i.e., columns of the \code{"sts"} object).}
  \item{which}{vector of logicals indicating which unit(s)
    should get an unit-specific parameter.
    For units with a \code{FALSE}
    value, the effect term for \code{x} will be zero in the log-linear
    predictor. Note especially that setting a \code{FALSE} value for the
    intercept term of a unit, e.g.,
    \code{ar = list(f = ~-1 + fe(1, which=c(TRUE, FALSE)))}
    in a bivariate \code{hhh4} model, does \emph{not} mean that the
    (autoregressive) model component is omitted for this unit, but that
    \eqn{\log(\lambda_1) = \alpha_1} and \eqn{\log(\lambda_2) = 0}, which
    is usually not of interest. ATM, omiting an autoregressive effect for
    a specific unit is not possible.\cr
    If \code{which=NULL}, the parameter is assumed to be the same
    for all units.}
  \item{initial}{initial values (on internal scale!) 
    for the fixed effects used for optimization. The default
    (\code{NULL}) means to use zeroes.}
  \item{type}{random intercepts either follow an IID or a CAR model.}
  \item{corr}{whether random effects
   in different components (such as \code{ar} and \code{end})
   should be correlated or not.}
  \item{initial.fe}{initial value for the random intercept mean.}
  \item{initial.var}{initial values (on internal scale!) 
    for the variance components used for optimization.}
  \item{initial.re}{initial values (on internal scale!) for the random effects 
    used for optimization. The default \code{NULL} are random numbers
    from a normal distribution with zero mean and variance 0.001.}
}


\seealso{
\code{\link{addSeason2formula}}, 
usage of formulae in the vignette and in examples of \code{\link{hhh4}}.
}

\note{
This function should only be used in formula objects for \code{\link{hhh4}}, 
and is not intended for direct calling.

If unit-specific or random intercepts are specified, an overall
intercept must be excluded (by \code{-1}) in the component formula.
}

\keyword{regression}


\examples{
# some calls of the fitting function 'hhh4': 
# see vignette("hhh4") for further details

data("influMen")
fluMen <- disProg2sts(influMen)
meningo <- fluMen[, "meningococcus"]

## Ex: univariate time series of meningococcal infections in Germany
# Negative binomial model with
# endemic component: Intercept + S = 1 sine/cosine pair
# autoregressive component: Intercept

f.S1 <- addSeason2formula(f = ~ 1, S = 1, period = 52)
hhh4(meningo, list(
    ar = list(f = ~ 1),
    end = list(f = f.S1), 
    family = "NegBin1"
))


## Ex: disease-specific intercept in influenza/meningococcal time series
# Negative binomial model with
# autoregressive component: disease-specific intercepts
# neighbour-driven component: only transmission from flu to men
# endemic component: S=3 and S=1 sine/cosine pairs for flu and men, respectively

Wflumen <- neighbourhood(fluMen)
Wflumen["meningococcus","influenza"] <- 0
Wflumen
f.end <- addSeason2formula(f = ~ -1 + fe(1, which = c(TRUE,TRUE)), 
                           S = c(3, 1), period = 52)
f.end
m <- list(ar = list(f = ~ -1 + fe(1, unitSpecific = TRUE)),
          ne = list(f = ~ 1, weights = Wflumen),
          end = list(f = f.end),
          family = "NegBinM")
hhh4(fluMen, control = m)


\dontrun{
## Ex: (correlated) random intercepts for influenza in Southern Germany
# Negative binomial model with
# autoregressive component: Intercept
# neighbour-driven component: random intercepts
# endemic component: random intercepts + trend + S = 3 sine/cosine pairs

data("fluBYBW")
f.end <- addSeason2formula(f = ~ -1 + ri(type = "iid", corr="all") +
                                 I((t-208)/100), S = 3, period = 52)
wji <- neighbourhood(fluBYBW)/rowSums(neighbourhood(fluBYBW))
model.B2 <- list(ar = list(f = ~ 1),
                 ne = list(f = ~ -1 + ri(type = "iid", corr="all"), 
                           weights = wji),
                 end = list(f = f.end, offset = population(fluBYBW)),
                 family = "NegBin1", verbose = TRUE)
hhh4(fluBYBW, model.B2)
}
}
