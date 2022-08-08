.PHONY: test-gauche test-kawa test-chibi test-chicken

test-gauche:
	gosh -I . srfi-234-test.scm

test-kawa:
	cp srfi-234-test.sld srfi-234-test.scm
	kawa srfi-234-test.scm
	rm srfi-234-test.scm

test-chibi:
	chibi-scheme srfi-234-test.scm

test-chicken:
	csc -R r7rs -X r7rs -sJ -o srfi-234-test.so srfi-234-test.scm
	csi -I . -R r7rs -s srfi-234-test.scm
	rm srfi-234-test.so
	rm srfi-234-test.import.scm
