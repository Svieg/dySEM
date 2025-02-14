#' A Function That Writes, Saves, and Exports Syntax for
#' Fitting Latent Dyadic Measurement and Invariance Models
#'
#' This function takes the outputted object from dyadVarNames()
#' and automatically writes, returns, and exports (.txt) lavaan() syntax
#' for specifying dyadic configural, loading, and intercept invariant
#' measurement models for either a specified X or Y factor.
#' @param dvn input object from dyadVarNames()
#' @param lvname input character to (arbitrarily) name LV in lavaan syntax
#' @param lvnum optional input character to indicate which LV is modeled ("one" or "two").
#' Only necessary if dvn contains both X and Y information and user wants CFA for Y
#' @param model input character used to specify which level of invariance is
#' modeled. Defaults to "configural"
#' @return character object of lavaan script that can be passed immediately to
#' lavaan functions
#' @seealso \code{\link{dyadVarNames}} which this function relies on
#' @export
#' @examples
#' dvn = dyadVarNames(dat, xvar="X", sep = ".",distinguish1 = "1", distinguish2 = "2")
#' con.config.script = dyadCFA(dvn, lvname = "Conflict", model = "configural")
#' con.loading.script = dyadCFA(dvn, lvname = "Conflict",  model = "loading")
#' con.intercept.script = dyadCFA(dvn, lvname = "Conflict",  model = "intercept")
dyadCFA = function(dvn, lvname, model = "configural"){
  dirs("scripts")
    if(model == "configural"){
      #Loadings
      eta_x1 = sprintf("%s%s =~ NA*",lvname, dvn[[4]])
      eta.x1 = gsub(" ", "",paste(eta_x1,paste(dvn[[1]], collapse = "+")), fixed = T)
      eta_x2 = sprintf("%s%s =~ NA*",lvname, dvn[[5]])
      eta.x2 = gsub(" ", "",paste(eta_x2,paste(dvn[[2]], collapse = "+")), fixed = T)

      #Latent (co)variances
      psi_x1 = sprintf("%s%s ~~ 1*%s%s",lvname, dvn[[4]],lvname, dvn[[4]])
      psi_x2 = sprintf("%s%s ~~ 1*%s%s",lvname, dvn[[5]],lvname, dvn[[5]])
      psi_x1x2 = sprintf("%s%s ~~ %s%s",lvname, dvn[[4]],lvname, dvn[[5]])

      #Correlated residuals
      resids = list()
      for (i in 1:dvn[[3]]) {
        resids[[i]]=sprintf("%s ~~ %s",dvn[[1]][i], dvn[[2]][i])
      }
      resids = paste(resids, collapse = "\n")

      #Intercepts
      xints1 = list()
      xints2 = list()
      for (i in 1:dvn[[3]]) {
        xints1[[i]]=sprintf("%s ~ 1", dvn[[1]][i])
        xints2[[i]]=sprintf("%s ~ 1", dvn[[2]][i])
      }
      xints1 = paste(xints1, collapse = "\n")
      xints2 = paste(xints2, collapse = "\n")

      #Script Creation Syntax
      configural.script = sprintf("#Loadings\n%s\n%s\n\n#(Co)Variances\n%s\n%s\n%s\n\n#Residuals\n%s\n\n#Intercepts\n%s\n%s", eta.x1, eta.x2, psi_x1, psi_x2, psi_x1x2, resids, xints1, xints2)
      cat(configural.script,"\n", file = sprintf("./scripts/%s_dyadic_configural.txt",lvname))
      return(configural.script)
    }
    else if (model == "loading"){
      #Loadings
      eta_x1 = sprintf("%s%s =~ NA*%s+",lvname, dvn[[4]], dvn[[1]][1])
      eta.x1 = list()
      for (i in 1:dvn[[3]]) {
        eta.x1[[i]]=sprintf("l%s*%s",i, dvn[[1]][i])
      }
      eta.x1 = gsub(" ", "",paste(eta_x1,paste(eta.x1, collapse = "+")), fixed = T)

      eta_x2 = sprintf("%s%s =~ NA*%s+",lvname, dvn[[5]], dvn[[2]][1])
      eta.x2 = list()
      for (i in 1:dvn[[3]]) {
        eta.x2[[i]]=sprintf("l%s*%s",i, dvn[[2]][i])
      }
      eta.x2 = gsub(" ", "",paste(eta_x2,paste(eta.x2, collapse = "+")), fixed = T)

      #Latent (co)variances
      psi_x1 = sprintf("%s%s ~~ 1*%s%s",lvname, dvn[[4]],lvname, dvn[[4]])
      psi_x2 = sprintf("%s%s ~~ NA*%s%s",lvname, dvn[[5]],lvname, dvn[[5]])
      psi_x1x2 = sprintf("%s%s ~~ %s%s",lvname, dvn[[4]],lvname, dvn[[5]])

      #Correlated residuals
      resids = list()
      for (i in 1:dvn[[3]]) {
        resids[[i]]=sprintf("%s ~~ %s",dvn[[1]][i], dvn[[2]][i])
      }
      resids = paste(resids, collapse = "\n")

      #Intercepts
      xints1 = list()
      xints2 = list()
      for (i in 1:dvn[[3]]) {
        xints1[[i]]=sprintf("%s ~ 1", dvn[[1]][i])
        xints2[[i]]=sprintf("%s ~ 1", dvn[[2]][i])
      }
      xints1 = paste(xints1, collapse = "\n")
      xints2 = paste(xints2, collapse = "\n")

      #Script Creation Syntax
      loading.script = sprintf("#Loadings\n%s\n%s\n\n#(Co)Variances\n%s\n%s\n%s\n\n#Residuals\n%s\n\n#Intercepts\n%s\n%s", eta.x1, eta.x2, psi_x1, psi_x2, psi_x1x2, resids, xints1, xints2)
      cat(loading.script,"\n", file = sprintf("./scripts/%s_dyadic_loading.txt",lvname))
      return(loading.script)
    }
    else if (model == "intercept"){
      #Loadings
      eta_x1 = sprintf("%s%s =~ NA*%s+",lvname, dvn[[4]], dvn[[1]][1])
      eta.x1 = list()
      for (i in 1:dvn[[3]]) {
        eta.x1[[i]]=sprintf("l%s*%s",i, dvn[[1]][i])
      }
      eta.x1 = gsub(" ", "",paste(eta_x1,paste(eta.x1, collapse = "+")), fixed = T)

      eta_x2 = sprintf("%s%s =~ NA*%s+",lvname, dvn[[5]], dvn[[2]][1])
      eta.x2 = list()
      for (i in 1:dvn[[3]]) {
        eta.x2[[i]]=sprintf("l%s*%s",i, dvn[[2]][i])
      }
      eta.x2 = gsub(" ", "",paste(eta_x2,paste(eta.x2, collapse = "+")), fixed = T)

      #Latent (co)variances
      psi_x1 = sprintf("%s%s ~~ 1*%s%s",lvname, dvn[[4]],lvname, dvn[[4]])
      psi_x2 = sprintf("%s%s ~~ NA*%s%s",lvname, dvn[[5]],lvname, dvn[[5]])
      psi_x1x2 = sprintf("%s%s ~~ %s%s",lvname, dvn[[4]],lvname, dvn[[5]])

      #Correlated residuals
      resids = list()
      for (i in 1:dvn[[3]]) {
        resids[[i]]=sprintf("%s ~~ %s",dvn[[1]][i], dvn[[2]][i])
      }
      resids = paste(resids, collapse = "\n")

      #Intercepts
      xints1 = list()
      xints2 = list()
      for (i in 1:dvn[[3]]) {
        xints1[[i]]=sprintf("%s ~ t%s*1", dvn[[1]][i], i)
        xints2[[i]]=sprintf("%s ~ t%s*1", dvn[[2]][i], i)
      }
      xints1 = paste(xints1, collapse = "\n")
      xints2 = paste(xints2, collapse = "\n")

      #Script Creation Syntax
      intercept.script = sprintf("#Loadings\n%s\n%s\n\n#(Co)Variances\n%s\n%s\n%s\n\n#Residuals\n%s\n\n#Intercepts\n%s\n%s", eta.x1, eta.x2, psi_x1, psi_x2, psi_x1x2, resids, xints1, xints2)
      cat(intercept.script,"\n", file = sprintf("./scripts/%s_dyadic_intercept.txt",lvname))
      return(intercept.script)
    }
}
