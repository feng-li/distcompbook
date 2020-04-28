all: gitbook

gitbook:
	Rscript -e 'bookdown::render_book("index.Rmd", "bookdown::gitbook", quiet=FALSE)'

watch:
	xdg-open textbook/index.html; while inotifywait -e modify *.Rmd; do make gitbook; done

deploy:
	rsync -avp textbook/ feng.li:feng/distcompbook/

clean:
	rm -rf textbook
	rm -rf _bookdown_files
