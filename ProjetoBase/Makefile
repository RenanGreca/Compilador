$DEPURA=1

compilador: lex.yy.c y.tab.c compilador.o compilador.h tabelaSimbolos.o tabelaSimbolos.h pilha.o pilha.h trataerro.o trataerro.h
	gcc lex.yy.c compilador.tab.c tabelaSimbolos.o pilha.o trataerro.o compilador.o -o compilador -ll -ly -lc

lex.yy.c: compilador.l compilador.h
	flex compilador.l

y.tab.c: compilador.y compilador.h
	bison compilador.y -d -v

compilador.o : compilador.h compiladorF.c
	gcc -c compiladorF.c -o compilador.o

tabelaSimbolos.o : tabelaSimbolos.h tabelaSimbolos.c
	gcc -c tabelaSimbolos.c -o tabelaSimbolos.o

pilha.o: pilha.h pilha.o
	gcc -c pilha.c -o pilha.o

trataerro.o: trataerro.h trataerro.o
	gcc -c trataerro.c -o trataerro.o

clean : 
	rm -f compilador.tab.* lex.yy.c 
