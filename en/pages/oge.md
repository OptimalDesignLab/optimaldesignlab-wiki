# Office of Graduate Education

## Anthony's lessons on submitting and formating the thesis (July 26th 2019)

My OGE thesis edits are almost done; I'm awaiting feedback on my latest iteration with OGE. I'll list a few comments that might help those who are approaching the process themselves, followed by my advice for references:

1. Center all figures - based on entire figure, not the box of the graph. For example, the left edge of the y-axis label text needs to be 2 and 1/8 inches from the left border of the paper, and the right edge of the graph's box needs to be 2 and 1/8 inches from the right border of the paper. I didn't know that the y-axis label is considered part of the figure to be centered.
2. Don't have equations run into margins.
3. The official RPI OGE LaTeX template worked quite well for me. The only thing that wasn't up to the standard was that my headings for the list of figures, list of tables, and contents were not entirely uppercase. To fix this, I added the following to my title page `.tex` file:
   ```
   \renewcommand{\contentsname}{CONTENTS}
   \renewcommand{\listfigurename}{LIST OF FIGURES}
   \renewcommand{\listtablename}{LIST OF TABLES}
   ```
   This was placed above the line containing `\titlepage`.

### Notes on References

I used the AIAA reference style: https://www.aiaa.org/publications/journals/reference-style-and-format

At first glance, it appears vague or loose in terms of guidelines, but it actually is not. Follow it to the character. Some *highlights* of my reference edits:

* Fully spell out the month whenever necessary: `September`, not `Sep`.
* Do not include the month if you are including the issue (e.g. `No. 4`)
* Pay attention to the "Meeting Paper" section; for an AIAA conference paper you'll have to find the exact paper number and month. No name of conference or location.
* Books must be in the exact format shown by the "Chapter in a Book" example in the link. In other words, you must find the relevant chapter and include it in the citation, not just the full book. You must have the edition, the publisher, the publishing city, the year, and the pages of the chapter.
* NASA reports are to be formatted in the exact fashion shown. You'll have to find the report designation, like "NASA SP-252".
* All references must be in title case, regardless of how the authors published it. So, the paper "Direct numerical simulation of compressible turbulent channel flows using the discontinuous Galerkin method" must be written as "Direct Numerical Simulation of Compressible Turbulent Channel Flows using the Discontinuous Galerkin Method".
* Online references must be listed like the following:
  ```
  Bezanson, J., Edelman, A., Karpinski, S., and Shah, V. B., "Julia Micro-Benchmarks," [online], https://julialang.org/benchmarks, 2019, [retrieved 7 June 2019].
  ```
* Any reference that doesn't neatly fit into the normal categories is considered a report. Here are a couple examples; note the "Rept." placement after the company or organization:
  ```
  Lineberger, R. S., and Hussain, A., "Program Management in Aerospace and Defense: Still Late and Over Budget," Deloitte Consulting LLP Rept., 2016.
  Berryman, S., Bjornson, R., Feeney, J., Haupt, T., Kohl, J., Mainwaring, A., McBryan, O., and McKinley, P., "MPI: A Message-Passing Interface Standard," Message Passing Interface Forum Rept., September 2012.
  ```
* There must be a comma in between all authors. The `aiaa.bst` bibliography style file will do this properly by default for a reference with three or more authors, but it will not place the comma if the reference has two authors. By default, it generates: "Ashley, A. and Hicken, J. E., ...", but it must be "Ashley, A., and Hicken, J. E.". Note the comma after my first initial. This is fixed by editing the `aiaa.bst` file. Find it (on my Mac, it was located at `/usr/local/texlive/2015/texmf-dist/bibtex/bst/aiaa`), and go to the `FUNCTION {format.names}` function. Look for the `numnames #2` block, which by default is
  ```
              numnames #2 >
                { "," * }
                'skip$
              if$
  ```
  I'll spare you all the RPN details of this ridiculous programming language, but basically it's an if statement that either places a comma or not. I wanted it to always place a comma, so I just replaced the `'skip$` line with one that places a comma. I'm sure there's a more elegant way to do this, but it was 2:30am while I was on vacation in California, and I just wanted it done. Here's what that block became:
  ```
              numnames #2 >
                { "," * }
                { "," * }
              if$
  ```
  In my aiaa.bst, this block was lines 428-431.

I think that's it! I hope this saves some of you some time.
