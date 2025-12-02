.PHONY: all

all:
	ignite build
	rm -fr docs/
	mv Build docs
	cp CNAME docs/CNAME
	git add -A
	git commit -m "Update links" || true
	git push
