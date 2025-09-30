#' @title Generate synthetic data martix
#' @name genData
#' @description This function create complete data through a multiplication by a synthetic weigh matrix and factor matrix
#' @param n_features a number of features
#' @param n_samples a number of samples/observations
#' @param n_factors a number of factors
#' @param theta_z a probability of factor actication
#' @param theta_w a probability of weight actication
#' @param tau the precision for likelihood
#' @param tau_mode a character that can take the value of "perFeature" or None.
#' "perFeature" allows the noise to varied to degrees defined by "shape_noise" and "scale_noise" in a per-feature manner or by reference_df.
#' @param shape_noise the shape parameter of gamma distribution
#' @param scale_noise the scale parameter of gamma distribution
#' @param alpha_row intercepts are added to row level using a normal distribution. alpha_row is the loc parameter of this distribution.
#' @param sd_row intercepts are added to row level using a normal distribution. sd_row is the scale parameter of this distribution.
#' @param alpha_col intercepts are added to column level using a normal distribution. alpha_col is the loc parameter of this distribution.
#' @param sd_col intercepts are added to column level using a normal distribution. sd_col is the loc parameter of this distribution.
#' @return dataList
#' @import reticulate
#' @export
genData <- function(n_features = 200, n_samples = 50, n_factors = 5, theta_z = 1, theta_w = 1,
                    tau = 0, tau_mode = "perProt", shape_noise = 1.5, scale_noise = 1.5,
                    alpha_row = 0, sd_row = 1, alpha_col = 20, sd_col = 2){
  msbayesimputepy <- import("msbayesimputepy")
  dataList <- msbayesimputepy$generation$gen_data(n_features = as.integer(n_features), n_samples = as.integer(n_samples), n_factors = as.integer(n_factors),
                                                   theta_z = theta_z, theta_w = theta_w,
                                                   tau = tau, tau_mode = tau_mode, shape_noise = shape_noise, scale_noise = scale_noise,
                                                   alpha_row = alpha_row, sd_row = sd_row, alpha_col = alpha_col, sd_col = sd_col)
  return(dataList)
}

#' @title Generate synthetic data martix
#' @name genProbMiss
#' @description This function create complete data through a multiplication by a synthetic weigh matrix and factor matrix
#' @param X a complete input matrix, with features in rows and samples in columns
#' @param rho loc parameter for dropout model
#' @param zeta slope parameter for the drop-out model
#' @param model a character that can take the value of "global", "perFeature" or "perSample". "global" indicates generating missing values for all measurements using the same probabilistic.
#' "perFeature" and "perSample" allow the drop-out model parameter to varied to degrees defined by "rho_sd" and "zeta_sd" in a per-feature or per-sample manner.
#' @param rho_sd the degree (standard deviation in a normal distribution) the loc of the drop-out model can vary.
#' @param zeta_sd the degree (standard deviation in a normal distribution) the slope of the drop-out model can vary.
#' @param subSample if value is > 0 and < 1, features will be subsetted randomly by this percentage.
#' @param filter_threshold the cutoff for removing proteins within missingness
#' @return dataList
#' @import reticulate
#' @export
genProbMiss <- function(X, rho = 20, zeta = 2, model = "perFeature", rho_sd = 1, zeta_sd = 1, subSample = 0, filter_threshold = 0){
  msbayesimputepy <- import("msbayesimputepy")
  dataList <- msbayesimputepy$generation$gen_prob_miss(X = X, rho = rho, zeta = zeta, model = model,
                                                     rho_sd = rho_sd, zeta_sd = zeta_sd, subSample = subSample,
                                                     filter_threshold = filter_threshold)
  dataList$X_miss[is.nan(as.matrix(dataList$X_miss))] <- NA
  return(dataList)
}
