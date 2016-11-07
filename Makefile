vadere_path := ../../vadere
traingen_path := ../../traingen/traingen
usability_study_path := ../survey/seating/data-usability-study
seatingdc_path := ../../seating-datacollection/SeatingDataCollection
seating_data_path := ../../seating-data/data
seating_scripts_path := ../../seating-data/scripts
seating_pilot := ../survey/pilot
bib_files := ../Literatur/Literature.bib ../../Literatur/Literature.bib
tex_files := $(shell find . chapters/ -maxdepth 1 -name '*.tex' -and -not -name 'thesis.tex')
all_tex_files := $(shell find . chapters/ -maxdepth 1 -name '*.Rtex' -or -name '*.tex' -and -not -name 'thesis.tex')

.PHONY: all clean tags

all: thesis.pdf tags

thesis.pdf: thesis.tex \
	pictures/image.tex \
	$(bib_files) \
	helpers.R \
	appendix/usability-study.pdf \
	tables/event-type-descriptions.tex \
	listings/trainbuilder-interface.java \
	listings/traingen-help.txt \
	listings/db-export.java \
	listings/primitive-event-logger.sh \
	listings/target-interface-for-listener.java \
	listings/seating-model-update.java \
	listings/attributessource-spawndistribution.java \
	listings/attributessource-maximumspawnnumbertotal.java \
	listings/generate-data.R \
	listings/data-collector.R \
	figures/et423-draw.png \
	figures/et423-techdraw.png \
	figures/et423-techdraw-interior.jpg \
	figures/screenshot-*.png \
	figures/train-simulation.png \
	figures/seating-algorithm.eps \
	figures/model-framework.eps \
	figures/seatingmodel.eps \
	figures/db-schema.eps \
	figures/uml-class-diagram-actions.eps \
	figures/uml-class-diagram-model.eps
	latexmk -bibtex -lualatex thesis.tex

