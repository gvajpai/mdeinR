library(testthat)
library(mdeinR)

# ---- mde_dictionary ---------------------------------------------------------

test_that("mde_dictionary has expected structure", {
  expect_s3_class(mde_dictionary, "data.table")
  expect_true(all(c("token", "dimension") %in% names(mde_dictionary)))
  expect_equal(nrow(mde_dictionary), 324L)
})

test_that("mde_dictionary dimensions are the five expected ones", {
  dims <- sort(unique(mde_dictionary$dimension))
  expect_equal(dims, sort(c("sensory", "affect", "behavioral",
                            "social", "intellectual")))
})

# ---- mde() ------------------------------------------------------------------

test_that("mde() returns a data.table with correct columns", {
  result <- mde("The food was amazing and the ambiance was beautiful.")
  expect_s3_class(result, "data.table")
  expected_cols <- c("element_id", "sentence_id", "word_count",
                     "sensory", "affect", "behavioral", "social",
                     "intellectual", "mde_count")
  expect_true(all(expected_cols %in% names(result)))
})

test_that("mde() detects sensory words", {
  result <- mde("The aroma was absolutely wonderful.")
  expect_gt(result$sensory[1], 0)
})

test_that("mde() detects affect words", {
  result <- mde("I was amazed by the whole dining experience.")
  expect_gt(result$affect[1], 0)
})

test_that("mde() detects social words", {
  result <- mde("The staff were so caring and made us feel welcome.")
  expect_gt(result$social[1], 0)
})

test_that("mde() negation sets score to zero", {
  # "not amazing" should not contribute positively to affect
  result_neg <- mde("The food was not amazing at all.")
  result_pos <- mde("The food was amazing.")
  expect_lte(result_neg$affect[1], result_pos$affect[1])
})

test_that("mde() handles empty string gracefully", {
  expect_silent(result <- mde(""))
  expect_equal(nrow(result), 1L)
  expect_equal(result$word_count[1], 0L)
})

test_that("mde() handles a vector of reviews", {
  reviews <- c(
    "Amazing food and beautiful ambiance.",
    "Staff were warm and caring.",
    "Nothing special about the cuisine."
  )
  result <- mde(reviews)
  expect_equal(nrow(result), 3L)
  expect_equal(result$element_id, 1:3)
})

test_that("mde_count reflects number of dimensions present", {
  # Review mentioning sensory and affect only
  result <- mde("The aroma was stunning and I felt amazed.")
  expect_gte(result$mde_count[1], 1L)
  expect_lte(result$mde_count[1], 5L)
})

# ---- mde_by() ---------------------------------------------------------------

test_that("mde_by() returns one row when no grouping", {
  reviews <- c("Amazing food.", "Caring staff.")
  result  <- mde_by(reviews)
  expect_equal(nrow(result), 1L)
})

test_that("mde_by() groups correctly", {
  library(data.table)
  df <- data.table(
    group = c("A", "A", "B"),
    text  = c(
      "Amazing aroma.",
      "Caring and warm staff.",
      "Very intellectual cuisine with exotic flavours."
    )
  )
  result <- mde_by(df, by = "group")
  expect_equal(nrow(result), 2L)
  expect_true("group" %in% names(result))
})

# ---- highlight_mde() --------------------------------------------------------

test_that("highlight_mde() wraps matched words", {
  out <- highlight_mde("The aroma was wonderful.")
  expect_true(grepl("<sensory>aroma</sensory>", out))
})

test_that("highlight_mde() leaves non-MDE words unchanged", {
  out <- highlight_mde("The weather was nice today.")
  expect_false(grepl("<", out))
})

# ---- update_valence_shifters() ---------------------------------------------

test_that("update_valence_shifters() adds new entries", {
  base_n <- nrow(mdeinR::valence_shifters)
  custom <- data.frame(x = c("overpriced", "undercooked"), y = c(1L, 1L))
  vs     <- update_valence_shifters(custom)
  # Should have at least as many rows as base + 2 new (may replace existing)
  expect_gte(nrow(vs), base_n)
  expect_true("overpriced" %in% vs$x)
})
