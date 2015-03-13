

CFLAGS=-g
BISON=bison
FLEX=flex
 
parser: parser.o scanner.o
	$(CC) -o prj1 scanner.o parser.o
 
parser.c: parser.y
	$(BISON) -d parser.y  -o parser.c
 
scanner.c: scanner.l
	$(FLEX)  -o scanner.c scanner.l
 
clean:
	rm -f scanner.c scanner.o parser.c parser.o parser.h prj1

