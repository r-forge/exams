#
# Extracting current package version
VERSION := $(shell grep '^Version:' DESCRIPTION | awk '{print $$2}')

.PHONY: install build
build:
	@echo Building current version: $(VERSION)
	(cd ../ && R CMD build c403)
install: build
	@echo Installing current version: $(VERSION)
	(cd ../ && R CMD INSTALL c403_$(VERSION).tar.gz)
check: build
	@echo Checking current version: $(VERSION)
	(cd ../ && R CMD check --as-cran c403_$(VERSION).tar.gz)

package: doc vignettes
	make install

doc: .
	Rscript -e "devtools::load_all('.')" && \
		Rscript -e "devtools::document('.')"

vignettes: .
	Rscript -e "devtools::build_vignettes('.')"


