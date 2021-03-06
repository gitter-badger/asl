include Makefile.def

CURRDIR=./
DATE=`date +"%d%m%Y"`

include makedefs.src

include objdefs.unix

include makedefs.files

ALLFLAGS = $(CFLAGS) -D$(CHARSET) -DSTDINCLUDES=\"$(INCDIR)\" -DLIBDIR=\"$(LIBDIR)\"

#---------------------------------------------------------------------------
# primary targets

binaries: $(ALLTARGETS)

all: binaries docs

docs: $(TEX2DOCTARGET) $(TEX2HTMLTARGET)
	cd doc_DE; $(MAKE) TEX2DOC=../$(TEX2DOCTARGET) TEX2HTML=../$(TEX2HTMLTARGET) RM="rm -f"
	cd doc_EN; $(MAKE) TEX2DOC=../$(TEX2DOCTARGET) TEX2HTML=../$(TEX2HTMLTARGET) RM="rm -f"

$(ASLTARGET): $(ASM_OBJECTS) $(AS_OBJECTS) $(ST_OBJECTS) $(CODE_OBJECTS) $(NLS_OBJECTS)
	$(LD) -o $(ASLTARGET) $(ASM_OBJECTS) $(AS_OBJECTS) $(ST_OBJECTS) $(CODE_OBJECTS) $(NLS_OBJECTS) -lm $(LDFLAGS)

$(DASLTARGET): $(DASM_OBJECTS) $(DAS_OBJECTS) $(ST_OBJECTS) $(DECODE_OBJECTS)  $(NLS_OBJECTS)
	$(LD) -o $(DASLTARGET) $(DASM_OBJECTS) $(DAS_OBJECTS) $(ST_OBJECTS)  $(DECODE_OBJECTS) $(NLS_OBJECTS)

$(PLISTTARGET): $(PLIST_OBJECTS) $(NLS_OBJECTS)
	$(LD) -o $(PLISTTARGET) $(PLIST_OBJECTS) $(NLS_OBJECTS) -lm $(LDFLAGS)

$(ALINKTARGET): $(ALINK_OBJECTS) $(NLS_OBJECTS)
	$(LD) -o $(ALINKTARGET) $(ALINK_OBJECTS) $(NLS_OBJECTS) -lm $(LDFLAGS)

$(PBINDTARGET): $(PBIND_OBJECTS) $(NLS_OBJECTS)
	$(LD) -o $(PBINDTARGET) $(PBIND_OBJECTS) $(NLS_OBJECTS) -lm $(LDFLAGS)

$(P2HEXTARGET): $(P2HEX_OBJECTS) $(NLS_OBJECTS)
	$(LD) -o $(P2HEXTARGET) $(P2HEX_OBJECTS) $(NLS_OBJECTS) -lm $(LDFLAGS)

$(P2BINTARGET): $(P2BIN_OBJECTS) $(NLS_OBJECTS)
	$(LD) -o $(P2BINTARGET) $(P2BIN_OBJECTS) $(NLS_OBJECTS) -lm $(LDFLAGS)

$(RESCOMPTARGET): $(RESCOMP_OBJECTS)
	$(LD) -o $(RESCOMPTARGET) $(RESCOMP_OBJECTS) $(LDFLAGS)

$(TEX2DOCTARGET): $(TEX2DOC_OBJECTS)
	$(LD) -o $(TEX2DOCTARGET) $(TEX2DOC_OBJECTS) $(LDFLAGS) -lm

$(TEX2HTMLTARGET): $(TEX2HTML_OBJECTS)
	$(LD) -o $(TEX2HTMLTARGET) $(TEX2HTML_OBJECTS) $(LDFLAGS) -lm

$(UNUMLAUTTARGET): $(UNUMLAUT_OBJECTS)
	$(LD) -o $(UNUMLAUTTARGET) $(UNUMLAUT_OBJECTS) $(LDFLAGS)

$(MKDEPENDTARGET): $(MKDEPEND_OBJECTS)
	$(LD) -o $(MKDEPENDTARGET) $(MKDEPEND_OBJECTS) $(LDFLAGS)

#---------------------------------------------------------------------------
# special rules for objects dependant on string resource files

include makedefs.str

include Makefile.dep

Makefile.dep depend: $(MKDEPENDTARGET)
	$(CURRDIR)$(MKDEPENDTARGET) -o Makefile.dep *.c

#---------------------------------------------------------------------------
# supplementary targets

test: $(ALLTARGETS)
	cd tests; ./testall "$(TESTDIRS)"

install: $(ALLTARGETS)
	PREFIX=$(PREFIX) ./install.sh $(BINDIR) $(INCDIR) $(MANDIR) $(LIBDIR) $(DOCDIR)

clean:
	rm -f $(ALLTARGETS) $(RESCOMPTARGET) $(TEX2DOCTARGET) $(TEX2HTMLTARGET) *$(HOST_OBJEXTENSION) *$(TARG_OBJEXTENSION) *.p *.rsc tests/testlog testlog
	cd doc_DE; $(MAKE) RM="rm -f" clean
	cd doc_EN; $(MAKE) RM="rm -f" clean

#---------------------------------------------------------------------------
# create distributions

