#' Create boxplot standardize with IMPACT style
#'
#' @param .data:  data that contains the statistical result to build boxplots
#' @param x: element of .data that contains the different values of the categorical data
#' @param name.y: name of value calculated
#' @param median: element of .data containing the median values
#' @param first_quantile: element of .data containing lower hinges correspond to the first quartile
#' @param third_quantile: element of .data containing upper hinges correspond to the third quartile
#' @param whisker_min: element of .data containing the value of the lower whisher. Usually calculated as 1.5*IQR smallest value from the hinge
#' @param whisker_max: element of .data containing the value of the upper whisher. Usually calculated as 1.5*IQR largest value from the hinge
#' @param outlier_min (optional): element of .data containing the most extreme value beyond the lower whisper.
#' @param outlier_max (optional): element of .data containing the most extreme value beyond the upper whisper.
#' @param sens.boxplot (optional): if sens.boxplot = "vertical" (default) boxplots are build with vertical cartesian coordinates. If sens.boxplot="horizontal" flip cartesian coordinates so that vertical becomes horizontal
#' @details Create a plot with one or multiple boxplot standardize with IMPACT colors, fonts, ... for the same numerical variable
#' @return a ggplot object contaning a boxplot
#' @export
boxplot_impact <- function(.data, x, name.y, median, first_quantile, third_quantile, whisker_min, whisker_max, outlier_min = NULL, outlier_max = NULL, sens.boxplot = "vertical"){

  ## Quote the parameters
  x <- enquo(x)
  median <- enquo(median)
  first_quantile <- enquo(first_quantile)
  third_quantile <- enquo(third_quantile)
  whisker_min <- enquo(whisker_min)
  whisker_max <- enquo(whisker_max)
  outlier_min <- enquo(outlier_min)
  outlier_max <- enquo(outlier_max)

  ## Check and return message if empty evironnement
  stop_msg <- error_message_empty_env_boxplot( x, subset.x=NULL, median, whisker_min, whisker_max, first_quantile, third_quantile, outlier_min, outlier_max)
  if(stop_msg != ""){
    stop(paste0("The variable(s) following does not exist in .data: ",stop_msg))
  }

  if(sens.boxplot != "vertical" & sens.boxplot != "horizontal"){
    stop("Please enter a valid value to the parameter sens.barchart: 'vertical' or 'horizontal'")
  }

  #No plot if variables are only NA
  check_contains_only_NA(x,.data)
  check_contains_only_NA(median,.data)
  check_contains_only_NA(first_quantile,.data)
  check_contains_only_NA(third_quantile,.data)
  check_contains_only_NA(whisker_min,.data)
  check_contains_only_NA(whisker_max,.data)

  nbre_box <-  length(unique(rlang::eval_tidy(x,.data)))
  # if(nbre_box > 20){
  #   warning("Too many variables. It is not going to fit correclty into the plot.")
  # }


  ## Create boxplot thanks to values already calculted and with IMPACT theme
  theplot <- ggplot(.data, aes(1, width = 0.5)) + geom_boxplot_impact(aes( x = !!x,
                                                       lower = !!first_quantile,
                                                       upper = !!third_quantile,
                                                       middle = !!median,
                                                       ymin = !!whisker_min,
                                                       ymax = !!whisker_max),
                                                  fill= reach_style_color_lightgrey()) +
                                    xlab("")+ylab(name.y) +
                                    theme_impact()

  ## Add statistic values of the boxplot on the graph
 # theplot <- add_stat_to_boxplot(theplot, x, whisker_min, whisker_max, median)

   ## Add outlier if exist (min and max values of dataset)
  if(rlang::quo_is_null(outlier_min) == FALSE){
    group=NULL
    theplot <- add_outlier_boxplot(theplot, x, outlier_min, type.boxplot = "ungrouped", group=enquo(group))
  }

  if(rlang::quo_is_null(outlier_max) == FALSE){
    group=NULL
    theplot <- add_outlier_boxplot(theplot, x, outlier_min, type.boxplot = "ungrouped",group=enquo(group))
  }

  ## Change sens of plot if necessary
  if(sens.boxplot == "horizontal"){
    theplot <- theplot + coord_flip() + theme_boxplot_horizontal()
  }
  else{
    theplot <- theplot + theme_boxplot_vertical()
  }
  x.label.value <- rlang::eval_tidy(x, .data)
  x.label.value <- as.character(x.label.value)
  length_labels <- nchar(x.label.value)
  max_length_label<-max(length_labels)
  max_length_numbers <- 0
  attributes(theplot)$ggsave_parameters <- list(num_bar = nbre_box, direction_plot = sens.boxplot, max_length_label = max_length_label, max_length_numbers = max_length_numbers)

  return(theplot)
}


