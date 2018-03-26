#
# Makefile
#

FILE := assignment-1

pdf:
	@- pdflatex $(FILE).tex

openpdf: pdf
	@- open $(FILE).pdf
	@- make clean

clean:
	@- rm -f *.aux
	@- rm -f *.cut
	@- rm -f *.log
	@- rm -f *.out
	@- rm -f *.bbl
	@- rm -f *.blg
