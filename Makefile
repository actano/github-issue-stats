ISSUES_JSONS = $(shell find repos -name "issues.json")

TIMELINES = $(patsubst repos/%/issues.json,repos/%/timeline.tsv,$(ISSUES_JSONS))
CFD_PNGS = $(patsubst repos/%/issues.json,repos/%/cfd.svg,$(ISSUES_JSONS))
OPEN_PNGS = $(patsubst repos/%/issues.json,repos/%/open.svg,$(ISSUES_JSONS))
LT_PNGS = $(patsubst repos/%/issues.json,repos/%/lt.svg,$(ISSUES_JSONS))
LTS_PNGS = $(patsubst repos/%/issues.json,repos/%/lts.svg,$(ISSUES_JSONS))
AS_PNGS = $(patsubst repos/%/issues.json,repos/%/as.svg,$(ISSUES_JSONS))

all: $(CFD_PNGS) $(OPEN_PNGS) $(LT_PNGS) $(LTS_PNGS) $(AS_PNGS)

clean:
	rm -f $(TIMELINES) $(CFD_PNGS) $(OPEN_PNGS) $(LT_PNGS) $(LTS_PNGS) $(AS_PNGS)

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

.PRECIOUS: repos/%/timeline.tsv
repos/%/timeline.tsv: repos/%/issues.json bin/ghis lib/ghis.rb
	ruby -Ilib bin/ghis $< > $@
