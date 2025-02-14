#' A Function That Exports Tables and/or SEM Digrams based on dySEM models
#'
#' This function takes the  model from fitted dySEM() scripts and
#' exports table(s) and/or a path diagram figure of expected output. Currently
#' only working for dyadCFA() and apimSEM() models.
#'
#' @param dvn input object from dyadVarNames()
#' @param model character input specying type of model to output (e.g., "cfa", "apim", "cf")
#' @param fit input object from fitted lavaan model
#' @param table logical input of whether table output is desired. Default is TRUE
#' @param tabletype character input of what type of table(s) is(are) desired.
#' .data$options are "measurement" (i.e,, slopes, intercepts, and [.data$optionally] dMACS),
#' "slopes" (i.e., latent slopes, such as actor/partner effects), or "both"
#' (i.e., both measurement and slope tables)
#' @param figure logical input of whether figure output is desired. Default is TRUE
#' @param figtype character input of what type of figure is desired.
#' @param dydMACS.x .data$optional input of saved output from dydMACS() for x variable, to be included
#' in tabletype = "measurement" output
#' @param dydMACS.y .data$optional input of saved output from dydMACS() for y variable, to be included
#' in tabletype = "measurement" output
#' @return Ignore console (prints unneccessary semPlot::semPaths details). More importantly,
#' prints word files for the table(s) and/or figure, outputed to the users working directory
#' @seealso \code{\link{dyadVarNames}} \code{\link{apimSEM}} \code{\link{dydMACS}} which this function relies on
#' @export
#' @examples
#' dvn = dyadVarNames(dat, xvar="X", yvar="Y", sep = ".",
#' distinguish1 = "1", distinguish2 = "2")
#' apim.script.load = apimSEM(dvn, lvxname = "Conflict",
#' lvyname = "Satisfaction", model = "loading")
#' apim.fit.load <- lavaan::cfa(apim.script.load, data = dat, std.lv = FALSE,
#' auto.fix.first= FALSE, meanstructure = TRUE)
#' dyOutput(dvn, model = "apim", apim.fit.load, tabletype = "both", figtype = "unstandardized")

