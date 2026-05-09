#' Score Memorable Dining Experience (MDE) Dimensions in Text
#'
#' @description
#' Detects and scores the five MDE dimensions — \code{sensory}, \code{affect},
#' \code{behavioral}, \code{social}, and \code{intellectual} — in each sentence
#' of the supplied text, applying valence-shifter (negator / amplifier /
#' de-amplifier / adversative) adjustments.
#'
#' The function accepts either raw character vectors or the output of the
#' built-in \code{\link{get_sentences}()} tokeniser.
#'
#' @param text A character vector, a \code{data.frame} / \code{data.table}
#'   with a text column, or the list output of \code{\link{get_sentences}}.
#' @param mde_dt A \code{data.table} with columns \code{token} (character) and
#'   \code{dimension} (character) that defines the MDE lexicon.
#'   Defaults to the built-in \code{\link{mde_dictionary}}.
#' @param valence_shifters_dt A \code{data.table} with columns \code{x}
#'   (token) and \code{y} (integer type code: 1 = negator, 2 = amplifier,
#'   3 = de-amplifier, 4 = adversative conjunction) used to modulate raw
#'   dimension scores.  Defaults to the built-in
#'   \code{\link{valence_shifters}} table bundled with \pkg{mdeinR}.
#' @param n.before Integer (default \code{5}).  Number of words \emph{before}
#'   a dimension word to scan for valence shifters.
#' @param n.after Integer (default \code{2}).  Number of words \emph{after} a
#'   dimension word to scan for valence shifters.
#' @param amplifier.weight Numeric (default \code{0.8}).  Multiplicative
#'   boost applied when an amplifier is detected in the window.
#' @param n.neutral Numeric (default \code{0.2}).  Fraction toward neutral
#'   (zero) applied when a de-amplifier is detected.
#' @param neutral.nonword.check Logical (default \code{TRUE}).  If
#'   \code{TRUE}, punctuation-only "words" are ignored when counting the
#'   context window.
#' @param ... Currently unused; reserved for future arguments.
#'
#' @return A \code{data.table} with one row per sentence containing:
#' \describe{
#'   \item{\code{element_id}}{Integer index of the original document element.}
#'   \item{\code{sentence_id}}{Integer index of the sentence within the element.}
#'   \item{\code{word_count}}{Number of words in the sentence.}
#'   \item{\code{sensory}}{Adjusted score for the sensory dimension.}
#'   \item{\code{affect}}{Adjusted score for the affective dimension.}
#'   \item{\code{behavioral}}{Adjusted score for the behavioral dimension.}
#'   \item{\code{social}}{Adjusted score for the social dimension.}
#'   \item{\code{intellectual}}{Adjusted score for the intellectual dimension.}
#'   \item{\code{mde_count}}{Number of distinct MDE dimensions mentioned
#'     (0–5).}
#' }
#'
#' @details
#' **Scoring algorithm:**
#'
#' 1. Each sentence is tokenised into lower-case words.
#' 2. For every token that matches the MDE lexicon, a raw score of
#'    \code{1 / word_count} is attributed to the matching dimension.
#' 3. A context window of \code{n.before} words before and \code{n.after}
#'    words after the hit is examined for valence shifters:
#'    * **Negator** (type 1): the raw score is multiplied by \code{-1}.
#'    * **Amplifier** (type 2): the raw score is multiplied by
#'      \code{1 + amplifier.weight}.
#'    * **De-amplifier** (type 3): the raw score is multiplied by
#'      \code{1 - n.neutral}.
#'    * **Adversative conjunction** (type 4): words after the conjunction
#'      within the window receive reduced weight (\code{1 - n.neutral}).
#' 4. Adjusted scores for each dimension are summed across a sentence.
#' 5. Because MDE theory exclusively concerns positive occurrences, any
#'    negated (negative) dimension score is set to zero.
#'
#' @references
#' Vajpai, G. N., Webb, T., & Beldona, S. (2025). Designing a memorable
#' dining experience lexicon based on theory and text mining.
#' *International Journal of Hospitality Management*, 130, 104245.
#' \doi{10.1016/j.ijhm.2025.104245}
#'
#' Rinker, T. W. (2021). \pkg{sentimentr}: Calculate text polarity
#' sentiment (inspiration for the scoring algorithm).
#' \url{https://github.com/trinker/sentimentr}
#'
#' @seealso \code{\link{mde_by}}, \code{\link{mde_dictionary}},
#'   \code{\link{get_sentences}}, \code{\link{valence_shifters}}
#'
#' @examples
#' \dontrun{
#' reviews <- c(
#'   "The food was amazing and the ambiance was absolutely stunning.",
#'   "We learned so much about French cuisine — a truly educational experience.",
#'   "Staff were warm and made us feel like family."
#' )
#'
#' # Sentence-level scores
#' mde(reviews)
#'
#' # Using get_sentences() first (recommended for multi-sentence documents)
#' mde(get_sentences(reviews))
#' }
#'
#' @importFrom data.table data.table rbindlist
#' @importFrom stringi stri_trans_tolower stri_detect_regex stri_split_regex
#' @export
mde <- function(
    text,
    mde_dt              = mdeinR::mde_dictionary,
    valence_shifters_dt = mdeinR::valence_shifters,
    n.before            = 5L,
    n.after             = 2L,
    amplifier.weight    = 0.8,
    n.neutral           = 0.2,
    neutral.nonword.check = TRUE,
    ...
) {

  ## ---- 0. Normalise input --------------------------------------------------
  if (inherits(text, "data.table") &&
      all(c("element_id", "sentence_id", "sentences") %in% names(text))) {
    # Already the output of get_sentences()
    sents <- .unpack_get_sentences(text)
  } else if (is.character(text)) {
    sents <- .unpack_get_sentences(get_sentences(text))
  } else if (inherits(text, c("data.frame", "data.table"))) {
    char_cols <- names(text)[vapply(text, is.character, logical(1))]
    if (length(char_cols) == 0L) stop("No character column found in `text`.")
    sents <- .unpack_get_sentences(get_sentences(text[[char_cols[1]]]))
  } else {
    stop("`text` must be a character vector, data.frame, or get_sentences() output.")
  }

  ## ---- 1. Build lookup structures ------------------------------------------
  ## NOTE: The scoring approach below (steps 1-4) is adapted from the
  ## emotion() function in sentimentr (Rinker, 2021), MIT License.
  ## https://github.com/trinker/sentimentr
  ##
  ## We build plain named lists for O(1) lookup rather than using data.table
  ## := mutations (which modify by reference and can corrupt package-level
  ## data objects).
  mde_tokens <- stringi::stri_trans_tolower(mde_dt[["token"]])
  mde_dims   <- mde_dt[["dimension"]]
  ## Named list: token -> dimension(s)
  mde_lookup <- split(mde_dims, mde_tokens)

  vs_tokens  <- stringi::stri_trans_tolower(valence_shifters_dt[["x"]])
  vs_types_v <- valence_shifters_dt[["y"]]
  ## Named integer vector: token -> type code
  vs_lookup  <- stats::setNames(as.integer(vs_types_v), vs_tokens)

  dims <- c("sensory", "affect", "behavioral", "social", "intellectual")

  ## ---- 2. Score each sentence ----------------------------------------------
  results <- lapply(seq_len(nrow(sents)), function(i) {
    row      <- sents[i, ]
    sent_str <- row[["sentence"]]
    eid      <- row[["element_id"]]
    sid      <- row[["sentence_id"]]

    words <- .tokenise(sent_str, neutral.nonword.check)
    n     <- length(words)

    scores <- stats::setNames(rep(0, length(dims)), dims)

    if (n == 0L) {
      return(.make_score_row(eid, sid, n, scores))
    }

    for (k in seq_len(n)) {
      w <- words[k]
      if (!w %in% names(mde_lookup)) next

      dim_hit <- mde_lookup[[w]]
      if (length(dim_hit) == 0L) next

      raw <- 1 / n

      ## Context window indices (exclude position k itself)
      win_start <- max(1L, k - n.before)
      win_end   <- min(n,  k + n.after)
      idx       <- setdiff(win_start:win_end, k)
      window    <- words[idx]
      window    <- window[!is.na(window)]

      ## Retrieve valence-shifter types for window tokens
      vs_types  <- vs_lookup[window[window %in% names(vs_lookup)]]

      ## Apply shifters
      has_neg <- 1L %in% vs_types
      n_amp   <- sum(vs_types == 2L)
      n_deamp <- sum(vs_types == 3L)

      adj <- raw
      if (n_amp   > 0L) adj <- adj * (1 + amplifier.weight * n_amp)
      if (n_deamp > 0L) adj <- adj * (1 - n.neutral * n_deamp)
      if (has_neg)      adj <- adj * -1

      ## Per MDE theory: only positive occurrences count
      if (adj > 0) {
        for (d in dim_hit) {
          if (d %in% dims) scores[d] <- scores[d] + adj
        }
      }
    }

    .make_score_row(eid, sid, n, scores)
  })

  out <- data.table::rbindlist(results)

  ## Count distinct dimensions mentioned (score > 0)
  ## Plain R assignment avoids data.table := returning NULL
  out[["mde_count"]] <- rowSums(out[, dims, with = FALSE] > 0)

  return(out)
}


