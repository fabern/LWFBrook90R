% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/r_lwfbrook90.R
\name{r_lwfbrook90}
\alias{r_lwfbrook90}
\title{Interface function to the LWF-Brook90 model}
\usage{
r_lwfbrook90(
  siteparam,
  climveg,
  param,
  pdur,
  soil_materials,
  soil_nodes,
  precdat = NULL,
  output_log = TRUE
)
}
\arguments{
\item{siteparam}{A [1,6] matrix with site level information: start year, start doy,
latitude, initial snow, initial groundwater, precipitation interval.}

\item{climveg}{A matrix with 15 columns of climatic and vegetation data: year, month, day,
global radiation (MJ m-2 d-1), tmax (degC), tmin (degC), vappres (kPa), wind (m s-1), prec (mm), mesfl (mm),
densef (-), stand height (m), lai (m2 m-2), sai (m2 m-2), stand age (years).}

\item{param}{A numeric vector of model input parameters (for the right order see \code{\link{param_to_rlwfbrook90}}).}

\item{pdur}{a [1,12]-matrix of precipitation durations (hours) for each month.}

\item{soil_materials}{A matrix of the 8 soil materials parameters. When imodel = 1 (Mualem-van Genuchten), these refer to:
mat, ths, thr, alpha (m-1), npar, ksat (mm d-1), tort (-), stonef (-). When imodel = 2 (Clapp-Hornberger):
mat, thsat, thetaf, psif (kPa), bexp, kf (mm d-1), wetinf (-), stonef (-).}

\item{soil_nodes}{A matrix of the soil model layers with columns nl (layer number),
layer midpoint (m), thickness (mm), mat, psiini (kPa), rootden (-).}

\item{precdat}{A matrix of precipitation interval data with 6 columns:
year, month, day, interval-number (1:precint), prec, mesflp.}

\item{output_log}{Logical whether to print runtime output to console.}
}
\value{
A list containing the daily and soil layer model outputs (see \code{\link{runLWFB90}}.
}
\description{
Passes input data matrices to the Fortran model code and returns the results
}
