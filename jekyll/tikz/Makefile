.PHONY: install all

all: all_pdf all_svg

install: all
	cp *.svg images/vector/
	rm images/vector/logo.svg
	cp logo.svg assets/img/

all_% :
	rm -f _include.tex
	dst=$@; dst="$${dst##all_}" ; \
			for tikz in *.tex ; do if [ "$$tikz" != "template.tex" ] ; \
				then make $${tikz%.tex}.$$dst ; \
				fi ; done

%.pdf : %.tex
	rm -f _include.tex
	ln -s $^ _include.tex
	pdflatex template.tex
	rm -f _include.tex
	rm -f $@
	mv template.pdf $@
	make latexclean

%.png : %.pdf
	convert -density 900 $^ $@

%.svg : %.pdf
	pdf2svg $^ $@

.PHONY: latexclean
latexclean:
	rm -f *.aux  *.log

.PHONY: clean
clean: latexclean
	rm -f *.svg *.png *.pdf
