assets.img = logo.svg logo_wide.svg logo_text.svg

images.vector = oneforall.svg elearning.svg written.svg dynamic.svg

custom = mini.svg

.PHONY: all install

all : ${custom} ${assets.img} ${images.vector} latexclean

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
	mv rlogo.pdf rlogo.pdf.bak
	rm -f ${custom} ${assets.img} ${images.vector} *.pdf
	mv rlogo.pdf.bak rlogo.pdf

.PHONY: force
force: clean all
