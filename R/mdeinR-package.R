#' mdeinR: Memorable Dining Experience Text Analysis
#'
#' @description
#' \pkg{mdeinR} provides tools to detect and score the five dimensions of
#' the Memorable Dining Experience (MDE) framework — \strong{sensory},
#' \strong{affect}, \strong{behavioral}, \strong{social}, and
#' \strong{intellectual} — from free-text restaurant reviews.
#'
#' The package is fully self-contained: it ships its own sentence tokeniser
#' (\code{\link{get_sentences}}), its own valence-shifter table
#' (\code{\link{valence_shifters}}), and the validated MDE lexicon
#' (\code{\link{mde_dictionary}}).  No external NLP package is required.
#' \itemize{
#'   \item Sentence-level scoring with valence-shifter adjustment
#'     (negator / amplifier / de-amplifier / adversative conjunction).
#'   \item Group-level aggregation via \code{\link{mde_by}}.
#'   \item Qualitative annotation via \code{\link{highlight_mde}}.
#'   \item Easy extension of the shifter table via
#'     \code{\link{update_valence_shifters}}.
#' }
#'
#' @section Main functions:
#' \describe{
#'   \item{\code{\link{mde}}}{Score MDE dimensions sentence by sentence.}
#'   \item{\code{\link{mde_by}}}{Aggregate scores by grouping variables (e.g.,
#'     restaurant, reviewer).}
#'   \item{\code{\link{get_sentences}}}{Split a character vector into sentences.}
#'   \item{\code{\link{highlight_mde}}}{Annotate a review string with dimension
#'     tags for qualitative inspection.}
#'   \item{\code{\link{update_valence_shifters}}}{Extend the valence-shifter
#'     table with domain-specific terms.}
#' }
#'
#' @section Quick start:
#' ```r
#' library(mdeinR)
#'
#' reviews <- c(
#'   "The aroma and presentation were absolutely stunning.",
#'   "Staff were warm and made us feel like family.",
#'   "We tried exotic dishes and discovered a whole new cuisine."
#' )
#'
#' # Sentence-level scores
#' mde(reviews)
#'
#' # Document-level aggregate
#' mde_by(reviews)
#'
#' # Annotate a single review
#' highlight_mde(reviews[1])
#' ```
#'
#' @references
#' Vajpai, G. N., Webb, T., & Beldona, S. (2025). Designing a memorable
#' dining experience lexicon based on theory and text mining.
#' *International Journal of Hospitality Management*, 130, 104245.
#' \doi{10.1016/j.ijhm.2025.104245}
#'
#' @docType package
#' @name mdeinR-package
#' @aliases mdeinR
"_PACKAGE"


# Suppress R CMD CHECK notes for data.table non-standard evaluation
utils::globalVariables(c(
  "token", "dimension", "x", "y", "sentences",
  "element_id", "sentence_id", "word_count",
  "sensory", "affect", "behavioral", "social", "intellectual",
  "mde_count", ".SD", ".N", ":="
))