#' Create a plot with grouped boxplot with standadize IMPACT style
#'
#' @param .data:  data that contains the statistical result to build boxplots
#' @param x: element of .data that contains the different values of the categorical data
#' @param subset.x: element containing all the subset categories of x.
#' @param name.y: name of value calculated
#' @param median: element of .data containing the median values
#' @param first_quantile: element of .data containing lower hinges correspond to the first quartile
#' @param third_quantile: element of .data containing upper hinges correspond to the third quartile
#' @param whisker_min: element of .data containing the value of the lower whisher. Usually calculated as 1.5*IQR smallest value from the hinge
#' @param whisker_max: element of .data containing the value of the upper whisher. Usually calculated as 1.5*IQR largest value from the hinge
#' @param outlier_min (optional): element of .data containing the most extreme value beyond the lower whisper.
#' @param outlier_max (optional): element of .data containing the most extreme value beyond the upper whisper.
#' @param sens.boxplot (optional): if sens.boxplot = "vertical" (default) boxplots are build with vertical cartesian coordinates. If sens.boxplot="horizontal" flip cartesian coordinates so that vertical becomes horizontal
#' @details Create a plot with one or multiple boxplot standardize with IMPACT colors, fonts, ... for the same numerical variable
#' @return a ggplot object containing grouped boxplots
#' @export
grouped_boxplot_impact <- function(.data, x, subset.x, name.y, median, whisker_min, whisker_max, first_quantile, third_quantile, outlier_min = NULL, outlier_max = NULL, sens.boxplot = "vertical"){

  x <- enquo(x)
  subset.x <- enquo(subset.x)
  median <- enquo(median)
  first_quantile <- enquo(first_quantile)
  third_quantile <- enquo(third_quantile)
  whisker_min <- enquo(whisker_min)
  whisker_max <- enquo(whisker_max)
  outlier_min <- enquo(outlier_min)
  outlier_max <- enquo(outlier_max)

  ## Check and return message if empty evironnement

  stop_msg <- error_message_empty_env_boxplot( x, subset.x, median, whisker_min, whisker_max, first_quantile, third_quantile, outlier_min, outlier_max)
  if(stop_msg != ""){
    stop(paste0("The variable(s) following does not exist in .data: ",stop_msg))
  }
  if(sens.boxplot != "vertical" & sens.boxplot != "horizontal"){
    stop("Please enter a valid value to the parameter sens.barchart: 'vertical' or 'horizontal'")
  }

  #No plot if variables are only NA
  check_contains_only_NA(x,.data)
  check_contains_only_NA(subset.x,.data)
  check_contains_only_NA(median,.data)
  check_contains_only_NA(first_quantile,.data)
  check_contains_only_NA(third_quantile,.data)
  check_contains_only_NA(whisker_min,.data)
  check_contains_only_NA(whisker_max,.data)

  nbre_box <- length(unique(rlang::eval_tidy(subset.x,.data))) * length(unique(rlang::eval_tidy(x,.data)))
  # if(nbre_box > 20){
  #   warning("Too many variables. It is not going to fit correclty into the plot.")
  # }

  ## Create a ggplot

  theplot <- ggplot(.data, aes(1), width = 0.5) + geom_boxplot_impact(aes( x = !!x,
                                                       lower = !!first_quantile,
                                                       upper = !!third_quantile,
                                                       middle = !!median,
                                                       ymin = !!whisker_min,
                                                       ymax = !!whisker_max,
                                                       fill = !!subset.x )) +
    scale_fill_reach_categorical(n=nrow(dplyr::distinct(.data,!!x)),name="") +
    xlab("")+ylab(name.y) + theme_impact()


  ## Add outlier if exist (min and max values of dataset)
  if(rlang::quo_is_null(outlier_min) == FALSE){
    theplot <- add_outlier_boxplot(theplot, x, outlier_min, type.boxplot = "grouped", subset.x)
  }

  if(rlang::quo_is_null(outlier_max) == FALSE){
  }

  if(sens.boxplot == "horizontal"){
    theplot <- theplot + coord_flip() + theme_boxplot_horizontal()
  }
  else{
    theplot <- theplot + theme_boxplot_vertical()
  }

  x.label.value <- rlang::eval_tidy(x, .data)
  x.label.value <- as.character(x.label.value)
  length_labels <- nchar(x.label.value)
  max_length_label<-max(length_labels)
  max_length_numbers <- 0
  attributes(theplot)$ggsave_parameters <- list(num_bar = nbre_box, direction_plot = sens.boxplot, max_length_label = max_length_label, max_length_numbers = max_length_numbers)


  return(theplot)

}


#' Use geom_boxplot function with pre_fill arguments
#' @return geom_boxplot function pre-fill
#' @export
geom_boxplot_impact <- purrr::partial(ggplot2::geom_boxplot, stat = "identity",size = 0.5, width = 1 )




