COMMIT_EPOCH = $(shell git log -1 --pretty=%ct)
COMMIT_DATE = $(shell date -d @$(COMMIT_EPOCH) +"%F-%H%M")
FILENAME = "data_governance_policy"

# Makes sure latexmk always runs
.PHONY: $(FILENAME)-$(COMMIT_DATE).pdf all clean
all: $(FILENAME)-$(COMMIT_DATE).pdf

$(FILENAME)-$(COMMIT_DATE).tex: $(wildcard ???-*.md)
	COMMIT_DATE=$(COMMIT_DATE) envsubst < 000-headers-toc.mdt > 000-headers-toc.md
	pandoc -s $? -t latex -o $(FILENAME)-$(COMMIT_DATE).tex

$(FILENAME)-$(COMMIT_DATE).pdf: $(FILENAME)-$(COMMIT_DATE).tex $(FILENAME)-$(COMMIT_DATE).xmpdata
	SOURCE_DATE_EPOCH=$(COMMIT_EPOCH) latexmk -pdf -lualatex -use-make $<
	evince $(FILENAME)-$(COMMIT_DATE).pdf

$(FILENAME)-$(COMMIT_DATE).xmpdata: source_xmpdata
	cp source_xmpdata $(FILENAME)-$(COMMIT_DATE).xmpdata

docx: $(FILENAME)-$(COMMIT_DATE).docx
odt: $(FILENAME)-$(COMMIT_DATE).odt

$(FILENAME)-$(COMMIT_DATE).docx: $(wildcard ???-*.md)
	COMMIT_DATE=$(COMMIT_DATE) envsubst < 000-headers-toc.mdt > 000-headers-toc.md
	pandoc -s $? -t docx -o $(FILENAME)-$(COMMIT_DATE).docx
	libreoffice $(FILENAME)-$(COMMIT_DATE).docx

$(FILENAME)-$(COMMIT_DATE).odt: $(wildcard ???-*.md)
	COMMIT_DATE=$(COMMIT_DATE) envsubst < 000-headers-toc.mdt > 000-headers-toc.md
	pandoc -s $? -t odt -o $(FILENAME)-$(COMMIT_DATE).odt
	libreoffice $(FILENAME)-$(COMMIT_DATE).odt

clean:
	latexmk -c
delete:
	latexmk -C
	rm $(FILENAME)-$(COMMIT_DATE).odt $(FILENAME)-$(COMMIT_DATE).docx $(FILENAME)-$(COMMIT_DATE).tex $(FILENAME)-$(COMMIT_DATE).pdf pdfa.xmpi *.xmpdata *.tex

