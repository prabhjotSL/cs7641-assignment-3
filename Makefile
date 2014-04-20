jruby_path = vendor/jruby-bin-1.7.10.tar.gz
all: latex clean zip ;
	echo 'Finished build'
latex:
	pdflatex mkirk9-analysis.latex
preview: latex ;
	open mkirk9-analysis.pdf
clean:
	find . -name mkirk9\* | grep -v latex | grep -v pdf |  xargs rm	
	rm -r assets
setup_jruby:
	./bin/setup_jruby.sh
	source ./bin/jruby_source.sh
zip:	
	git archive HEAD | gzip > ../mkirk9.tar.gz	

