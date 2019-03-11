PREFIX=/usr
DESTDIR=

EXECUTABLE_NAME := $(shell grep ^EXECUTABLE_NAME src/systemd-zram.sh | cut -d\' -f2)
VERSION := $(shell grep ^VERSION src/$(EXECUTABLE_NAME).sh | cut -d\' -f2)
LICENSE := $(shell grep ^LICENSE src/$(EXECUTABLE_NAME).sh | cut -d\' -f2)

DOCS= ChangeLog README.md AUTHORS THANKS
MAN = $(patsubst %.rst,%.gz,$(wildcard man/*.rst))

DEBIANPKG = $(EXECUTABLE_NAME)_$(VERSION)_all.deb
ARCHPKG = $(EXECUTABLE_NAME)-$(VERSION)-1-any.pkg.tar.xz

default: man

man: $(MAN)
%.gz: %.rst
	rst2man $^ | gzip -c > $@
man_clean:
	rm -f $(MAN)

install: $(DOCS)
	install -d -m 755 "$(DESTDIR)$(PREFIX)/share/doc/$(EXECUTABLE_NAME)"
	install -Dm 644 $^ "$(DESTDIR)$(PREFIX)/share/doc/$(EXECUTABLE_NAME)"
	install -Dm 755 src/$(EXECUTABLE_NAME).sh "$(DESTDIR)$(PREFIX)/bin/$(EXECUTABLE_NAME)"
	install -d -m 755 "$(DESTDIR)$(PREFIX)/share/licenses/$(EXECUTABLE_NAME)"
	install -Dm 644 LICENSE "$(DESTDIR)$(PREFIX)/share/licenses/$(EXECUTABLE_NAME)/COPYING"
	install -Dm 644 src/$(EXECUTABLE_NAME).service "$(DESTDIR)/lib/systemd/system/$(EXECUTABLE_NAME).service"
	install -Dm 644 man/$(EXECUTABLE_NAME).1.gz $(DESTDIR)$(PREFIX)/share/man/man1/$(EXECUTABLE_NAME).1.gz

arch_install: $(DOCS)
	install -d -m 755 "$(DESTDIR)$(PREFIX)/share/doc/$(EXECUTABLE_NAME)"
	install -Dm 644 $^ "$(DESTDIR)$(PREFIX)/share/doc/$(EXECUTABLE_NAME)"
	install -Dm 755 src/$(EXECUTABLE_NAME).sh "$(DESTDIR)$(PREFIX)/bin/$(EXECUTABLE_NAME)"
	install -d -m 755 "$(DESTDIR)$(PREFIX)/share/licenses/$(EXECUTABLE_NAME)"
	install -Dm 644 LICENSE "$(DESTDIR)$(PREFIX)/share/licenses/$(EXECUTABLE_NAME)/COPYING"
	install -Dm 644 src/$(EXECUTABLE_NAME).service "$(DESTDIR)$(PREFIX)/lib/systemd/system/$(EXECUTABLE_NAME).service"
	install -Dm 644 man/$(EXECUTABLE_NAME).1.gz $(DESTDIR)$(PREFIX)/share/man/man1/$(EXECUTABLE_NAME).1.gz


uninstall:
	rm -f $(PREFIX)/bin/$(EXECUTABLE_NAME)
	rm -f /lib/systemd/system/$(EXECUTABLE_NAME).service
	rm -rf $(PREFIX)/share/licenses/$(EXECUTABLE_NAME)/
	rm -rf $(PREFIX)/share/doc/$(EXECUTABLE_NAME)/
	rm -f $(PREFIX)/share/man/man1/$(EXECUTABLE_NAME).1.gz

clean: arch_clean debian_clean man_clean

debian_pkg: $(DEBIANPKG)

debian:
	mkdir -p $@

debian/changelog: ChangeLog debian
	cp $< $@

debian/README: README.md debian
	cp $< $@

debian/compat: dpkg/compat debian
	cp $< $@

debian/rules: dpkg/rules debian
	cp $< $@

debian/control: dpkg/control debian
	cp $< $@

debian/copyright: debian/changelog debian/README debian/compat debian/rules debian/control
	@echo Format: https://www.debian.org/doc/packaging-manuals/copyright-format/1.0/ > $@
	@echo Upstream-Name: $(EXECUTABLE_NAME) >> $@
	@echo "Upstream-Contact: $(AUTHOR) <$(MAIL)>" >> $@
	@echo Source: $(SOURCE) >> $@
	@echo License: $(LICENSE) >> $@
	@echo >> $@
	sed s/@mail@/$(MAIL)/g copyright >> $@

$(DEBIANPKG): debian/compat debian/control debian/rules debian/changelog debian/README
	#fakeroot debian/rules clean
	#fakeroot debian/rules build
	fakeroot debian/rules binary
	mv ../$@ $@
	@echo Package done!
	@echo You can install it as root with:
	@echo dpkg -i $@

debian_clean:
	rm -rf debian
	rm -f $(DEBIANPKG)

arch_pkg: $(ARCHPKG)

$(ARCHPKG): PKGBUILD $(EXECUTABLE_NAME).install
	sed -i "s|_name=.*|_name=$(EXECUTABLE_NAME)|" PKGBUILD
	sed -i "s|pkgver=.*|pkgver=$(VERSION)|" PKGBUILD
	makepkg -d
	@echo Package done!
	@echo You can install it as root with:
	@echo pacman -U $@

arch_clean:
	rm -rf pkg
	rm -f $(ARCHPKG)

.PHONY: clean arch_pkg arch_clean debian_pkg debian_clean man install arch_install uninstall
