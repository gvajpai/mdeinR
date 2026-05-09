MIT License

## mdeinR (original code, MDE lexicon, and package design)

Copyright (c) 2025 Gopi Nath Vajpai, Timothy Webb, Srikanth Beldona

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

---

## Derived work notice — sentimentr

Portions of this package are derived from **sentimentr** by Tyler W. Rinker,
which is also distributed under the MIT License:

Copyright (c) 2017 Tyler Rinker

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

The following elements of mdeinR are derived from or substantially based
on sentimentr (https://github.com/trinker/sentimentr):

1. **Scoring algorithm** (R/mde.R): The sentence-level scoring approach —
   raw score of 1/word_count per matched token, context-window scanning for
   valence shifters, and the amplifier/de-amplifier/negator weight formulas —
   is adapted from sentimentr's emotion() function.

2. **Function interface** (R/mde.R): The parameter names and default values
   n.before = 5, n.after = 2, amplifier.weight = 0.8, n.neutral = 0.2, and
   neutral.nonword.check are taken directly from sentimentr's emotion()
   signature.

3. **Valence shifter type codes** (data-raw/valence_shifters.csv): The
   integer coding scheme (1 = negator, 2 = amplifier, 3 = de-amplifier,
   4 = adversative conjunction) and the token lists in valence_shifters.csv
   are derived from sentimentr's valence_shifters table.

