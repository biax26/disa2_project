all: model
model: main.o source.o
	gcc -o model main.o source.o
main.o: main.c header.h
	gcc -c main.c
source.o: source.c header.h
	gcc -c source.c
clean:
	rm -f model main.o source.o
