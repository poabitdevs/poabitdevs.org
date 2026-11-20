all: build

write-build-info:
	mkdir -p _data
	echo "sha: \"$$(git rev-parse --short HEAD 2>/dev/null || echo local)\"" > _data/build.yml
	echo "timestamp: \"$$(date -u +%Y-%m-%dT%H:%M:%SZ)\"" >> _data/build.yml
	echo "pipeline: \"local\"" >> _data/build.yml

preview: write-build-info
	bundle exec jekyll clean
	bundle exec jekyll serve --future --drafts --unpublished --incremental

build: write-build-info
	bundle exec jekyll clean
	bundle exec jekyll build --future --drafts --unpublished
