
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

int num_vars, *temp_num, deslocamento, nivel;
char temp[10];
// Instancia TABELA DE SIMBOLOS
ApontadorSimbolo tabelaSimbolo = NULL;
// Instancia PILHA
PilhaT pilha_rot, pilha_tipos, pilha_amem_dmem, pilha_simbs;

/* Empilha numero de vars locais para posterior DMEM */
#define empilhaAMEM(n_vars) temp_num = malloc (sizeof (int)); *temp_num = n_vars; empilha(&pilha_amem_dmem, temp_num);
#define geraCodigoDMEM() \
        num_vars = *(int *)desempilha(&pilha_amem_dmem); \
                char buffer[50]; sprintf(buffer, "DMEM %d", num_vars); geraCodigo (NULL, buffer);

%}

%token PROGRAM ABRE_PARENTESES FECHA_PARENTESES 
%token VIRGULA PONTO_E_VIRGULA DOIS_PONTOS PONTO
%token T_BEGIN T_END VAR IDENT ATRIBUICAO NUMERO
%token WRITE MAIS MENOS ASTERISCO DIV AND OR
%token WHILE READ

%%

programa    :{ 
                geraCodigo (NULL, "INPP");
                deslocamento = 0;
                nivel = 0;
             }
             PROGRAM IDENT {
                Simbolo a;
                a.identificador = malloc(sizeof(token));
                strcpy(a.identificador, token);
                // Adiciona o nome do programa na tabela de simbolos
                tabelaSimbolo = insere(a, tabelaSimbolo, OPT_Procedimento);
                printf("TABELA BEGIN\n");
                //imprime(tabelaSimbolo);
                num_vars = 0;
             }
             ABRE_PARENTESES lista_idents FECHA_PARENTESES PONTO_E_VIRGULA bloco
             PONTO {
                geraCodigoDMEM();
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

declara_var : { num_vars=0;
              } 
              lista_id_var DOIS_PONTOS 
              tipo 
              { /* AMEM */
                printf("Aloca memoria %d\n", num_vars);
                char amem[10];
                sprintf(amem, "AMEM %d", num_vars);
                printf("%s\n", amem);
                geraCodigo (NULL, amem);
              }
              PONTO_E_VIRGULA
;

tipo        : IDENT
;

lista_id_var: lista_id_var VIRGULA IDENT 
                /* insere última vars na tabela de símbolos */
              { 
                Simbolo a;
                a.identificador = malloc(sizeof(token));
                strcpy(a.identificador, token);
                a.deslocamento = deslocamento++;
                a.nivel = nivel;
                /* insere vars na tabela de símbolos */
                tabelaSimbolo = insere(a, tabelaSimbolo, OPT_variavelSimples);
                //printf("Adicionando simbolo a tabela\n");
                //imprime(tabelaSimbolo);
                num_vars++;
             }
            | IDENT /* insere vars na tabela de símbolos */
             { 
                Simbolo a;
                a.identificador = malloc(sizeof(token));
                strcpy(a.identificador, token);
                a.deslocamento = deslocamento++;
                a.nivel = nivel;
                //a->identificador = token;
                tabelaSimbolo = insere(a, tabelaSimbolo, OPT_variavelSimples);
                //printf("Adicionando simbolo a tabela\n");
                //imprime(tabelaSimbolo);
                num_vars++;
             }
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
        | atribuicao
        | write
        | while
        | read
        |
;

while   : WHILE ABRE_PARENTESES
          expr
          FECHA_PARENTESES
          comando_composto
;

write   : WRITE ABRE_PARENTESES IDENT {
                ApontadorSimbolo a = busca(token, tabelaSimbolo);
                char crvl[10];
                sprintf(crvl, "CRVL %d,%d", a->nivel, a->deslocamento);
                geraCodigo(NULL, crvl);
                geraCodigo(NULL, "IMPR");
          } FECHA_PARENTESES
;

read   : READ ABRE_PARENTESES IDENT {
                ApontadorSimbolo a = busca(token, tabelaSimbolo);
                char armz[10];
                sprintf(armz, "ARMZ %d,%d", a->nivel, a->deslocamento);
                geraCodigo(NULL, "LEIT");
                geraCodigo(NULL, armz);
          } FECHA_PARENTESES
;

atribuicao: IDENT 
                {
                        strcpy(temp, token);
                } ATRIBUICAO expr {
                        //ARMZ
                        char armz[10];
			printf("tmp: %s\n", temp);
                        ApontadorSimbolo a = busca(temp, tabelaSimbolo);
                        sprintf(armz, "ARMZ %d,%d", a->nivel, a->deslocamento);
                        geraCodigo(NULL, armz);
                }
;

expr       : sum //|
             //or
;

sum        : sum MAIS mult 
                {
                        geraCodigo(NULL, "SOMA");
                } |
             sum MENOS mult
                {
                        geraCodigo(NULL, "SUBT");
                }  | 
             mult
;

mult       : mult ASTERISCO val
                {
                        geraCodigo(NULL, "MULT");
                }  | 
             mult DIV val 
                {
                        geraCodigo(NULL, "DIVI");
                } | 
             val
;
/*
or         : or OR and { printf ("or"); } | 
             and
;

and        : and AND bool { printf ("and"); } |
             bool
;*/

val        : ident | numero
;

ident      : IDENT
                {
                        printf("ATRIBUICAO: %s\n", token);
                        imprime(tabelaSimbolo);
                        ApontadorSimbolo a = busca(token, tabelaSimbolo);
                        char crvl[10];
                        sprintf(crvl, "CRVL %d,%d", a->nivel, a->deslocamento);
                        printf("%s\n", crvl);
                        geraCodigo(NULL, crvl);
                }
;
numero     : NUMERO {
                        char crct[10];
                        sprintf(crct, "CRCT %s", token);
                        printf("%s\n", crct);
                        geraCodigo(NULL, crct);
                }

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

