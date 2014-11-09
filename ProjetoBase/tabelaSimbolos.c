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
	tmp->rotulo = simbolo.rotulo;
	tmp->passagem = simbolo.passagem;
	tmp->n_args = simbolo.n_args;

	tmp->proximo = topo;
	topo = tmp;

	return topo;
}

void alterarNumeroArgumentos(ApontadorSimbolo procedure, int nArgumentos, int *vetorTipo, int *vetorPassagem) {
	printf("Entrou alterarNumeroArgumentos\n");
	procedure->n_args = nArgumentos;
	procedure->tiposParam = malloc(sizeof(int)*nArgumentos);
	procedure->passagemParam = malloc(sizeof(int)*nArgumentos);

	int i;
	for(i=0; i<nArgumentos; i++) {
		procedure->tiposParam[i] = vetorTipo[i];
		procedure->passagemParam[i] = vetorPassagem[i];
	}
}

// Retira simbolo da tabela
ApontadorSimbolo retira(ApontadorSimbolo topo, char* identificador) {
	return busca(identificador, topo);
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

void setaDeslocamento(ApontadorSimbolo topo, int n_posicoes, int deslocamento) {
	int i=0;

	while(i < n_posicoes){
		topo->deslocamento = deslocamento--;
		topo = topo->proximo;
		i++;
	}

	return;
}

void setaTipo(ApontadorSimbolo topo, int n_posicoes, int tipo) {
	int i=0;
	printf("...................n_posicoes: %d tipo: %d\n", n_posicoes, tipo);
	while(i < n_posicoes){
		topo->tipo = tipo;
		topo = topo->proximo;
		i++;
	}

	return;
}

// Imprime um simbolo
void imprimeSimbolo(ApontadorSimbolo a){
	/*if(a->categoria == OPT_Procedimento){
		int k;
		printf("Vetor passagem:");
		printf("%d", a->passagemParam[0]);
		printf("%d", a->passagemParam[1]);
	    printf("\n");
	}*/

	printf("....................|                    %14s | %14d | %14d |", a->identificador, a->nivel, a->deslocamento);
	// TIPO
	if(a->tipo == VARTIPO_INT){
		printf("%14s", "Int |");
	} else if(a->tipo == VARTIPO_CHAR){
		printf("%14s", "Char |");
	} else if(a->tipo == VARTIPO_STRING){
		printf("%14s", "String |");
	} else if(a->tipo == VARTIPO_BOOLEAN){
		printf("%14s", "Boolean |");
	}
	// CATEGORIA
	if(a->categoria == OPT_variavelSimples){
		printf("%18s", "VARIAVEL SIMPLES |");
	} else if(a->categoria == OPT_ParametroFormal){
		printf("%18s", "PARAMETRO FORMAL |");
	} else if(a->categoria == OPT_Procedimento){
		printf("%18s", "PROCEDIMENTO |");
	} else if(a->categoria == OPT_Rotulo){
		printf("%18s", "ROTULO |");
	}
	// ROTULO (APENAS PARA FUNCAO E PROCEDIMENTO)
	if(a->categoria == OPT_Procedimento){
		printf("%6s", a->rotulo);
	} else if(a->categoria == OPT_Rotulo){
		printf("%6s", a->rotulo);
	} else {
		printf("%6s", "");
	}
	printf("   |");
	// NUMERO DE VARIAVEIS
	if(a->categoria == OPT_Procedimento){
		printf("%6d", a->n_args);
	} else {
		printf("%6s", "");
	}
	printf("   |");
	// LISTA DE VARIAVEIS
	if(a->categoria == OPT_Procedimento){
		int i;
		for(i=0;i<a->n_args;i++){
			if(a->passagemParam[i] == PARAMTIPO_REFER){
				printf("%s", "(VAR)");
			} else {
				printf("%s", "(---)");
			}
			if(a->tiposParam[i] == VARTIPO_INT){
				printf("INT ");
			} else if(a->tiposParam[i] == VARTIPO_CHAR){
				printf("CHAR ");
			}
		}
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
	printf("....................|-------------- TABELA ----------------------------------------------------------------------------------------------------#\n");
	printf("....................|                           NOME    | NIVEL LEXICO   | DESLOCAMENTO   |      TIPO   |   CATEGORIA     | ROTULO  | N_ARGS  | ARG_LIST#\n");
	printf("....................|--------------------------------------------------------------------------------------------------------------------------#\n");
	imprimeTabela(topo);
	printf("....................|-------------- FINISH ----------------------------------------------------------------------------------------------------#\n");

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


