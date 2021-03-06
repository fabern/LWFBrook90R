options(stringsAsFactors = F)

#Wessolek-MVG
wessolek_mvg_tab10 <- read.csv("data-raw/wessolek_MVG_tab10.csv")
wessolek_mvg_tab10$mpar <- 1-1/wessolek_mvg_tab10$n
wessolek_mvg_tab10$ksat <- wessolek_mvg_tab10$ksat*10
names(wessolek_mvg_tab10)[5] <- "npar"


hydpar_forestfloor <- data.frame(ths = 0.848, thr = 0, alpha = 98, npar = 1.191,
                         mpar=0.1603694, ksat = 98000,tort = 0.5, stringsAsFactors = F)


# # hypres tab
hypres_tab4 <- read.csv("H:/RProjects/PTF-Validierung/RESULTS1/PTF_tables&functions/HypresKlassPTF.csv", stringsAsFactor=F)
names(hypres_tab4) <- c("tex.hypres", "topsoil", "ths", "thr", "alpha", "npar","mpar","ksat", "tort")
hypres_tab4$topsoil <- as.logical(hypres_tab4$topsoil)
hypres_tab4 <- rbind(hypres_tab4, hypres_tab4[hypres_tab4$tex.hypres=="Org",])
hypres_tab4$topsoil[11] <- TRUE
row.names(hypres_tab4) <- NULL
#
# # teepe-table
# teepe_tables123 <- read.csv("data-raw/TeepePTF.csv", stringsAsFactors=F)
# str(teepe_tables123)
# names(teepe_tables123) <- c("bd.teepe", "tex.teepe", "AC", "AWC", "PWP", "mean_oc", "AC_surcharge",
#                             "AWC_surcharge","PWP_surcharge","ths", "n","alpha","thr")
# teepe_tables123$m <- 1-1/teepe_tables123$n
# teepe_tables123$thr <- teepe_tables123$thr/100
#devtools::use_data(teepe_tables123, hypres_tab4,wessolek_mvg_tab10,din4220_tabA1, internal =T, overwrite = T)

# Vignette data -----

library(LWFBrook90R)
library(data.table)
# b90res ---------------
options.b90 <- setoptions_LWFB90()
param.b90 <- setparam_LWFB90()
soil <- cbind(slb1_soil, hydpar_wessolek_tab(tex.KA5 = slb1_soil$texture))
output <- setoutput_LWFB90()

b90res <- runLWFB90(options.b90 = options.b90,
                    param.b90 = param.b90,
                    climate = slb1_meteo,
                    soil = soil,
                    output = output, output.log = F)



# mrun_res -------------
# Agg-Function

output_function <- function(x) {
  # aggregate SWAT
  swat_tran <- x$SWATDAY.ASC[which(nl <= 14),
                             list(swat100cm = sum(swati)),
                             by  = list(dates = as.Date(paste(yr, mo, da, sep = "-")))]
  #add transpiration from EVAPDAY.ASC
  swat_tran$tran <- x$EVAPDAY.ASC$tran
  return(swat_tran)
}

N=50
paramvar <- data.frame(maxlai = runif(N, 4,7),
                       glmax = runif(N,0.003, 0.01))

mrun_res <- mrunLWFB90(paramvar = paramvar,
                       param.b90 = param.b90,
                       cores = 3,
                       options.b90 = options.b90, # the following args are passed to runLWFB90
                       climate = slb1_meteo,
                       soil = soil,
                       output = output,
                       rtrn.input = F, rtrn.output = F,
                       output_fun = output_function,
                       output.log = F, verbose = F)

mrun_dt <- rbindlist(lapply(mrun_res, function(x) x$output_fun[[1]]),
                     idcol = "singlerun")




#speichert den Dataframe als internes Objekt, welches nicht exportiert wird. ANsprechen mit brook90r:::wess_mvg_tex
usethis::use_data(mrun_dt, b90res, wessolek_mvg_tab10,hydpar_forestfloor, hypres_tab4, internal = T, overwrite =T)

