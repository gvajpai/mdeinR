#' MDE Dimension Dictionary
#'
#' @description
#' A \code{data.table} containing 324 tokens and their corresponding
#' Memorable Dining Experience (MDE) dimension assignments.  The dictionary
#' was developed and validated by Vajpai, Webb & Beldona (2025) from
#' 11,481 French fine-dining restaurant reviews sourced from the Yelp open
#' dataset.
#'
#' @format A \code{data.table} with 324 rows and 2 columns:
#' \describe{
#'   \item{\code{token}}{Character. The dictionary word (lower-case).}
#'   \item{\code{dimension}}{Character. One of \code{"sensory"},
#'     \code{"affect"}, \code{"behavioral"}, \code{"social"}, or
#'     \code{"intellectual"}.}
#' }
#'
#' @details
#' The five dimensions follow the theoretical MDE framework of Cao et al.
#' (2019), which in turn adapts Schmitt's (1999) Strategic Experiential
#' Modules:
#'
#' \describe{
#'   \item{sensory (n = 85)}{Pleasure from sight, sound, touch, taste, and
#'     smell; covers food quality, ambience, décor, and presentation.}
#'   \item{affect (n = 82)}{Emotions and psychological reactions aroused
#'     during the dining experience.}
#'   \item{social (n = 58)}{Feelings of belonging and social interaction with
#'     staff, friends, and family.}
#'   \item{intellectual (n = 51)}{Cognitive engagement, curiosity, and learning
#'     stimulated by the dining experience.}
#'   \item{behavioral (n = 48)}{Physical engagement, activities, and
#'     involvement during the experience.}
#' }
#'
#' @references
#' Vajpai, G. N., Webb, T., & Beldona, S. (2025). Designing a memorable
#' dining experience lexicon based on theory and text mining.
#' *International Journal of Hospitality Management*, 130, 104245.
#' \doi{10.1016/j.ijhm.2025.104245}
#'
#' Cao, Y., Li, X. R., DiPietro, R., & So, K. K. F. (2019). The creation
#' of memorable dining experiences: formative index construction.
#' *International Journal of Hospitality Management*, 82, 308–317.
#'
#' @examples
#' head(mde_dictionary, 10)
#' table(mde_dictionary$dimension)
#'
"mde_dictionary"


#' Valence Shifters Table
#'
#' @description
#' A \code{data.table} of 248 English valence-shifter tokens used to
#' modulate raw MDE dimension scores within a sentence context window.
#' Bundled directly in \pkg{mdeinR} so no external NLP package is required.
#'
#' @format A \code{data.table} with 248 rows and 2 columns:
#' \describe{
#'   \item{\code{x}}{Character. The lower-case token.}
#'   \item{\code{y}}{Integer. Shifter type:
#'     \code{1} = negator (e.g., \emph{not}, \emph{never}),
#'     \code{2} = amplifier (e.g., \emph{very}, \emph{extremely}),
#'     \code{3} = de-amplifier (e.g., \emph{slightly}, \emph{somewhat}),
#'     \code{4} = adversative conjunction (e.g., \emph{but}, \emph{however}).}
#' }
#'
#' @details
#' The shifter types follow the same coding scheme used by
#' Rinker (2021), allowing the table to be used with the same
#' scoring logic.  Use \code{\link{update_valence_shifters}} to add or
#' override entries with domain-specific terms.
#'
#' @references
#' Rinker, T. W. (2021). \pkg{sentimentr}: Calculate text polarity sentiment.
#' University at Buffalo/SUNY. \url{https://github.com/trinker/sentimentr}
#'
#' @examples
#' head(valence_shifters)
#' table(valence_shifters$y)
#'
"valence_shifters"


#' Update (Merge / Replace) the Valence Shifters Table
#'
#' @description
#' Returns a modified copy of the bundled \code{\link{valence_shifters}} table
#' after merging user-supplied overrides.  Useful when domain-specific terms
#' (e.g., \emph{undercooked}, \emph{overpriced}) should be treated as
#' negators or de-amplifiers in restaurant text.
#'
#' @param additions A \code{data.frame} or \code{data.table} with columns
#'   \code{x} (character, the token) and \code{y} (integer, shifter type:
#'   1 = negator, 2 = amplifier, 3 = de-amplifier, 4 = adversative).
#'   Rows whose \code{x} already appear in the base table are replaced;
#'   new rows are appended.
#' @param base A \code{data.table} to use as the base table.  Defaults to
#'   the built-in \code{\link{valence_shifters}} bundled with \pkg{mdeinR}.
#'
#' @return A \code{data.table} suitable for passing to the
#'   \code{valence_shifters_dt} argument of \code{\link{mde}} or
#'   \code{\link{mde_by}}.
#'
#' @examples
#' \dontrun{
#' custom <- data.frame(
#'   x = c("overpriced", "undercooked", "bland"),
#'   y = c(1L, 1L, 1L)   # treat as negators
#' )
#' vs <- update_valence_shifters(custom)
#' mde("The food was amazing but overpriced.", valence_shifters_dt = vs)
#' }
#'
#' @importFrom data.table copy setDT setkey as.data.table
#' @export
update_valence_shifters <- function(
    additions,
    base = mdeinR::valence_shifters
) {
  base_copy <- data.table::copy(base)
  data.table::setDT(base_copy)
  add_copy  <- data.table::copy(data.table::as.data.table(additions))
  add_copy[, x := stringi::stri_trans_tolower(x)]

  # Remove existing entries for tokens that will be overridden
  base_copy <- base_copy[!x %in% add_copy[["x"]]]
  out <- rbind(base_copy, add_copy)
  data.table::setkey(out, x)
  out
}


#' Highlight MDE Dimension Words in a Review
#'
#' @description
#' Returns a character string with dimension keywords wrapped in simple
#' annotation tags \code{<dimension>word</dimension>} to facilitate
#' qualitative inspection and debugging.
#'
#' @param text A single character string (one review).
#' @param mde_dt A \code{data.table} with columns \code{token} and
#'   \code{dimension}.  Defaults to \code{\link{mde_dictionary}}.
#' @param tag_format Character string with \code{"\%s"} appearing twice:
#'   first for the dimension name and second for the word.  Defaults to
#'   \code{"<\%s>\%s</\%s>"} which expands to e.g. \code{<sensory>aroma</sensory>}.
#'
#' @return A character string with matched words annotated.
#'
#' @examples
#' \dontrun{
#' highlight_mde("The aroma was wonderful and staff were so caring.")
#' }
#'
#' @export
highlight_mde <- function(
    text,
    mde_dt     = mdeinR::mde_dictionary,
    tag_format = "<%s>%s</%s>"
) {
  if (length(text) != 1L || !is.character(text)) {
    stop("`text` must be a single character string.")
  }

  lookup <- data.table::copy(mde_dt)
  lookup[, token := stringi::stri_trans_tolower(token)]

  words    <- stringi::stri_split_fixed(text, " ")[[1L]]
  lower_w  <- stringi::stri_trans_tolower(words)

  annotated <- mapply(function(orig, lw) {
    m <- lookup[token == lw, ]
    if (nrow(m) == 0L) return(orig)
    dim <- m[["dimension"]][1L]
    sprintf(tag_format, dim, orig, dim)
  }, words, lower_w, SIMPLIFY = TRUE)

  paste(annotated, collapse = " ")
}
