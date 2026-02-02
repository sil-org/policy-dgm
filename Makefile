.DEFAULT_GOAL:=help
COMMIT_EPOCH = $(shell git log -1 --pretty=%ct)
COMMIT_DATE  = $(shell date -d @$(COMMIT_EPOCH) +"%F-%H%M")
TITLE_DATE   = $(shell date -d @$(COMMIT_EPOCH) +"%e %b %Y, %H:%M:%S")
VERSION      = $(shell git describe --tags)
FILENAME     = "data_governance_policy"
RELEASE_NAME = "SIL-Data-Governance $(VERSION)"

# Makes sure latexmk always runs
.PHONY: $(FILENAME)-$(COMMIT_DATE).pdf $(FILENAME)-$(COMMIT_DATE).pdf.sha256 all clean check checkall gdrive release

help:  ## Display this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n\nTargets:\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

all: $(FILENAME)-$(COMMIT_DATE).pdf $(FILENAME)-$(COMMIT_DATE).pdf.sha256 $(FILENAME)-$(COMMIT_DATE).docx $(FILENAME)-$(COMMIT_DATE).odt  ## Create all versions (no preview)

$(FILENAME)-$(COMMIT_DATE).md: $(wildcard ???-*.md)
	VERSION=$(VERSION) TITLE_DATE="$(TITLE_DATE)" envsubst < 000-headers-toc.mdt > 000-headers-toc.md
	-rm $(FILENAME)-$(COMMIT_DATE).md 
	cat $? >> $(FILENAME)-$(COMMIT_DATE).md 

$(FILENAME)-$(COMMIT_DATE).tex: $(FILENAME)-$(COMMIT_DATE).md
	pandoc -s $(FILENAME)-$(COMMIT_DATE).md -t latex -o $(FILENAME)-$(COMMIT_DATE).tex

$(FILENAME)-$(COMMIT_DATE).pdf: $(FILENAME)-$(COMMIT_DATE).tex $(FILENAME)-$(COMMIT_DATE).xmpdata
	SOURCE_DATE_EPOCH=$(COMMIT_EPOCH) latexmk -pdf -lualatex -use-make $<
        
$(FILENAME)-$(COMMIT_DATE).pdf.sha256:
	sha256sum $(FILENAME)-$(COMMIT_DATE).pdf > $(FILENAME)-$(COMMIT_DATE).pdf.sha256

$(FILENAME)-$(COMMIT_DATE).xmpdata: source_xmpdata
	cp source_xmpdata $(FILENAME)-$(COMMIT_DATE).xmpdata

check:	$(FILENAME)-$(COMMIT_DATE).pdf  ## Preview .pdf version
	evince $(FILENAME)-$(COMMIT_DATE).pdf

checkall:	check $(FILENAME)-$(COMMIT_DATE).docx $(FILENAME)-$(COMMIT_DATE).odt   ## Preview all version types
	libreoffice $(FILENAME)-$(COMMIT_DATE).docx
	libreoffice $(FILENAME)-$(COMMIT_DATE).odt

docx: $(FILENAME)-$(COMMIT_DATE).docx  ## Preview .docx version
	libreoffice $(FILENAME)-$(COMMIT_DATE).docx

odt: $(FILENAME)-$(COMMIT_DATE).odt  ## Preview .odt version
	libreoffice $(FILENAME)-$(COMMIT_DATE).odt

$(FILENAME)-$(COMMIT_DATE).docx: $(FILENAME)-$(COMMIT_DATE).md
	pandoc -s $(FILENAME)-$(COMMIT_DATE).md -t docx -o $(FILENAME)-$(COMMIT_DATE).docx

$(FILENAME)-$(COMMIT_DATE).odt: $(FILENAME)-$(COMMIT_DATE).md
	pandoc -s $(FILENAME)-$(COMMIT_DATE).md -t odt -o $(FILENAME)-$(COMMIT_DATE).odt

gdrive:  ## import .docx version to Google Drive
	gdrive files import $(FILENAME)-$(COMMIT_DATE).docx

release:  ## Create version Release on Github
	gh release create $(VERSION) --generate-notes -p -t $(RELEASE_NAME)  $(FILENAME)-$(COMMIT_DATE).pdf $(FILENAME)-$(COMMIT_DATE).pdf.sha256 $(FILENAME)-$(COMMIT_DATE).docx $(FILENAME)-$(COMMIT_DATE).odt
	
clean:  ## Clean up the LaTeX temp files using latexmk
	-latexmk -c
delete:	clean  ## Delete all the files not stored in Git repo
	-rm $(FILENAME)-$(COMMIT_DATE).md $(FILENAME)-$(COMMIT_DATE).odt $(FILENAME)-$(COMMIT_DATE).docx $(FILENAME)-$(COMMIT_DATE).tex $(FILENAME)-$(COMMIT_DATE).pdf* pdfa.xmpi *.xmpdata *.tex
	git restore 000-headers-toc.md

