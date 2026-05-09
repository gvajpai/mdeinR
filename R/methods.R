#' Print Method for mde_by Objects
#'
#' @param x An object of class \code{mde_by}.
#' @param ... Ignored.
#' @export
print.mde_by <- function(x, ...) {
  cat("MDE Dimension Scores (aggregated)\n")
  cat(rep("-", 50), "\n", sep = "")
  NextMethod()
}

#' Summary Method for mde_by Objects
#'
#' Prints a compact summary of mean dimension scores and the proportion of
#' sentences mentioning each dimension.
#'
#' @param object An object of class \code{mde_by}.
#' @param ... Ignored.
#' @export
summary.mde_by <- function(object, ...) {
  dims <- c("sensory", "affect", "behavioral", "social", "intellectual")
  present_dims <- intersect(dims, names(object))

  cat("MDE Dimension Summary\n")
  cat(rep("=", 50), "\n", sep = "")

  means <- unlist(object[, present_dims, with = FALSE][1, ])
  cat("\nMean dimension scores:\n")
  for (d in present_dims) {
    cat(sprintf("  %-15s %.4f\n", d, means[d]))
  }

  if ("mde_count" %in% names(object)) {
    cat(sprintf("\nMean MDE dimensions per sentence: %.2f / 5\n",
                mean(object[["mde_count"]], na.rm = TRUE)))
  }
  invisible(object)
}
