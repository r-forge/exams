target = ../www/

.PHONY: dev
dev: clean
	bundle exec jekyll serve --incremental --config _config.yml,_config_dev.yml

.PHONY: clean
clean:
	bundle exec jekyll clean

.PHONY: install
install: clean
	bundle exec jekyll build --config _config.yml
	svn up ${target}
	rsync -rt --delete _site/ ${target}
	chmod -R  o+r ${target}
	svn status ${target} | grep '^!' | awk '{print $$2}' | xargs -r svn delete
	svn status ${target} | grep '^?' | awk '{print $$2}' | xargs -r svn add
	svn commit ${target} -m 'jekyll make install'

