# mdeinR 0.2.0

## Improvements

* **Tokenizer fixed** — `.tokenise()` now uses Unicode-aware regex extraction
  (`\p{L}+`) instead of whitespace splitting. Words attached to punctuation
  (e.g. "amazing," "aroma." "beautiful!") now correctly match dictionary
  tokens, improving hit rates across all reviews.

* **Adversative conjunction logic implemented** — Type-4 valence shifters
  (but, however, although, etc.) are now applied in the scoring loop.
  MDE words appearing after an adversative conjunction within the context
  window receive a reduced weight of `1 - n.neutral`, reflecting lower
  certainty for the clause following the conjunction.

* **Lookup caching** — Dictionary and valence-shifter lookup objects are
  now precompiled and cached at the package level via `.build_lookups()`.
  Repeated calls to `mde()` on the same dictionary no longer rebuild the
  lookup structures on every call, improving performance for large corpora.

* **`mde_by()` aggregation refactored** — Grouped aggregation now uses
  `data.table` j-expression grouping instead of manual split-apply loops,
  improving performance and reducing memory usage for large group counts.

# mdeinR 0.1.0

* Initial release.
* Implements `mde()` and `mde_by()` for sentence-level and aggregate MDE scoring.
* Ships built-in MDE dictionary (324 tokens) and valence shifters (248 tokens).
* Includes `get_sentences()` tokeniser and `highlight_mde()` annotation utility.
