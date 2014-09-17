#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tabelaSimbolos.h"

// Insere atributo na tabela
ApontadorSimbolo insere(ApontadorSimbolo simbolo, ApontadorSimbolo topo, int categoria) {

	simbolo->categoria = categoria;

	simbolo->proximo = topo;
	topo = simbolo;

	return topo;
}

// Retira simbolo da tabela
void retira(ApontadorSimbolo* topo, int index) {
	int i=0;

	while(i<index) {
		*topo = ((ApontadorSimbolo) *topo)->proximo;
		i++;
	}
}

// Busca simbolo na tabela
ApontadorSimbolo busca(char* nome, ApontadorSimbolo topo) {

	while(topo) {
		if(!strcmp(topo->identificador, nome)){
			return topo;
		}
		topo = topo->proximo;

	}
}

// Imprime um simbolo
void imprimeSimbolo(ApontadorSimbolo a){
	printf("%p: %s -> %p\n", a, a->identificdador, a->proximo);
}

// Imprime pilha
void imprime(ApontadorSimbolo topo) {
	if(topo == NULL){
		return;
	}
	imprimeSimbolo(topo);
	imprime(topo->proximo);
	return;
}

/*
int main(int argc, char** argv) {
	ApontadorSimbolo topo = NULL;

	Simbolo a;
	a.identificador = "sdfsdf";
	a.nivel = 0;
	a.tipo = 0;
	a.deslocamento = 0;

	Simbolo b;
	b.identificador = "aaaa";
	b.nivel = 0;
	b.tipo = 0;
	b.deslocamento = 0;

	topo = insere(&a, topo, 0);
	topo = insere(&b, topo, 0);
	imprime(topo);
	retira(&topo, 1);
	imprime(topo);

	imprimeSimbolo(*busca("sdfsdf", topo));
}
*/


