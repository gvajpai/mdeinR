\name{update_valence_shifters}
\alias{update_valence_shifters}
\title{Update the Valence Shifters Table}
\description{
Returns a modified copy of the bundled \code{valence_shifters} table after
merging user-supplied overrides. Useful for adding domain-specific terms
such as restaurant-specific negators or amplifiers.
}
\usage{
update_valence_shifters(additions, base = mdeinR::valence_shifters)
}
\arguments{
  \item{additions}{A data.frame or data.table with columns \code{x}
    (character, the token) and \code{y} (integer, shifter type:
    1 = negator, 2 = amplifier, 3 = de-amplifier, 4 = adversative).
    Existing tokens are replaced; new tokens are appended.}
  \item{base}{A data.table to use as the base table. Defaults to the
    built-in \code{valence_shifters} table.}
}
\value{
A \code{data.table} suitable for passing to the \code{valence_shifters_dt}
argument of \code{mde()} or \code{mde_by()}.
}
\examples{
\dontrun{
custom <- data.frame(
  x = c("overpriced", "undercooked", "bland"),
  y = c(1L, 1L, 1L)
)
vs <- update_valence_shifters(custom)
mde("The food was amazing but overpriced.", valence_shifters_dt = vs)
}
}
