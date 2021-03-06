% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/msiterunLWFB90.R
\name{msiterunLWFB90}
\alias{msiterunLWFB90}
\title{Make a multi-site simulation using lists of climate, soil, options and parameter input objects.}
\usage{
msiterunLWFB90(
  param.b90,
  options.b90,
  climate,
  soil = NULL,
  all_combinations = FALSE,
  cores = 2,
  showProgress = TRUE,
  ...
)
}
\arguments{
\item{param.b90}{Named list of parameters to be used in all simulations, or a list of multiple parameter sets.}

\item{options.b90}{Named list of model control options to be used in all simulations}

\item{climate}{Data.frame with climate data, or a list of climate data.frames.}

\item{soil}{Data.frame with soil properties to be used in all simulations, or a list of data.frames with different soil profiles.}

\item{all_combinations}{Logical: Set up and run all possible combinations of
individual param.b90, climate and soil objects? Default is FALSE,
running one or the list of param.b90 for a series of climate/soil combinations.}

\item{cores}{Number of cores to use for parallel processing.}

\item{showProgress}{Logical: Show progress bar? Default is TRUE. See also section \code{Progress bar} below.}

\item{...}{Further arguments passed to \code{\link{runLWFB90}}.
It might be a good idea to pass \code{verbose=FALSE} to suppress excessive chatter of \code{runLWFB90}.}
}
\value{
A named list with the results of the single runs as returned by \code{\link{runLWFB90}}.
Simulation or processing errors are passed on. The names of the returned list entries
are concatenated from the names of the input list entries
in the following form: <climate> <soil> <param.b90>.
}
\description{
Wrapper function for \code{\link{runLWFB90}} to make multiple parallel simulations for combinations
of climate, soil, and parameters, e.g., for simulating one or several parameter sets
for a series of sites with individual climate and soil, or individual parameter set for each combination.
}
\section{Data management}{

The returned list of single run results can become very large, if many simulations are performed and
the selected output contains daily resolution datasets, especially daily layer-wise soil moisture data.
To not overload memory, it is advised to reduce the returned simulation results to a minimum, by
carefully selecting the output, and make use of the option to pass a list of functions to
\code{\link{runLWFB90}} (argument \code{output_fun}). These functions perform directly on the
output of a single run simulation, and can be used for aggrating model output on-the-fly,
or writing results to a file or database.
}

\section{Progress bar}{

This function provides a progress bar via the package \CRANpkg{progressr}
if \code{showProgress=TRUE}. The parallel computation is then wrapped with
\code{progressr::with_progress()} to enable progress reporting from
distributed calculations. The appearance of the progress bar (including
audible notification) can be customized by the user for the entire session
using \code{progressr::handlers()} (see \code{vignette('progressr-intro')}).
}

\examples{
options.b90 <- setoptions_LWFB90(budburst.method = "Menzel")

# define parameter sets
param_l <- list(spruce = setparam_LWFB90(maxlai = 5,
                                         budburst.species = "Picea abies (frueh)",
                                         winlaifrac = 0.8),
                beech = setparam_LWFB90(maxlai = 6,
                                        budburst.species = "Fagus sylvatica",
                                        winlaifrac = 0))

soil <- cbind(slb1_soil, hydpar_wessolek_tab(slb1_soil$texture))

# define list of soil objects
soils <- list(soil1 = soil, soil2 = soil)

# define list of climate objects
climates <- list(clim1 = slb1_meteo, clim2 = slb1_meteo)

# run two parameter sets on a series of climate and soil-objects
# (run = FALSE: 'dry' run without actual simulation, only input returned)
res <- msiterunLWFB90(param.b90 = param_l,
                      options.b90 = options.b90,
                      soil = soils,
                      climate = climates,
                      run = FALSE)
names(res)

# set up and run individual parameter sets for individual locations

# set up location parameters
loc_parm <- data.frame(loc_id = names(climates),
                       coords_y = c(48.0, 54.0),
                       eslope = c(30,0),
                       aspect = c(180,0))

# create input list of multiple param.b90 list objects
param_l <- lapply(names(climates), function(x, loc_parms) {
  parms <- setparam_LWFB90()
  parms[match(names(loc_parm),names(parms), nomatch = 0)] <-
    loc_parm[loc_parm$loc_id == x, which(names(loc_parm) \%in\% names(parms))]
  parms
}, loc_parm = loc_parm)

names(param_l) <- c("locpar1", "locpar2")

res <- msiterunLWFB90(param.b90 = param_l,
                      options.b90 = options.b90,
                      soil = soils,
                      climate = climates,
                      run = FALSE)
names(res)
}
