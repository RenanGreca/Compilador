
// Testar se funciona corretamente o empilhamento de parâmetros
// passados por valor ou por referência.


%{
#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "compilador.h"
#include "tabelaSimbolos.h"
#include "pilha.h"

int num_vars, *temp_num, deslocamento;
// Instancia TABELA DE SIMBOLOS
ApontadorSimbolo tabelaSimbolo = NULL;
// Instancia PILHA
PilhaT pilha_rot, pilha_tipos, pilha_amem_dmem, pilha_simbs;

/* Empilha numero de vars locais para posterior DMEM */
#define empilhaAMEM(n_vars) temp_num = malloc (sizeof (int)); *temp_num = n_vars; empilha(&pilha_amem_dmem, temp_num);
#define geraCodigoDMEM() \
	num_vars = *(int *)desempilha(&pilha_amem_dmem); \
		if (num_vars) {printf ("DMEM %d", num_vars);}

%}

%token PROGRAM ABRE_PARENTESES FECHA_PARENTESES 
%token VIRGULA PONTO_E_VIRGULA DOIS_PONTOS PONTO
%token T_BEGIN T_END VAR IDENT ATRIBUICAO NUMERO

%%

programa    :{ 
             	geraCodigo (NULL, "INPP");
		deslocamento = 0;
             }
             PROGRAM IDENT {
	     	Simbolo a;
	     	a.identificador = token;
		// Adiciona o nome do programa na tabela de simbolos
	     	tabelaSimbolo = insere(&a, tabelaSimbolo, OPT_Procedimento);
		/*printf("TABELA BEGIN\n");
		imprime(tabelaSimbolo);
		printf("TABELA END\n");*/ 
	     }
             ABRE_PARENTESES lista_idents FECHA_PARENTESES PONTO_E_VIRGULA bloco
	     PONTO {
		geraCodigo (NULL, "PARA");
             }
;

bloco       : 
              parte_declara_vars
              {
		empilhaAMEM(deslocamento);
              }

              comando_composto 
              ;




parte_declara_vars:  var 
;


var         : { } VAR declara_vars
            |
;

declara_vars: declara_vars declara_var 
            | declara_var 
;

declara_var : { } 
              lista_id_var DOIS_PONTOS 
              tipo 
              { /* AMEM */
              }
              PONTO_E_VIRGULA
;

tipo        : IDENT
;

lista_id_var: lista_id_var VIRGULA IDENT 
              { /* insere última vars na tabela de símbolos */ }
            | IDENT { /* insere vars na tabela de símbolos */}
;

lista_idents: lista_idents VIRGULA IDENT  
            | IDENT
;

comando_composto: T_BEGIN comandos_ T_END
;

comandos_ : comandos
	  |
; 

comandos : comandos PONTO_E_VIRGULA comando
	 | comando
;

comando : NUMERO DOIS_PONTOS
	| comando_composto
	| IDENT ATRIBUICAO NUMERO {}
;

%%

main (int argc, char** argv) {
   FILE* fp;
   extern FILE* yyin;

   if (argc<2 || argc>2) {
         printf("usage compilador <arq>a %d\n", argc);
         return(-1);
      }

   fp=fopen (argv[1], "r");
   if (fp == NULL) {
      printf("usage compilador <arq>b\n");
      return(-1);
   }


/* -------------------------------------------------------------------
 *  Inicia a Tabela de Símbolos
 * ------------------------------------------------------------------- */

   yyin=fp;
   yyparse();

   return 0;
}

