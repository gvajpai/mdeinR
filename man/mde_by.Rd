\name{mde_by}
\alias{mde_by}
\title{Score MDE Dimensions Aggregated by Grouping Variable(s)}
\description{
A convenience wrapper around \code{mde} that averages sentence-level MDE
dimension scores within one or more grouping variables, such as restaurant,
reviewer, or time period.
}
\usage{
mde_by(text, by = NULL, ...)
}
\arguments{
  \item{text}{A character vector, data.frame, or output of \code{get_sentences()}.}
  \item{by}{Character vector of column names in \code{text} to group by, or
    a list of grouping vectors. Pass \code{NULL} (default) to aggregate the
    whole corpus into one row.}
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
\dontrun{
library(data.table)
df <- data.table(
  restaurant = c("A", "A", "B", "B"),
  text = c(
    "The aroma was stunning.",
    "Staff were so caring.",
    "Very educational cuisine.",
    "Nothing special."
  )
)
mde_by(df, by = "restaurant")
}
}
