ISSUES_JSONS = $(shell find repos -name "issues.json")

TIMELINE = $(patsubst repos/%/issues.json,repos/%/timeline.tsv,$(ISSUES_JSONS))
TIMELINE_LABELS = $(patsubst repos/%/issues.json,repos/%/timeline-of-label-numbers.tsv,$(ISSUES_JSONS))
CFD_PNGS = $(patsubst repos/%/issues.json,repos/%/cfd.svg,$(ISSUES_JSONS))
OPEN_PNGS = $(patsubst repos/%/issues.json,repos/%/open.svg,$(ISSUES_JSONS))
LT_PNGS = $(patsubst repos/%/issues.json,repos/%/lt.svg,$(ISSUES_JSONS))
LTS_PNGS = $(patsubst repos/%/issues.json,repos/%/lts.svg,$(ISSUES_JSONS))
AS_PNGS = $(patsubst repos/%/issues.json,repos/%/as.svg,$(ISSUES_JSONS))
OPEN_LABEL_GRAPH = $(patsubst repos/%/issues.json,repos/%/open-by-label.svg,$(ISSUES_JSONS))

ALL_GENERATED_FILES = $(TIMELINE) $(TIMELINE_LABELS) $(CFD_PNGS) $(OPEN_PNGS) $(LT_PNGS) \
$(LTS_PNGS) $(AS_PNGS)  $(OPEN_LABEL_GRAPH)

all: $(CFD_PNGS) $(OPEN_PNGS) $(LT_PNGS) $(LTS_PNGS) $(AS_PNGS) $(OPEN_LABEL_GRAPH)

clean:
	rm -f $(ALL_GENERATED_FILES)

repos/%/cfd.svg: repos/%/timeline.tsv scripts/cfd.gpi
	gnuplot -e "tsv='$<'" scripts/cfd.gpi > $@

repos/%/open.svg: repos/%/timeline.tsv scripts/open.gpi
	gnuplot -e "tsv='$<'" scripts/open.gpi > $@

repos/%/lt.svg: repos/%/timeline.tsv scripts/lt.gpi
	gnuplot -e "tsv='$<'" scripts/lt.gpi > $@

repos/%/lts.svg: repos/%/timeline.tsv scripts/lts.gpi
	gnuplot -e "tsv='$<'" scripts/lts.gpi > $@

repos/%/as.svg: repos/%/timeline.tsv scripts/as.gpi
	gnuplot -e "tsv='$<'" scripts/as.gpi > $@

repos/%/open-by-label.svg: repos/%/timeline-of-label-numbers.tsv scripts/open-by-label.gpi
	gnuplot -e "tsv='$<'" scripts/open-by-label.gpi > $@

.PRECIOUS: repos/%/timeline.tsv repos/%/timeline-of-label-numbers.tsv
repos/%/timeline.tsv: repos/%/issues.json bin/ghis lib/ghis.rb
	ruby -Ilib bin/ghis $< > $@

repos/%/timeline-of-label-numbers.tsv: repos/%/issues.json bin/ghisbt lib/ghis.rb
	ruby -Ilib bin/ghisbt $< > $@
