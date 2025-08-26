VERSION := $(shell awk '/^## Version:/ {print $$3; exit}' GSE/GSE.toc)

.PHONY: dist

dist:
	mkdir -p dist
	zip -rq dist/GSE-Ascension-$(VERSION).zip GSE GSE_GUI GSE_LDB README.md CHANGELOG.md CONTRIBUTING.md PORT_NOTES.md
