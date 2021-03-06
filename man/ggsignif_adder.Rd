% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/helpers_ggbetweenstats_graphics.R
\name{ggsignif_adder}
\alias{ggsignif_adder}
\title{Adding \code{geom_signif} to \code{ggplot}}
\usage{
ggsignif_adder(
  plot,
  df_pairwise,
  data,
  x,
  y,
  pairwise.display = "significant",
  ggsignif.args = list(textsize = 3, tip_length = 0.01),
  ...
)
}
\arguments{
\item{plot}{A \code{ggplot} object on which \code{geom_signif} needed to be added.}

\item{df_pairwise}{A dataframe containing results from pairwise comparisons
(produced by \code{pairwiseComparisons::pairwise_comparisons()} function).}

\item{data}{A dataframe (or a tibble) from which variables specified are to
be taken. Other data types (e.g., matrix,table, array, etc.) will \strong{not}
be accepted.}

\item{x}{The grouping (or independent) variable from the dataframe \code{data}.}

\item{y}{The response (or outcome or dependent) variable from the
dataframe \code{data}.}

\item{pairwise.display}{Decides \emph{which} pairwise comparisons to display.
Available options are:
\itemize{
\item \code{"significant"} (abbreviation accepted: \code{"s"})
\item \code{"non-significant"} (abbreviation accepted: \code{"ns"})
\item \code{"all"}
}

You can use this argument to make sure that your plot is not uber-cluttered
when you have multiple groups being compared and scores of pairwise
comparisons being displayed.}

\item{ggsignif.args}{A list of additional aesthetic
arguments to be passed to \code{ggsignif::geom_signif}.}

\item{...}{Currently ignored.}
}
\description{
Adding \code{geom_signif} to \code{ggplot}
}
\examples{
set.seed(123)
library(ggplot2)

# plot
p <- ggplot(iris, aes(Species, Sepal.Length)) +
  geom_boxplot()

# dataframe with pairwise comparison test results
df_pair <-
  pairwiseComparisons::pairwise_comparisons(
    data = iris,
    x = Species,
    y = Sepal.Length
  )

# adding a geom for pairwise comparisons
ggstatsplot:::ggsignif_adder(
  plot = p,
  data = iris,
  x = Species,
  y = Sepal.Length,
  df_pairwise = df_pair
)
}
\keyword{internal}
