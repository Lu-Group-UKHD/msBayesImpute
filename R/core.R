#' @title Train a msBayesImpute model and impute missing values
#' @name runMsBayesImpute
#' @description This function is called when the input data is prepared
#' @param miss_data the data should filter out complete missing proteins and normally distributed after e.g. logarithm transformation
#' @param n_components user can fix the number of components on their own; By default, the model can automatically filter out the insignificant factors
#' @param convergence_mode two convergence options: fast by default, and slow
#' @param drop_factor_threshold a threshold to filter out significant latent factors;By default, the values is 0.01
#' @return a list of a model and a data matrix
#' @import reticulate
#' @export
runMsBayesImpute <- function(miss_data, n_components = NULL, convergence_mode = "fast", drop_factor_threshold = 0.01, seed = NULL){
  msbayesimputepy <- import("msbayesimputepy")
  # check and convert to data frame
  if (!is(miss_data, "data.frame"))
    miss_data <- as.data.frame(miss_data)

  # initiate model
  if (!is.null(n_components)) n_components <- as.integer(n_components)
  if (!is.null(seed)) seed <- as.integer(seed)
  msBayes_model <- msbayesimputepy$core$msBayesImpute(n_components = n_components,
                                                      convergence_mode = convergence_mode,
                                                      drop_factor_threshold = drop_factor_threshold,
                                                      seed = seed)
  # run model
  msBayes_model$train(miss_data)
  imputed <- msBayes_model$predict(miss_data)
  imputed <- as.matrix(imputed)
  return(list("model" = msBayes_model, "data" = imputed))
}

#' @title Extract all parameters from the trained msBayes_model
#' @name getParams
#' @description This function output all parameters trained in msBayesImpute model
#' @param msBayes_model a msBayesImpute object
#' @param miss_data the data that is used for training msBayesImpute
#' @return params
#' @import reticulate
#' @export
getParams <- function(msBayes_model, miss_data){
  msbayesimputepy <- import("msbayesimputepy")
  # check and convert to data frame
  if (!is(miss_data, "data.frame"))
    miss_data <- as.data.frame(miss_data)

  # impute
  params <- msBayes_model$get_params(miss_data, output = "matrix")
  params <- c(params, list("rho" = msBayes_model$model$rho$numpy(),
                           "zeta" = msBayes_model$model$zeta$numpy()))
  return(params)
}

