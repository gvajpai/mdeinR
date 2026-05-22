\name{mde_by}
\alias{mde_by}
\title{Score MDE Dimensions Aggregated by Grouping Variable(s)}
\description{
A convenience wrapper around \code{mde} that averages sentence-level MDE
dimension scores within one or more grouping variables, such as restaurant,
reviewer, or star rating.
}
\usage{
mde_by(text, by = NULL, text_col = NULL, ...)
}
\arguments{
  \item{text}{A character vector, data.frame, or output of \code{get_sentences()}.}
  \item{by}{Character vector of column names in \code{text} to group by.
    Pass \code{NULL} (default) to aggregate the whole corpus into one row.}
  \item{text_col}{Character. Name of the column containing review text when
    \code{text} is a data.frame. When \code{NULL} (default), the function
    automatically selects the character column with the longest average string
    length. Specify explicitly when your data has multiple character columns
    and auto-detection may be ambiguous (e.g. \code{text_col = "review_text"}).}
  \item{...}{Additional arguments passed to \code{mde()}.}
}
\value{
A \code{data.table} with grouping columns (if any) plus mean scores for each
MDE dimension, \code{mde_count}, \code{word_count}, \code{n_sentences}, and
standard deviations (\code{sd_sensory}, etc.).
}
\references{
Vajpai, G. N., Webb, T., & Beldona, S. (2025). Designing a memorable
dining experience lexicon based on theory and text mining.
\emph{International Journal of Hospitality Management}, 130, 104245.
\doi{10.1016/j.ijhm.2025.104245}
}
\examples{
# Whole-corpus aggregate using built-in sample dataset
mde_by(restaurant_reviews$text)

# Group by restaurant
\dontrun{
mde_by(restaurant_reviews, by = "restaurant")
}

# Group by star rating
\dontrun{
mde_by(restaurant_reviews, by = "stars")
}

# Explicitly specify the text column (avoids any ambiguity)
\dontrun{
mde_by(restaurant_reviews, by = "restaurant", text_col = "text")
}

# Group by multiple columns
\dontrun{
mde_by(restaurant_reviews, by = c("restaurant", "stars"))
}
}
