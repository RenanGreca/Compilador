#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tabelaSimbolos.h"

// Insere atributo na tabela
ApontadorSimbolo insere(Simbolo simbolo, ApontadorSimbolo topo, int categoria) {
	ApontadorSimbolo tmp;

	tmp = malloc(sizeof(Simbolo));
	tmp->identificador = simbolo.identificador;
	tmp->nivel = simbolo.nivel;
	tmp->deslocamento = simbolo.deslocamento;
	tmp->categoria = categoria;

	tmp->proximo = topo;
	topo = tmp;

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

	return NULL;
}

void setaTipo(ApontadorSimbolo topo, int n_posicoes, int tipo) {
	int i=0;

	while(i < n_posicoes){
		topo->tipo = tipo;
		topo = topo->proximo;
		i++;
	}

	return;
}

// Imprime um simbolo
void imprimeSimbolo(ApontadorSimbolo a){
	printf("                    %14s | %14d | %14d |", a->identificador, a->nivel, a->deslocamento);
	if(a->tipo == VARTIPO_INT){
		printf("%14s", "Int |");
	} else if(a->tipo == VARTIPO_CHAR){
		printf("%14s", "Char |");
	} else if(a->tipo == VARTIPO_STRING){
		printf("%14s", "String |");
	}
	if(a->categoria == OPT_variavelSimples){
		printf("%18s", "VARIAVEL SIMPLES ");
	} else if(a->categoria == OPT_ParametroFormal){
		printf("%18s", "PARAMETRO FORMAL ");
	} else if(a->categoria == OPT_Procedimento){
		printf("%18s", "PROCEDIMENTO ");
	}	

	printf("   |\n");
}

// Imprime pilha
void imprimeTabela(ApontadorSimbolo topo) {
	if(topo == NULL){
		return;
	}
	imprimeSimbolo(topo);
	imprimeTabela(topo->proximo);
	
	return;
}

void imprime(ApontadorSimbolo topo){
	printf("-------------- TABELA -----------------------------------------------------------------------------------#\n");
	printf("                           NOME    | NIVEL LEXICO   | DESLOCAMENTO   |      TIPO   |   CATEGORIA         #\n");
	printf("---------------------------------------------------------------------------------------------------------#\n");
	imprimeTabela(topo);
	printf("-------------- FINISH -----------------------------------------------------------------------------------#\n");

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


