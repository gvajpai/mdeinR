\name{highlight_mde}
\alias{highlight_mde}
\title{Highlight MDE Dimension Words in a Review}
\description{
Returns a character string with MDE dimension keywords wrapped in
annotation tags for qualitative inspection and debugging. The default
tag format wraps matched words in XML-style tags, e.g.
\verb{<sensory>aroma</sensory>}.
}
\usage{
highlight_mde(text, mde_dt = mdeinR::mde_dictionary, tag_format)
}
\arguments{
  \item{text}{A single character string (one review).}
  \item{mde_dt}{A data.table with columns \code{token} and \code{dimension}.
    Defaults to the built-in \code{mde_dictionary}.}
  \item{tag_format}{A \code{sprintf}-style format string with three
    \code{\%s} placeholders for: dimension name (open tag), matched word,
    and dimension name (close tag). Defaults to \verb{<%s>%s</%s>}.}
}
\value{
A character string with matched dimension words annotated with tags.
}
\examples{
\dontrun{
highlight_mde("The aroma was wonderful and staff were so caring.")
}
}
