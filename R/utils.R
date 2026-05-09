# ============================================================
#  Internal helper functions — not exported (except get_sentences)
# ============================================================

# ---- Sentence splitter ------------------------------------------------------

#' Split Text Into Sentences
#'
#' @description
#' Splits one or more character strings into individual sentences, returning
#' a \code{data.table} with one row per sentence.  This is a self-contained
#' implementation that does not depend on any external NLP package.
#'
#' Sentence boundaries are detected at \code{.}, \code{!}, \code{?} followed
#' by whitespace or end-of-string, and at \code{;} as a soft boundary.
#' Common abbreviations (\emph{Mr.}, \emph{Dr.}, \emph{vs.}, etc.) are
#' protected and do \strong{not} trigger a split.
#'
#' @param text A character vector.  Each element is treated as one document
#'   (\code{element_id}).
#'
#' @return A \code{data.table} with columns:
#' \describe{
#'   \item{\code{element_id}}{Integer. Index of the source document.}
#'   \item{\code{sentence_id}}{Integer. Index of the sentence within its document.}
#'   \item{\code{sentences}}{Character. The sentence text (trimmed).}
#' }
#'
#' @examples
#' get_sentences(c(
#'   "The food was amazing. Staff were so caring!",
#'   "We learned about Thai cuisine. Truly memorable."
#' ))
#'
#' @importFrom data.table data.table rbindlist
#' @importFrom stringi stri_split_regex stri_trim_both stri_replace_all_regex
#'   stri_trans_tolower stri_detect_regex
#' @export
get_sentences <- function(text) {
  if (!is.character(text)) stop("`text` must be a character vector.")

  ## Abbreviations that should NOT trigger a sentence split
  abbrevs <- c(
    "Mr", "Mrs", "Ms", "Dr", "Prof", "Sr", "Jr", "Rev", "Gen", "Sgt",
    "Cpl", "Lt", "Col", "Maj", "Brig", "Capt", "Cmdr", "Adm",
    "St", "Ave", "Blvd", "Rd", "approx", "dept", "est", "fig",
    "govt", "incl", "max", "min", "misc", "no", "p", "pp",
    "vol", "vs", "etc", "i.e", "e.g", "a.m", "p.m",
    "Jan", "Feb", "Mar", "Apr", "Jun", "Jul", "Aug",
    "Sep", "Oct", "Nov", "Dec"
  )

  protect <- "___ABBREVPROTECT___"

  results <- vector("list", length(text))

  for (i in seq_along(text)) {
    doc <- text[i]

    if (is.na(doc) || nchar(trimws(doc)) == 0L) {
      results[[i]] <- data.table::data.table(
        element_id  = i,
        sentence_id = 1L,
        sentences   = ""
      )
      next
    }

    ## Protect abbreviations by temporarily replacing their trailing period
    for (ab in abbrevs) {
      pattern     <- paste0("(?<![A-Za-z])", ab, "\\.")
      replacement <- paste0(ab, protect)
      doc <- stringi::stri_replace_all_regex(
        doc, pattern, replacement,
        opts_regex = list(case_insensitive = FALSE)
      )
    }

    ## Split on sentence-terminal punctuation followed by whitespace,
    ## or on semicolons followed by whitespace
    raw_sents <- stringi::stri_split_regex(
      doc,
      pattern = "(?<=[.!?])\\s+|(?<=;)\\s+"
    )[[1L]]

    ## Restore protected periods
    raw_sents <- stringi::stri_replace_all_regex(
      raw_sents,
      pattern     = protect,
      replacement = "."
    )

    raw_sents <- stringi::stri_trim_both(raw_sents)
    raw_sents <- raw_sents[nchar(raw_sents) > 0L]
    if (length(raw_sents) == 0L) raw_sents <- ""

    results[[i]] <- data.table::data.table(
      element_id  = i,
      sentence_id = seq_along(raw_sents),
      sentences   = raw_sents
    )
  }

  data.table::rbindlist(results)
}


# ---- Tokeniser --------------------------------------------------------------

## Split a sentence string into lower-case word tokens.
## If neutral.nonword.check = TRUE, drop tokens with no alphabetic character.
.tokenise <- function(sentence, neutral.nonword.check = TRUE) {
  words <- stringi::stri_split_regex(
    stringi::stri_trans_tolower(sentence),
    pattern = "\\s+"
  )[[1L]]
  words <- words[nchar(words) > 0L]
  if (neutral.nonword.check) {
    words <- words[stringi::stri_detect_regex(words, "[a-z]")]
  }
  words
}


# ---- Row builder ------------------------------------------------------------

.make_score_row <- function(element_id, sentence_id, word_count, scores) {
  data.table::data.table(
    element_id   = element_id,
    sentence_id  = sentence_id,
    word_count   = word_count,
    sensory      = scores[["sensory"]],
    affect       = scores[["affect"]],
    behavioral   = scores[["behavioral"]],
    social       = scores[["social"]],
    intellectual = scores[["intellectual"]]
  )
}


# ---- get_sentences unpacker -------------------------------------------------

## Convert get_sentences() output to a canonical data.table
## with column "sentence" (not "sentences") for internal use.
.unpack_get_sentences <- function(gs) {
  if (inherits(gs, "data.table") &&
      all(c("element_id", "sentence_id", "sentences") %in% names(gs))) {
    out <- gs[, list(element_id, sentence_id, sentence = sentences)]
    return(out)
  }
  ## Fallback: one sentence per element
  data.table::data.table(
    element_id  = seq_along(gs),
    sentence_id = 1L,
    sentence    = as.character(gs)
  )
}


# ---- Flatten helper ---------------------------------------------------------

.flatten_get_sentences <- function(gs) {
  if (inherits(gs, "data.table") && "sentences" %in% names(gs)) {
    return(gs[["sentences"]])
  }
  as.character(gs)
}
