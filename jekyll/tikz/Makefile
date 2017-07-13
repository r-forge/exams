assets.img = logo.svg

images.vector = oneforall.svg elearning.svg written.svg dynamic.svg

.PHONY: all install

all : ${assets.img} ${images.vector} latexclean

install: all
	cp ${images.vector} ../images/vector/
	cp ${assets.img} ../assets/img/

%.pdf : %.tex
	pdflatex $^

%.png : %.pdf
	convert -density 900 $^ $@

%.svg : %.pdf
	pdf2svg $^ $@

.PHONY: latexclean
latexclean:
	rm -f *.aux  *.log

.PHONY: clean
clean: latexclean
	rm -f ${assets.img} ${images.vector} *.pdf

.PHONY: force
force: clean all
