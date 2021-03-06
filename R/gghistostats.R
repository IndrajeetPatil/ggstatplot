#' @title Histogram for distribution of a numeric variable
#' @name gghistostats
#'
#' @description
#'
#' \Sexpr[results=rd, stage=render]{rlang:::lifecycle("maturing")}
#'
#' Histogram with statistical details from one-sample test included in the plot
#' as a subtitle.
#'
#' @param ... Currently ignored.
#' @param normal.curve A logical value that decides whether to super-impose a
#'   normal curve using `stats::dnorm(mean(x), sd(x))`. Default is `FALSE`.
#' @param normal.curve.args A list of additional aesthetic arguments to be
#'   passed to the normal curve.
#' @param bar.fill Character input that decides which color will uniformly fill
#'   all the bars in the histogram (Default: `"grey50"`).
#' @param binwidth The width of the histogram bins. Can be specified as a
#'   numeric value, or a function that calculates width from `x`. The default is
#'   to use the `max(x) - min(x) / sqrt(N)`. You should always check this value
#'   and explore multiple widths to find the best to illustrate the stories in
#'   your data.
#' @inheritParams statsExpressions::expr_t_onesample
#' @inheritParams histo_labeller
#' @inheritParams ggbetweenstats
#'
#' @seealso \code{\link{grouped_gghistostats}}, \code{\link{ggdotplotstats}},
#'  \code{\link{grouped_ggdotplotstats}}
#'
#' @import ggplot2
#'
#' @importFrom dplyr select summarize mutate
#' @importFrom dplyr group_by n arrange
#' @importFrom rlang enquo as_name !! %||%
#' @importFrom stats dnorm
#' @importFrom statsExpressions expr_t_onesample
#'
#' @references
#' \url{https://indrajeetpatil.github.io/ggstatsplot/articles/web_only/gghistostats.html}
#'
#' @examples
#' # for reproducibility
#' set.seed(123)
#' \donttest{
#' # using defaults, but modifying which centrality parameter is to be shown
#' gghistostats(
#'   data = ToothGrowth,
#'   x = len,
#'   xlab = "Tooth length",
#'   centrality.type = "np"
#' )
#' }
#' @export

# function body
gghistostats <- function(data,
                         x,
                         binwidth = NULL,
                         xlab = NULL,
                         title = NULL,
                         subtitle = NULL,
                         caption = NULL,
                         type = "parametric",
                         test.value = 0,
                         bf.prior = 0.707,
                         bf.message = TRUE,
                         effsize.type = "g",
                         conf.level = 0.95,
                         nboot = 100,
                         tr = 0.2,
                         k = 2L,
                         ggtheme = ggplot2::theme_bw(),
                         ggstatsplot.layer = TRUE,
                         bar.fill = "grey50",
                         results.subtitle = TRUE,
                         centrality.plotting = TRUE,
                         centrality.type = type,
                         centrality.line.args = list(size = 1, color = "blue"),
                         normal.curve = FALSE,
                         normal.curve.args = list(size = 2),
                         ggplot.component = NULL,
                         output = "plot",
                         ...) {

  # convert entered stats type to a standard notation
  type <- ipmisc::stats_type_switch(type)

  # ================================= dataframe ==============================

  # to ensure that x will be read irrespective of whether it is quoted or unquoted
  x <- rlang::ensym(x)

  # if dataframe is provided
  df <- tidyr::drop_na(dplyr::select(data, {{ x }}))

  # column as a vector
  x_vec <- df %>% dplyr::pull({{ x }})

  # if binwidth not specified
  if (is.null(binwidth)) binwidth <- (max(x_vec) - min(x_vec)) / sqrt(length(x_vec))

  # ================ stats labels ==========================================

  if (isTRUE(results.subtitle)) {
    # preparing the subtitle with statistical results
    subtitle_df <-
      statsExpressions::expr_t_onesample(
        data = df,
        x = {{ x }},
        type = type,
        test.value = test.value,
        bf.prior = bf.prior,
        effsize.type = effsize.type,
        conf.level = conf.level,
        nboot = nboot,
        tr = tr,
        k = k
      )

    subtitle <- subtitle_df$expression[[1]]

    # preparing the BF message
    if (type == "parametric" && isTRUE(bf.message)) {
      caption_df <-
        statsExpressions::expr_t_onesample(
          data = df,
          x = {{ x }},
          type = "bayes",
          test.value = test.value,
          bf.prior = bf.prior,
          top.text = caption,
          k = k
        )

      caption <- caption_df$expression[[1]]
    }
  }

  # return early if anything other than plot
  if (output != "plot") {
    return(switch(output,
      "caption" = caption,
      subtitle
    ))
  }

  # ============================= plot ====================================

  # adding axes info
  plot <-
    ggplot2::ggplot(data = df, mapping = ggplot2::aes(x = {{ x }})) +
    ggplot2::stat_bin(
      col = "black",
      fill = bar.fill,
      alpha = 0.7,
      binwidth = binwidth,
      mapping = ggplot2::aes(y = ..count.., fill = ..count..)
    ) +
    ggplot2::scale_y_continuous(
      sec.axis = ggplot2::sec_axis(
        trans = ~ . / nrow(df),
        labels = function(x) paste0(x * 100, "%"),
        name = "proportion"
      )
    ) +
    ggplot2::guides(fill = FALSE)

  # if normal curve overlay  needs to be displayed
  if (isTRUE(normal.curve)) {
    plot <- plot +
      rlang::exec(
        .f = ggplot2::stat_function,
        fun = function(x, mean, sd, n, bw) stats::dnorm(x, mean, sd) * n * bw,
        args = list(mean = mean(x_vec), sd = sd(x_vec), n = length(x_vec), bw = binwidth),
        !!!normal.curve.args
      )
  }

  # ---------------- centrality tagging -------------------------------------

  # using custom function for adding labels
  if (isTRUE(centrality.plotting)) {
    plot <-
      histo_labeller(
        plot = plot,
        x = x_vec,
        type = ipmisc::stats_type_switch(centrality.type),
        tr = tr,
        k = k,
        centrality.line.args = centrality.line.args
      )
  }

  # adding the theme and labels
  plot +
    ggplot2::labs(
      x = xlab %||% rlang::as_name(x),
      y = "count",
      title = title,
      subtitle = subtitle,
      caption = caption
    ) +
    theme_ggstatsplot(ggtheme, ggstatsplot.layer) +
    ggplot.component
}
