COMMIT_EPOCH = $(shell git log -1 --pretty=%ct)
COMMIT_DATE  = $(shell date -d @$(COMMIT_EPOCH) +"%F-%H%M")
TITLE_DATE   = $(shell date -d @$(COMMIT_EPOCH) +"%e %b %Y, %H:%M:%S")
VERSION      = $(shell git describe --tags)
FILENAME     = "data_governance_policy"

# Makes sure latexmk always runs
.PHONY: $(FILENAME)-$(COMMIT_DATE).pdf all clean
all: $(FILENAME)-$(COMMIT_DATE).pdf

$(FILENAME)-$(COMMIT_DATE).md: $(wildcard ???-*.md)
	VERSION=$(VERSION) TITLE_DATE="$(TITLE_DATE)" envsubst < 000-headers-toc.mdt > 000-headers-toc.md
	-rm $(FILENAME)-$(COMMIT_DATE).md 
	cat $? >> $(FILENAME)-$(COMMIT_DATE).md 

$(FILENAME)-$(COMMIT_DATE).tex: $(FILENAME)-$(COMMIT_DATE).md
	pandoc -s $(FILENAME)-$(COMMIT_DATE).md -t latex -o $(FILENAME)-$(COMMIT_DATE).tex

$(FILENAME)-$(COMMIT_DATE).pdf: $(FILENAME)-$(COMMIT_DATE).tex $(FILENAME)-$(COMMIT_DATE).xmpdata
	SOURCE_DATE_EPOCH=$(COMMIT_EPOCH) latexmk -pdf -lualatex -use-make $<
	evince $(FILENAME)-$(COMMIT_DATE).pdf

$(FILENAME)-$(COMMIT_DATE).xmpdata: source_xmpdata
	cp source_xmpdata $(FILENAME)-$(COMMIT_DATE).xmpdata

docx: $(FILENAME)-$(COMMIT_DATE).docx
odt: $(FILENAME)-$(COMMIT_DATE).odt

$(FILENAME)-$(COMMIT_DATE).docx: $(FILENAME)-$(COMMIT_DATE).md
	pandoc -s $(FILENAME)-$(COMMIT_DATE).md -t docx -o $(FILENAME)-$(COMMIT_DATE).docx
	libreoffice $(FILENAME)-$(COMMIT_DATE).docx

$(FILENAME)-$(COMMIT_DATE).odt: $(FILENAME)-$(COMMIT_DATE).md
	pandoc -s $(FILENAME)-$(COMMIT_DATE).md -t odt -o $(FILENAME)-$(COMMIT_DATE).odt
	libreoffice $(FILENAME)-$(COMMIT_DATE).odt

clean:
	latexmk -c
delete:
	latexmk -C
	rm $(FILENAME)-$(COMMIT_DATE).md $(FILENAME)-$(COMMIT_DATE).odt $(FILENAME)-$(COMMIT_DATE).docx $(FILENAME)-$(COMMIT_DATE).tex $(FILENAME)-$(COMMIT_DATE).pdf pdfa.xmpi *.xmpdata *.tex

