VERSION= 1.0
md2test: md2test.c
	gcc md2test.c -o md2test -lpq

is: is.c is.h mr.c isGlobals.c adsc.c imtype.c mar345.c
	gcc -Wall -o is is.c isGlobals.c mr.c adsc.c imtype.c mar345.c  -ltiff -ljpeg -lm


clean:
	rm -f md2test *.o *~

dist:
	ln -fs . pxMarServer-$(VERSION)
	tar czvf pxMarServer-$(VERSION).tar.gz pxMarServer-$(VERSION)/pxMarServer pxMarServer-$(VERSION)/marccd pxMarServer-$(VERSION)/Makefile pxMarServer-$(VERSION)/fixMarccdLog pxMarServer-$(VERSION)/sudoers pxMarServer-$(VERSION)/px.sql pxMarServer-$(VERSION)/testCcd.py pxMarServer-$(VERSION)/md2test.c
	cd pxMarServer-$(VERSION)
	rm -f pxMarServer-$(VERSION)

install: 
	install pxMarServer /usr/local/bin
	install marccd /usr/local/bin
	install fixMarccdLog

	grep -q pxMarServer /etc/sudoers || echo "Please append etcService to /etc/services"
	if [ -d /etc/xinetd.d ]; then cp carpsIS /etc/xinetd.d; echo "Please restart xinetd"; fi

