DRAFT := draft-xyz-rats-psa-endorsements

KDRFC := kdrfc
KDRFC_ARGS := --v3
KDRFC_ARGS += --html
KDRFC_ARGS += --no-txt

MD := $(DRAFT).md

ART := $(wildcard art/*.txt)

MD_DEPS += $(ART)

HTML := $(MD:.md=.html)
CLEANFILES += $(HTML)

XML := $(MD:.md=.xml)
CLEANFILES += $(XML)

all: $(XML) $(HTML)
.PHONY: all

$(XML) $(HTML) : $(MD) $(MD_DEPS) ; $(KDRFC) $(KDRFC_ARGS) $<

clean: ; $(RM) $(CLEANFILES)
.PHONY: clean
