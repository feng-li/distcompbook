all: gitbook

gitbook:
	Rscript -e 'bookdown::render_book("index.Rmd", "bookdown::gitbook", quiet=FALSE)'
	# sed -i -f htmlreplace.sed public/*.html

watch:
	while inotifywait -e modify -r .; do make gitbook; done

deploy:
	rsync -avp textbook/ feng.li:feng/distcompbook/

clean:
	rm -rf textbook
	rm -rf _bookdown_files
