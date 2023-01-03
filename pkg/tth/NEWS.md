# tth 4.12-1

o Declare `USE_C17` as a system requirement in order to avoid errors with
  K&R-style declarations in C23, provided by Brian D. Ripley, Kurt Hornik,
  and the CRAN team.

o Improvements in `Makefile.win` from Kurt Hornik and Tomas Kalibera.


# tth 4.12-0

o Upgrade to latest TtH version included in Debian (4.12).

o Updated `Makefile.win` according to "Writing R Extensions".

o Compile executables using flag `-w`.


# tth 4.3-3

o Added a line to the Windows `Makefile` necessary by new R Windows
  toolchain to include appropriate `Makeconf`.


# tth 4.3-2

o Added an optional character entity reference processing to `tth()`
  and `ttm()`. Thus, to unify how character entities are referenced
  a particular `mode` (`"named"`, `"hex"`, or `"dec"`) can be enfored. For
  example, the "GREEK SMALL LETTER MU" can be referenced as
  `&mu;` (or `&mgr;`) in named mode, or `&#x03BC;` (hex) or `&#956;` (dec).


# tth 4.3-1

o The argument `L` in `tth.control()` can now also be a character
  for the base file (no extension) for LaTeX auxiliary input.


# tth 4.03-0

o First CRAN release of R package `tth` with wrappers to the
  TeX-to-HTML converter `tth()` and the TeX-to-HTML/MathML
  converter `ttm()` from the TtH project of Ian H. Hutchinson,
  see <http://hutchinson.belmont.ma.us/tth/>.
  
o Both C code and R wrappers are distributed under the GPL-2,
  see the `README` file in the R source package for more details.