#' Score MDE Dimensions Aggregated by Grouping Variable(s)
#'
#' @description
#' A convenience wrapper around \code{\link{mde}} that averages sentence-level
#' MDE dimension scores within one or more grouping variables — e.g., by
#' restaurant, reviewer, or time period.
#'
#' @param text A character vector, \code{data.frame}/\code{data.table} with a
#'   text column, or the output of \code{\link{get_sentences}}.
#' @param by Character vector of column names in \code{text} (when
#'   \code{text} is a data.frame) by which to group results, \emph{or} a
#'   list / vector of grouping variables of the same length as \code{text}.
#'   Pass \code{NULL} (default) to aggregate the whole corpus into one row.
#' @param ... Additional arguments passed to \code{\link{mde}}.
#'
#' @return A \code{data.table} with the grouping columns (if any) plus the
#'   mean of each MDE dimension and \code{mde_count} across all sentences
#'   within each group.  Also includes \code{word_count} (total words) and
#'   \code{sd} columns for each dimension.
#'
#' @examples
#' \dontrun{
#' library(data.table)
#'
#' reviews <- data.table(
#'   restaurant = c("A", "A", "B", "B"),
#'   text = c(
#'     "The aroma and presentation were stunning.",
#'     "Staff were caring and we felt at home.",
#'     "Nothing special about the food or the décor.",
#'     "We tried exotic dishes and learned a lot about Thai cuisine."
#'   )
#' )
#'
#' mde_by(reviews, by = "restaurant")
#' }
#'
#' @seealso \code{\link{mde}}
#' @export
mde_by <- function(text, by = NULL, ...) {

  dims <- c("sensory", "affect", "behavioral", "social", "intellectual")

  ## ---- Prepare grouping variables ------------------------------------------
  if (!is.null(by)) {
    if (inherits(text, c("data.frame", "data.table"))) {
      missing_cols <- setdiff(by, names(text))
      if (length(missing_cols) > 0L) {
        stop("Column(s) not found in `text`: ",
             paste(missing_cols, collapse = ", "))
      }
      group_data <- data.table::as.data.table(text)[, by, with = FALSE]
      text_col   <- names(text)[vapply(text, is.character, logical(1))][1]
      raw_text   <- text[[text_col]]
    } else if (is.character(text)) {
      if (!is.list(by)) {
        stop("When `text` is a character vector, `by` must be a list of vectors.")
      }
      raw_text   <- text
      group_data <- data.table::as.data.table(by)
    } else {
      # get_sentences input — flatten
      raw_text   <- .flatten_get_sentences(text)
      if (!is.list(by)) {
        stop("When `text` is get_sentences output, `by` must be a list of vectors.")
      }
      group_data <- data.table::as.data.table(by)
    }
  } else {
    if (is.character(text)) {
      raw_text <- text
    } else if (inherits(text, c("data.frame", "data.table"))) {
      text_col <- names(text)[vapply(text, is.character, logical(1))][1]
      raw_text <- text[[text_col]]
    } else {
      raw_text <- .flatten_get_sentences(text)
    }
    group_data <- NULL
  }

  ## ---- Sentence-level scores -----------------------------------------------
  sent_scores <- mde(raw_text, ...)

  ## ---- Attach grouping info -------------------------------------------------
  if (!is.null(group_data)) {
    # Expand group_data to match sentence rows via element_id
    group_expanded <- group_data[sent_scores[["element_id"]], ]
    sent_scores    <- cbind(sent_scores, group_expanded)
    group_cols     <- names(group_data)
  } else {
    group_cols <- NULL
  }

  ## ---- Aggregate -----------------------------------------------------------
  score_cols <- c(dims, "mde_count", "word_count")

  if (is.null(group_cols)) {

    ## Plain-R aggregate — no data.table in-place mutations
    means <- vapply(score_cols, function(col) {
      mean(sent_scores[[col]], na.rm = TRUE)
    }, numeric(1))

    sds <- vapply(dims, function(col) {
      stats::sd(sent_scores[[col]], na.rm = TRUE)
    }, numeric(1))
    names(sds) <- paste0("sd_", dims)

    out <- as.data.frame(c(
      list(n_sentences = nrow(sent_scores)),
      as.list(means),
      as.list(sds)
    ), stringsAsFactors = FALSE)
    out <- data.table::as.data.table(out)

  } else {

    ## Split-apply for grouped aggregate
    groups     <- unique(sent_scores[, group_cols, with = FALSE])
    group_keys <- do.call(paste, c(sent_scores[, group_cols, with = FALSE],
                                   sep = "\x1f"))
    unique_keys <- unique(group_keys)

    rows <- lapply(unique_keys, function(key) {
      idx    <- which(group_keys == key)
      subset <- sent_scores[idx, ]

      means <- vapply(score_cols, function(col) {
        mean(subset[[col]], na.rm = TRUE)
      }, numeric(1))

      sds <- vapply(dims, function(col) {
        stats::sd(subset[[col]], na.rm = TRUE)
      }, numeric(1))
      names(sds) <- paste0("sd_", dims)

      grp_vals <- as.list(subset[1L, group_cols, with = FALSE])

      as.data.frame(c(
        grp_vals,
        as.list(means),
        list(n_sentences = length(idx)),
        as.list(sds)
      ), stringsAsFactors = FALSE)
    })

    out <- data.table::rbindlist(rows)
  }

  class(out) <- c("mde_by", class(out))
  return(out)
}