dyOutput = function(dvn, model = NULL, fit, table = TRUE, tabletype = NULL,
                    figure = TRUE, figtype = NULL,
                    dydMACS.x = NULL, dydMACS.y = NULL){
  dirs("output")
  if(model=="apim"){
    if(table==TRUE & figure == FALSE){
      dirs("output/tables")
      if(tabletype== "both"){
        #Make measurement parameter table
        #Extract intercepts
        xints <- xintercepts(dvn, fit)
        yints <- yintercepts(dvn, fit)
        int.list <- c(xints, yints)

        #Extract loadings, SEs, Z, p,
        measurement.param <- loadings(dvn, fit)
        measurement.param$Intercept = int.list
        measurement.param$'p-value'[measurement.param$'p-value' < .001] = "< .001"
        if(!is.null(dydMACS.x)&!is.null(dydMACS.y)){
          dmacs = c(dydMACS.x, rep(NA, dvn[[3]]), dydMACS.y, rep(NA, dvn[[8]]))
          measurement.param$dMACS = dmacs
        }
        measurement.param = measurement.param %>%
          dplyr::mutate_if(is.numeric, round, digits = 3)
        #Extract structural parameters
        structural.param = lavaan::parameterEstimates(fit, standardized=TRUE) %>%
          dplyr::filter(.data$op == "~") %>%
          dplyr::select('Outcome'=.data$lhs, Predictor=.data$rhs, Label = .data$label, Slope=.data$est, SE=.data$se,
                        'p-value'=.data$pvalue, '95%CI LL' = .data$ci.lower, '95%CI UL' = .data$ci.upper, Std.Slope=.data$std.all)
        structural.param = structural.param %>%
          dplyr::mutate_if(is.numeric, round, digits = 3)
        structural.param$'p-value'[structural.param$'p-value' < .001] = "< .001"


        measure = sjPlot::tab_df(measurement.param, title = "Measurement Model Parameters",
                                 file = sprintf("./output/tables/%s Measurement.doc",stringr::str_remove_all(as.character(fit@call$model), "[.]")
), alternate.rows = T)
        struct = sjPlot::tab_df(structural.param, title = "Structural Model Parameters",
                                file = sprintf("./output/tables/%s Structural.doc", stringr::str_remove_all(as.character(fit@call$model), "[.]")
), alternate.rows = T)
        tab.list = list(measure, struct)
        return(tab.list)
      }
      else if(tabletype== "measurement"){
        #Make measurement parameter table

        xints <- xintercepts(dvn, fit)
        yints <- yintercepts(dvn, fit)
        int.list <- c(xints, yints)

        #Extract loadings, SEs, Z, p,
        measurement.param <- loadings(dvn, fit)
        measurement.param$Intercept = int.list
        measurement.param$'p-value'[measurement.param$'p-value' < .001] = "< .001"
        if(!is.null(dydMACS.x)&!is.null(dydMACS.y)){
          dmacs = c(dydMACS.x, rep(NA, dvn[[3]]), dydMACS.y, rep(NA, dvn[[8]]))
          measurement.param$dMACS = dmacs
        }
        measurement.param = measurement.param %>%
          dplyr::mutate_if(is.numeric, round, digits = 3)

        measure = sjPlot::tab_df(measurement.param, title = "Measurement Model Parameters",
                                 file = sprintf("./output/tables/%s Measurement.doc",stringr::str_remove_all(as.character(fit@call$model), "[.]")
), alternate.rows = T)
        return(measure)
      }
      else if(tabletype== "slopes"){
        #Extract structural parameters
        structural.param = lavaan::parameterEstimates(fit, standardized=TRUE) %>%
          dplyr::filter(.data$op == "~") %>%
          dplyr::select('Outcome'=.data$lhs, Predictor=.data$rhs, Label = .data$label, Slope=.data$est, SE=.data$se,
                        'p-value'=.data$pvalue, '95%CI LL' = .data$ci.lower, '95%CI UL' = .data$ci.upper, Std.Slope=.data$std.all)
        structural.param = structural.param %>%
          dplyr::mutate_if(is.numeric, round, digits = 3)

        structural.param$'p-value'[structural.param$'p-value' < .001] = "< .001"

        struct = sjPlot::tab_df(structural.param, title = "Structural Model Parameters",
                                file = sprintf("./output/tables/%s Structural.doc", stringr::str_remove_all(as.character(fit@call$model), "[.]")
), alternate.rows = T)
        return(struct)
      }
    }
    else if(table==FALSE & figure == TRUE){
      dirs("output/figures")
      #Make path diagram
      if(figtype == "unstandardized"){
        semPlot::semPaths(fit, what = "est", whatLabels = "est", edge.label.cex = 0.5,
                          curvePivot = F, intercepts = F,
                          edge.color = "black", filetype = "png", filename = sprintf("output/figures/%s unstd", stringr::str_remove_all(as.character(fit@call$model), "[.]")
), weighted = F,
                          edge.label.position = .3, nCharNodes = 0, fixedStyle = c("black", 2))
      }
      else if(figtype == "standardized"){
        semPlot::semPaths(fit, what = "std", whatLabels = "std", edge.label.cex = 0.5,
                          curvePivot = F, intercepts = F,
                          edge.color = "black", filetype = "png", filename = sprintf("output/figures/%s std", stringr::str_remove_all(as.character(fit@call$model), "[.]")
), weighted = F,
                          edge.label.position = .3, nCharNodes = 0, fixedStyle = c("black", 2))
      }
      else if(figtype == "labels"){
        semPlot::semPaths(fit, what = "est", whatLabels = "names", edge.label.cex = 0.5,
                          curvePivot = F, intercepts = F,
                          edge.color = "black", filetype = "png", filename = sprintf("output/figures/%s lab", stringr::str_remove_all(as.character(fit@call$model), "[.]")
), weighted = F,
                          edge.label.position = .3, nCharNodes = 0, fixedStyle = c("black", 2))
      }
    }
    else if(table==TRUE & figure == TRUE){
      dirs("output/tables")
      dirs("output/figures")
      if(tabletype== "both"){
        #Make measurement parameter table

        #Extract intercepts
        xints <- xintercepts(dvn, fit)
        yints <- yintercepts(dvn, fit)
        int.list <- c(xints, yints)

        #Extract loadings, SEs, Z, p,
        measurement.param <- loadings(dvn, fit)
        measurement.param$Intercept = int.list
        measurement.param$'p-value'[measurement.param$'p-value' < .001] = "< .001"
        if(!is.null(dydMACS.x)&!is.null(dydMACS.y)){
          dmacs = c(dydMACS.x, rep(NA, dvn[[3]]), dydMACS.y, rep(NA, dvn[[8]]))
          measurement.param$dMACS = dmacs
        }
        measurement.param= measurement.param%>%
          dplyr::mutate_if(is.numeric, round, digits = 3)
        #Extract structural parameters
        structural.param = lavaan::parameterEstimates(fit, standardized=TRUE) %>%
          dplyr::filter(.data$op == "~") %>%
          dplyr::select('Outcome'=.data$lhs, Predictor=.data$rhs, Label = .data$label, Slope=.data$est, SE=.data$se,
                        'p-value'=.data$pvalue, '95%CI LL' = .data$ci.lower, '95%CI UL' = .data$ci.upper, Std.Slope=.data$std.all)
        structural.param = structural.param %>%
          dplyr::mutate_if(is.numeric, round, digits = 3)

        structural.param$'p-value'[structural.param$'p-value' < .001] = "< .001"

        measure = sjPlot::tab_df(measurement.param, title = "Measurement Model Parameters",
                                 file = sprintf("./output/tables/%s Measurement.doc",stringr::str_remove_all(as.character(fit@call$model), "[.]")
), alternate.rows = T)
        struct = sjPlot::tab_df(structural.param, title = "Structural Model Parameters",
                                file = sprintf("./output/tables/%s Structural.doc", stringr::str_remove_all(as.character(fit@call$model), "[.]")
), alternate.rows = T)
        tab.list = list(measure,struct)
      }
      else if(tabletype== "measurement"){
        #Make measurement parameter table
        #Extract intercepts
        xints <- xintercepts(dvn, fit)
        yints <- yintercepts(dvn, fit)
        int.list <- c(xints, yints)

        #Extract loadings, SEs, Z, p,
        measurement.param <- loadings(dvn, fit)
        measurement.param$Intercept = int.list
        measurement.param$'p-value'[measurement.param$'p-value' < .001] = "< .001"
        if(!is.null(dydMACS.x)&!is.null(dydMACS.y)){
          dmacs = c(dydMACS.x, rep(NA, dvn[[3]]), dydMACS.y, rep(NA, dvn[[8]]))
          measurement.param$dMACS = dmacs
        }
        measurement.param = measurement.param %>%
          dplyr::mutate_if(is.numeric, round, digits = 3)

        measure = sjPlot::tab_df(measurement.param, title = "Measurement Model Parameters",
                                 file = sprintf("./output/tables/%s Measurement.doc",stringr::str_remove_all(as.character(fit@call$model), "[.]")
), alternate.rows = T)
        tab.list = list(measure)
      }
      else if(tabletype== "slopes"){
        #Make measurement parameter table
        #Extract structural parameters
        structural.param = lavaan::parameterEstimates(fit, standardized=TRUE) %>%
          dplyr::filter(.data$op == "~") %>%
          dplyr::select('Outcome'=.data$lhs, Predictor=.data$rhs, Label = .data$label, Slope=.data$est, SE=.data$se,
                        'p-value'=.data$pvalue, '95%CI LL' = .data$ci.lower, '95%CI UL' = .data$ci.upper, Std.Slope=.data$std.all)
        structural.param = structural.param %>%
          dplyr::mutate_if(is.numeric, round, digits = 3)

        structural.param$'p-value'[structural.param$'p-value' < .001] = "< .001"

        struct = sjPlot::tab_df(structural.param, title = "Structural Model Parameters",
                                file = sprintf("./output/tables/%s Structural.doc", stringr::str_remove_all(as.character(fit@call$model), "[.]")
), alternate.rows = T)
        tab.list = list(struct)
      }
      #Make path diagram
      if(figtype == "unstandardized"){
        fig  = semPlot::semPaths(fit, what = "est", whatLabels = "est", edge.label.cex = 0.5,
                                 curvePivot = F, intercepts = F,
                                 edge.color = "black", filetype = "png", filename = sprintf("output/figures/%s unstd", stringr::str_remove_all(as.character(fit@call$model), "[.]")
), weighted = F,
                                 edge.label.position = .3, nCharNodes = 0, fixedStyle = c("black", 2))
      }
      else if(figtype == "standardized"){
        fig = semPlot::semPaths(fit, what = "std", whatLabels = "std", edge.label.cex = 0.5,
                                curvePivot = F, intercepts = F,
                                edge.color = "black", filetype = "png", filename = sprintf("output/figures/%s std", stringr::str_remove_all(as.character(fit@call$model), "[.]")
), weighted = F,
                                edge.label.position = .3, nCharNodes = 0, fixedStyle = c("black", 2))
      }
      else if(figtype == "labels"){
        fig = semPlot::semPaths(fit, what = "est", whatLabels = "names", edge.label.cex = 0.5,
                                curvePivot = F, intercepts = F,
                                edge.color = "black", filetype = "png", filename = sprintf("output/figures/%s lab", stringr::str_remove_all(as.character(fit@call$model), "[.]")
), weighted = F,
                                edge.label.position = .3, nCharNodes = 0, fixedStyle = c("black", 2))
      }
      out.list = list(tab.list, fig)
      return(out.list)
    }
  }
  else if(model=="cfa"){
    if(table==TRUE & figure == FALSE){
      dirs("output/tables")
      #Extract intercepts (xintercepts function works for single X or Y factor)
      xints <- xintercepts(dvn, fit)

      #Extract loadings, SEs, Z, p,
      measurement.param <- loadings(dvn, fit)
      measurement.param$Intercept = xints
      measurement.param$'p-value'[measurement.param$'p-value' < .001] = "< .001"

      if(!is.null(dydMACS.x)){
        dmacs = c(dydMACS.x, rep(NA, dvn[[3]]))
        measurement.param$dMACS = dmacs
      }
      else if(!is.null(dydMACS.y)){
        dmacs = c(dydMACS.y, rep(NA, dvn[[3]]))
        measurement.param$dMACS = dmacs
      }

      measurement.param = measurement.param %>%
        dplyr::mutate_if(is.numeric, round, digits = 3)

      measure = sjPlot::tab_df(measurement.param, title = "Measurement Model Parameters",
                               file = sprintf("./output/tables/%s Measurement.doc",stringr::str_remove_all(as.character(fit@call$model), "[.]")
), alternate.rows = T)
      return(measure)
    }
    else if(table==FALSE & figure == TRUE){
      dirs("output/figures")
      #Make path diagram
      if(figtype == "unstandardized"){
        semPlot::semPaths(fit, what = "est", whatLabels = "est", edge.label.cex = 0.5,
                          curvePivot = F, intercepts = F,
                          edge.color = "black", filetype = "png", filename = sprintf("output/figures/%s unstd", stringr::str_remove_all(as.character(fit@call$model), "[.]")
), weighted = F,
                          edge.label.position = .3, nCharNodes = 0, fixedStyle = c("black", 2))
      }
      else if(figtype == "standardized"){
        semPlot::semPaths(fit, what = "std", whatLabels = "std", edge.label.cex = 0.5,
                          curvePivot = F, intercepts = F,
                          edge.color = "black", filetype = "png", filename = sprintf("output/figures/%s std", stringr::str_remove_all(as.character(fit@call$model), "[.]")
), weighted = F,
                          edge.label.position = .3, nCharNodes = 0, fixedStyle = c("black", 2))
      }
      else if(figtype == "labels"){
        semPlot::semPaths(fit, what = "est", whatLabels = "names", edge.label.cex = 0.5,
                          curvePivot = F, intercepts = F,
                          edge.color = "black", filetype = "png", filename = sprintf("output/figures/%s lab", stringr::str_remove_all(as.character(fit@call$model), "[.]")
), weighted = F,
                          edge.label.position = .3, nCharNodes = 0, fixedStyle = c("black", 2))
      }
    }
    else if(table==TRUE & figure == TRUE){
      dirs("output/tables")
      dirs("output/figures")
      #Extract intercepts (xintercepts function works for single X or Y factor)
      xints <- xintercepts(dvn, fit)

      #Extract loadings, SEs, Z, p,
      measurement.param <- loadings(dvn, fit)
      measurement.param$Intercept = xints
      measurement.param$'p-value'[measurement.param$'p-value' < .001] = "< .001"

      if(!is.null(dydMACS.x)){
        dmacs = c(dydMACS.x, rep(NA, dvn[[3]]))
        measurement.param$dMACS = dmacs
      }
      else if(!is.null(dydMACS.y)){
        dmacs = c(dydMACS.y, rep(NA, dvn[[3]]))
        measurement.param$dMACS = dmacs
      }

      measurement.param = measurement.param %>%
        dplyr::mutate_if(is.numeric, round, digits = 3)

      measure = sjPlot::tab_df(measurement.param, title = "Measurement Model Parameters",
                               file = sprintf("./output/tables/%s Measurement.doc",stringr::str_remove_all(as.character(fit@call$model), "[.]")
), alternate.rows = T)

      tab.list = list(measure)

      #Make path diagram
      if(figtype == "unstandardized"){
        fig  = semPlot::semPaths(fit, what = "est", whatLabels = "est", edge.label.cex = 0.5,
                                 curvePivot = F, intercepts = F,
                                 edge.color = "black", filetype = "png", filename = sprintf("output/figures/%s unstd", stringr::str_remove_all(as.character(fit@call$model), "[.]")
), weighted = F,
                                 edge.label.position = .3, nCharNodes = 0, fixedStyle = c("black", 2))
      }
      else if(figtype == "standardized"){
        fig = semPlot::semPaths(fit, what = "std", whatLabels = "std", edge.label.cex = 0.5,
                                curvePivot = F, intercepts = F,
                                edge.color = "black", filetype = "png", filename = sprintf("output/figures/%s std", stringr::str_remove_all(as.character(fit@call$model), "[.]")
), weighted = F,
                                edge.label.position = .3, nCharNodes = 0, fixedStyle = c("black", 2))
      }
      else if(figtype == "labels"){
        fig = semPlot::semPaths(fit, what = "est", whatLabels = "names", edge.label.cex = 0.5,
                                curvePivot = F, intercepts = F,
                                edge.color = "black", filetype = "png", filename = sprintf("output/figures/%s lab", stringr::str_remove_all(as.character(fit@call$model), "[.]")
), weighted = F,
                                edge.label.position = .3, nCharNodes = 0, fixedStyle = c("black", 2))
      }
      out.list = list(tab.list, fig)
      return(out.list)
    }
  }
}

