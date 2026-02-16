#
# Extracting current package version
VERSION := $(shell grep '^Version:' DESCRIPTION | awk '{print $$2}')

.PHONY: install build clean
build:
	@echo Building current version: $(VERSION)
	(cd ../ && R CMD build c403)
install: doc build
	@echo Installing current version: $(VERSION)
	(cd ../ && R CMD INSTALL c403_$(VERSION).tar.gz)
	make clean
check: build
	@echo Checking current version: $(VERSION)
	(cd ../ && R CMD check c403_$(VERSION).tar.gz)
	# The checks run w/ R CMD check (w/o --as-cran)
clean:
	-rm ../c403_*tar.gz

package: doc vignettes
	make install

doc: .
	Rscript -e "devtools::load_all('.')" && \
		Rscript -e "devtools::document('.')"

vignettes: .
	Rscript -e "devtools::build_vignettes('.')"