distrib: unjunk Makefile.dep
	mkdir ../asl-$(VERSION)
	tar cf - $(DISTARCHFILES) Makefile.dep | (cd ../asl-$(VERSION); tar xvf -)
	cd ..; tar cvf asl-$(VERSION).tar asl-$(VERSION)
	mv ../asl-$(VERSION).tar ./
	rm -rf ../asl-$(VERSION)
	gzip -9 -f asl-$(VERSION).tar

bindist:
	mkdir asl-$(VERSION)
	chmod 755 asl-$(VERSION)
	./install.sh asl-$(VERSION)/bin asl-$(VERSION)/include asl-$(VERSION)/man asl-$(VERSION)/lib asl-$(VERSION)/doc
	tar cvf asl-$(VERSION)-bin.tar asl-$(VERSION)
	rm -rf asl-$(VERSION)
	gzip -9 -f asl-$(VERSION)-bin.tar 

win32-bindist: $(UNUMLAUTTARGET)
	rm -rf as
	mkdir as
	cmd /cinstw32.cmd as\\bin as\\include as\\man as\\lib as\\doc
	cd as; zip -9 -r ../as$(VERSION).zip *.*
	zip -9 -r as$(VERSION).zip bin/cyg*
	rm -rf as

#---------------------------------------------------------------------------
# the Debian package (only works under Debian Linux!!!)

debian: docs debversion
	echo "asl (`./debversion -v`) stable; urgency=low" >debian/changelog
	echo "" >>debian/changelog
	echo "  * no changelog here" >>debian/changelog
	echo "" >>debian/changelog
	echo " -- Alfred Arnold <alfred@ccac.rwth-aachen.de> " `822-date` >>debian/changelog
	echo "" >>debian/changelog
	echo `./debversion -v`; 
	dpkg-shlibdeps $(ASLTARGET) $(ALINKTARGET) $(PBINDTARGET) $(PLISTTARGET) $(P2HEXTARGET) $(P2BINTARGET)
	rm -rf bindebian
	mkdir -p bindebian/DEBIAN
	echo "Package: asl" >>bindebian/DEBIAN/control
	echo "Version:" `./debversion -v` >>bindebian/DEBIAN/control
	echo "Section: base" >>bindebian/DEBIAN/control
	echo "Priority: optional" >>bindebian/DEBIAN/control
	echo "Architecture:" `./debversion -a` >>bindebian/DEBIAN/control
	cat debian-files/control >>bindebian/DEBIAN/control
	cp debian-files/postinst debian-files/prerm bindebian/DEBIAN/
	mkdir -p bindebian/usr/lib/asl/
	cp *.msg bindebian/usr/lib/asl/
	mkdir bindebian/usr/lib/asl/include/
	cp include/*.inc bindebian/usr/lib/asl/include/
	mkdir -p bindebian/usr/share/doc/asl/
	cp debian-files/copyright bindebian/usr/share/doc/asl/
	cp changelog bindebian/usr/share/doc/asl/
	mkdir bindebian/usr/share/doc/asl/de/ bindebian/usr/share/doc/asl/en/
	cp doc_DE/as.doc doc_DE/as.html bindebian/usr/share/doc/asl/de/
	cp doc_EN/as.doc doc_EN/as.html bindebian/usr/share/doc/asl/en/
	cp debian-files/changelog.Debian bindebian/usr/share/doc/asl/
	gzip -9 bindebian/usr/share/doc/asl/changelog*
	mkdir -p bindebian/usr/bin
	cp $(ASLTARGET) bindebian/usr/bin
	cp $(ALINKTARGET) bindebian/usr/bin
	cp $(PBINDTARGET) bindebian/usr/bin
	cp $(PLISTTARGET) bindebian/usr/bin
	cp $(P2HEXTARGET) bindebian/usr/bin
	cp $(P2BINTARGET) bindebian/usr/bin
	strip bindebian/usr/bin/*
	strip -R .note -R .comment bindebian/usr/bin/*
	mkdir -p bindebian/usr/share/man/man1
	cp man/*.1 bindebian/usr/share/man/man1
	gzip -9 bindebian/usr/share/man/man1/*.1
	find bindebian -type f | xargs chmod 644
	chmod 755 bindebian/usr/bin/* bindebian/DEBIAN/postinst bindebian/DEBIAN/prerm
	find bindebian -type d | xargs chmod 755
	fakeroot dpkg-deb --build bindebian
	mv bindebian.deb asl_`./debversion -v`_`./debversion -a`.deb

#---------------------------------------------------------------------------
# for my own use only...

archive: unjunk asport.tar.gz
zarchive: unjunk asport.zip

asport.tar.gz: $(ARCHFILES)
	tar cvf asport.tar $(ARCHFILES)
	gzip -9 -f asport.tar

asport.zip: $(ARCHFILES)
	zip -9 -r asport $(ARCHFILES)

unjunk:
	rm -f `find . -name "testlog" -print` \
	   `find . -name "*~" -print` \
	   `find . -name "core" -print` \
	   `find . -name "*.core" -print` \
	   `find . -name "*.lst" -print` \
	   `find . -name "lst" -print` \
	   `find . -name "*.noi" -print`
	cd doc_DE; $(MAKE) clean RM="rm -f"
	cd doc_EN; $(MAKE) clean RM="rm -f"

#---------------------------------------------------------------------------

.SUFFIXES: .c .asm
.c$(TARG_OBJEXTENSION):
	$(CC) $(ALLFLAGS) -c $*.c
.asm.p:
	./asl -L -q $*.asm
