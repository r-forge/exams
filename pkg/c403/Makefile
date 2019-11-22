

#test: $(PKG)
#	make package
#	Rscript -e "library('foehnix'); testthat::test_dir('foehnix/tests/testthat')"

package: doc vignettes
	make install

doc: .
	Rscript -e "devtools::load_all('.')" && \
		Rscript -e "devtools::document('.')"

check: .
	make install && Rscript -e "devtools::check('.')"

install: .
	make doc
	Rscript -e "devtools::install('.', upgrade = 'always')"

vignettes: .
	Rscript -e "devtools::build_vignettes('.')"