thesis.tex: *.Rtex chapters/*.Rtex $(tex_files) \
			$(seating_data_path)/* $(seating_scripts_path)/*.R \
			$(seating_pilot)/*
	R -q -e 'library(knitr); knit("thesis.Rtex", out = "thesis.tex")'

tables/event-type-descriptions.tex: tables/event-type-descriptions.txt tables/event-types.txt
	# join --check-order -t $$'\t' tables/event-type-descriptions.txt tables/event-types.txt \
	join -t $$'\t' tables/event-type-descriptions.txt tables/event-types.txt \
		| awk -F'\t' 'BEGIN{OFS="\t"}; {print "\\verb|"$$1"|", $$2}' \
		| tools/csv2table.sh '\t' '1,2' \
		> tables/event-type-descriptions.tex

tables/event-types.txt: $(seatingdc_path)/app/src/main/java/edu/hm/cs/vadere/seating/datacollection/model/LogEventType.java
	awk '/enum LogEventType/{s=1}; s&&/^ *[A-Z_]+/{if (match($$0, /[A-Z_]+/)) print substr($$0, RSTART, RLENGTH)}' \
		< $(seatingdc_path)/app/src/main/java/edu/hm/cs/vadere/seating/datacollection/model/LogEventType.java \
		> tables/event-types.txt
		# | awk '{print ++i "\t" $0}' \

listings/trainbuilder-interface.java: $(traingen_path)/src/main/java/edu/hm/cs/vadere/seating/traingen/TrainBuilder.java
	#TMP=$(mktemp -d)
	# compiling is too complicated
	#javac -d "$TMP" -sourcepath $(traingen_path)/src/main/java/ $(traingen_path)/src/main/java/edu/hm/cs/vadere/seating/traingen/TrainBuilder.java
	#javap -classpath "$TMP" -public edu.hm.cs.vadere.seating.traingen.TrainBuilder > listings/trainbuilder-interface.java
	# Project must be compiled and class files must be in target/ folder
	javap -classpath $(traingen_path)/target/classes/ -public edu.hm.cs.vadere.seating.traingen.TrainBuilder > listings/trainbuilder-interface.java

listings/traingen-help.txt: $(traingen_path)/src/main/resources/doc.txt
	cp $(traingen_path)/src/main/resources/doc.txt listings/traingen-help.txt

listings/generate-data.R: $(seating_scripts_path)/analysis.R
	tools/extract-r-function.sh generateMoreData $(seating_scripts_path)/analysis.R \
		| sed -r -n '/ {8}state\b/,/ {8}\}/ p' \
		| tools/remove-indentation.sh > listings/generate-data.R

listings/data-collector.R: $(seating_scripts_path)/collector.R
	tools/extract-r-function.sh createCollectDataFunction $(seating_scripts_path)/collector.R \
		| tools/skip-lines.sh nPersonsCompartment personDiagonal > listings/data-collector.R

listings/attributessource-spawndistribution.java: $(vadere_path)/VadereState/src/org/vadere/state/attributes/scenario/AttributesSource.java
	grep -E 'String CONSTANT_DISTRIBUTION|String interSpawnTimeDistribution|List<Double> distributionParameters' \
				$(vadere_path)/VadereState/src/org/vadere/state/attributes/scenario/AttributesSource.java \
		| tools/remove-indentation.sh > listings/attributessource-spawndistribution.java

listings/attributessource-maximumspawnnumbertotal.java: $(vadere_path)/VadereState/src/org/vadere/state/attributes/scenario/AttributesSource.java
	grep 'int maxSpawnNumberTotal' $(vadere_path)/VadereState/src/org/vadere/state/attributes/scenario/AttributesSource.java \
		| tools/remove-indentation.sh > listings/attributessource-maximumspawnnumbertotal.java

listings/target-interface-for-listener.java: $(vadere_path)/VadereState/src/org/vadere/state/scenario/Target.java
	tools/extract-java-methods.sh addListener 3 $(vadere_path)/VadereState/src/org/vadere/state/scenario/Target.java \
		| tools/remove-indentation.sh > listings/target-interface-for-listener.java

listings/seating-model-update.java: $(vadere_path)/VadereSimulator/src/org/vadere/simulator/models/seating/SeatingModel.java
	tools/extract-java-method.sh update $(vadere_path)/VadereSimulator/src/org/vadere/simulator/models/seating/SeatingModel.java \
		| tools/remove-indentation.sh > listings/seating-model-update.java

appendix/usability-study.pdf: appendix/usability-study.tex
	cd appendix/ && latexmk -pdf usability-study.tex

appendix/usability-study.tex: $(usability_study_path)/Usability\ study.org
	emacs -nw --batch \
		--visit=$(usability_study_path)/Usability\ study.org \
		--funcall=org-latex-export-to-latex
	@# Shit, I have to escape \ for make
	sed "/^\\\begin{document}/a\\\\\\pagenumbering{gobble}" $(usability_study_path)/Usability\ study.tex > appendix/usability-study.tex

figures/seating-algorithm.eps: figures/seating-algorithm.uxf
	tools/umlet2vec.sh figures/seating-algorithm.uxf

figures/seatingmodel.eps: figures/seatingmodel.uxf
	tools/umlet2vec.sh figures/seatingmodel.uxf

figures/uml-class-diagram-actions.eps: figures/uml-class-diagram-actions.uxf
	tools/umlet2vec.sh figures/uml-class-diagram-actions.uxf

figures/model-framework.eps: figures/model-framework.uxf
	tools/umlet2vec.sh figures/model-framework.uxf

figures/uml-class-diagram-model.eps: figures/uml-class-diagram-model.uxf
	tools/umlet2vec.sh figures/uml-class-diagram-model.uxf

figures/db-schema.eps: figures/db-schema.uxf
	tools/umlet2vec.sh figures/db-schema.uxf

listings/db-export.java: $(seatingdc_path)/app/src/main/java/edu/hm/cs/vadere/seating/datacollection/DatabaseExportTask.java
	tools/extract-java-method.sh doInBackground $(seatingdc_path)/app/src/main/java/edu/hm/cs/vadere/seating/datacollection/DatabaseExportTask.java > listings/db-export.java

listings/primitive-event-logger.sh: ../survey/rate/collect.sh
	cp ../survey/rate/collect.sh listings/primitive-event-logger.sh

figures/train-simulation.png: figures/train-simulation.svg
	inkscape --export-png=figures/train-simulation.png --export-area=0:260:750:1050 figures/train-simulation.svg
	@#inkscape --export-png=figures/train-simulation.png --export-area=0:60:750:1050 figures/train-simulation.svg


tags: $(all_tex_files) $(bib_files)
	ctags $(all_tex_files) $(bib_files)

clean:
	rm -f thesis_final.pdf thesis.pdf thesis.tex
	rm -f *.fdb_latexmk *.latexmain *.aux *.fls *.log *.toc *.fls *.lof *.lol *.out *.dvi *.brf *.bbl *.blg *.lot
	rm -f figures/*.eps
	rm -f figures/*-eps-converted-to.pdf
	rm -f figures/train-simulation.png
	rm -f listings/*
	rm -f tables/event-type-descriptions.tex tables/event-types.txt
	rm -f ../survey/seating/data-usability-study/usability-study.{tex,tex~,pdf}
	rm -f appendix/usability-study.*
	rm -f thesis-tikzDictionary
	@# temp folder from Knitr:
	rm -rf figures/knitr/
