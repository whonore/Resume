PDF := pdflatex
PDF_OPT := -output-format pdf -interaction nonstopmode -file-line-error
BIB := bibtex

PAPER := resume
TEX_FILES := $(wildcard *.tex)
PDF_FILES := $(PAPER).pdf

BIB_FILES := $(wildcard *.bib)

EXTRA_EXT := aux log out nav toc snm vrb bbl bcf blg run.xml
EXTRA_EXT := $(addprefix *., $(EXTRA_EXT)) *-blx.bib

.PHONY: all show-errors clean-nopdf clean

all: $(PDF_FILES)

%.pdf: %.tex $(TEX_FILES) $(BIB_FILES)
	$(PDF) $(PDF_OPT) $< $(BIB_FILES) > /dev/null
	$(BIB) $(basename $<) > /dev/null
	@$(PDF) $(PDF_OPT) $< $(BIB_FILES) > /dev/null

show-errors:
	@if ! grep -sE "^[^:]+:[0-9]+:.+$$" *.log; then echo "No errors."; fi

clean-nopdf:
	@rm -f $(EXTRA_EXT)

clean: clean-nopdf
	@rm -f $(PDF_FILES)
