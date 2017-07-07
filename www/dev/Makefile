
.PHONY: dev
dev: clean
	bundle exec jekyll serve --incremental --config _config.yml,_config_dev.yml

.PHONY: clean
clean:
	bundle exec jekyll clean

.PHONY: install
install: clean
	bundle exec jekyll build --config _config.yml,_config_savoia.yml
	rsync -rt --delete _site/ ../www/dev/
	chmod -R  o+r ../www/dev

