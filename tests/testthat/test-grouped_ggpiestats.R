test_that(
  desc = "grouped_ggpiestats works",
  code = {
    skip_on_cran()

    #--------------------- only x variable -------------------------------

    ## expecting error
    expect_error(
      ggstatsplot::grouped_ggpiestats(
        data = mtcars,
        x = cyl
      )
    )

    ## without counts

    # when arguments are entered as bare expressions
    set.seed(123)
    expect_true(inherits(suppressWarnings(
      ggstatsplot::grouped_ggpiestats(
        data = mtcars,
        grouping.var = am,
        x = "cyl",
        results.subtitle = FALSE
      )
    ),
    what = "gg"
    ))

    #------------------ both x and y variables ------------------

    ## without counts

    # creating a smaller dataframe
    mpg_short <-
      ggplot2::mpg %>%
      dplyr::filter(
        .data = .,
        drv %in% c("4", "f"),
        class %in% c("suv", "midsize"),
        trans %in% c("auto(l4)", "auto(l5)")
      )

    # when arguments are entered as bare expressions
    set.seed(123)
    expect_true(inherits(suppressWarnings(
      ggstatsplot::grouped_ggpiestats(
        data = mpg_short,
        x = cyl,
        y = "class",
        results.subtitle = FALSE,
        grouping.var = drv,
        label.repel = TRUE
      )
    ),
    what = "gg"
    ))

    ## with counts

    # when arguments are entered as bare expressions
    set.seed(123)
    expect_true(inherits(suppressWarnings(
      ggstatsplot::grouped_ggpiestats(
        data = as.data.frame(Titanic),
        grouping.var = Class,
        x = Sex,
        results.subtitle = FALSE,
        y = Survived,
        counts = "Freq"
      )
    ),
    what = "gg"
    ))
  }
)

# subtitle output --------------------------------------------------

test_that(
  desc = "subtitle output",
  code = {
    skip_on_cran()

    set.seed(123)
    df <- dplyr::sample_frac(tbl = forcats::gss_cat, size = 0.1) %>%
      dplyr::mutate_if(., is.factor, droplevels)


    # should output a list of length 3
    set.seed(123)
    ls_results <-
      suppressWarnings(ggstatsplot::grouped_ggpiestats(
        data = df,
        x = relig,
        y = marital,
        grouping.var = race,
        output = "subtitle"
      ))

    set.seed(123)
    sexpr_results <-
      suppressWarnings(statsExpressions::expr_contingency_tab(
        data = dplyr::filter(df, race == "Other") %>%
          dplyr::mutate_if(., is.factor, droplevels),
        x = relig,
        y = marital,
        output = "subtitle"
      )$expression[[1]])

    # checking subtitle
    expect_equal(ls_results$Other, sexpr_results)
  }
)
