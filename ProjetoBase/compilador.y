
// Testar se funciona corretamente o empilhamento de parâmetros
// passados por valor ou por referência.


%{
#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "compilador.h"
#include "compiladorF.h"
#include "tabelaSimbolos.h"
#include "pilha.h"

int num_vars, *temp_num, deslocamento = 0, nivel = 0, rotulo = 0;

char temp[10], erro[100], s_rotulo[10];
// Instancia TABELA DE SIMBOLOS
ApontadorSimbolo tabelaSimbolo = NULL;
// Instancia PILHA
PilhaT pilha_rot, pilha_tipos, pilha_amem_dmem, pilha_simbs;

/* Empilha numero de vars locais para posterior DMEM */
#define empilhaAMEM(n_vars) temp_num = malloc (sizeof (int)); *temp_num = n_vars; empilha(&pilha_amem_dmem, temp_num);
#define geraCodigoDMEM() \
        num_vars = *(int *)desempilha(&pilha_amem_dmem); \
                char buffer[50]; sprintf(buffer, "DMEM %d", num_vars); geraCodigo (NULL, buffer);

int proxRotulo(){
	return rotulo++;
}

int prevRotulo(){
        return --rotulo;
}

void imprimeRotulo(int this_rotulo, char* s_rotulo){
	//char s_rotulo[10];
        if (this_rotulo < 10) {
                sprintf(s_rotulo, "R0%d", this_rotulo);
        } else {
                sprintf(s_rotulo, "R%d", this_rotulo);
        }
	//return s_rotulo;
        //geraCodigo (s_rotulo, "NADA");
}

void Erro(char* s) {
	printf("Erro de compilacao: %s\n", s);
}

%}

%token PROGRAM ABRE_PARENTESES FECHA_PARENTESES 
%token VIRGULA PONTO_E_VIRGULA DOIS_PONTOS PONTO
%token T_BEGIN T_END VAR IDENT ATRIBUICAO NUMERO
%token WRITE MAIS MENOS ASTERISCO DIV AND OR
%token WHILE READ IGUAL DIFERENTE MAIOR MENOR
%token MENOR_IGUAL MAIOR_IGUAL

%%

programa    :{ 
                geraCodigo (NULL, "INPP");
                deslocamento = 0;
                nivel = 0;
             }
             PROGRAM IDENT {
                Simbolo a;
                a.identificador = malloc(sizeof(token));
		a.nivel = nivel;
		a.deslocamento = deslocamento++;
                strcpy(a.identificador, token);
                // Adiciona o nome do programa na tabela de simbolos
                tabelaSimbolo = insere(a, tabelaSimbolo, OPT_Procedimento);
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
                //imprimeRotulo(proxRotulo());
                imprimeRotulo(proxRotulo(), s_rotulo);
                geraCodigo(s_rotulo, "NADA");
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
                //printf("%s\n", amem);
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

comando_composto: T_BEGIN comandos_ T_END { imprime(tabelaSimbolo); }
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

while   : {
                imprimeRotulo(proxRotulo(), s_rotulo);
                geraCodigo(s_rotulo, "NADA");
                //imprimeRotulo(proxRotulo());
          } WHILE ABRE_PARENTESES
          boolexpr
          FECHA_PARENTESES
          {
                char dsvf[10];
                imprimeRotulo(proxRotulo(), s_rotulo);
                sprintf(dsvf, "DSVF %s", s_rotulo);
                geraCodigo(NULL, dsvf);
          }
          comando_composto
          {
                char temp[10];
                imprimeRotulo(prevRotulo(), temp);
                imprimeRotulo(prevRotulo(), s_rotulo);
                char dsvs[10];
                sprintf(dsvs, "DSVS %s", s_rotulo); 
                geraCodigo(NULL, dsvs); // rotulo de volta ao loop
                geraCodigo(temp, "NADA"); // rotulo de saida do loop
          }
;

write   : WRITE {
                //printf("Imprimindo\n");
        } ABRE_PARENTESES lista_vals FECHA_PARENTESES
;

lista_vals:     numero {
                        geraCodigo(NULL, "IMPR")
                } VIRGULA lista_vals |
                ident {
                        geraCodigo(NULL, "IMPR")
                } VIRGULA lista_vals |
                numero {
                        geraCodigo(NULL, "IMPR")
                } |
                ident {
                        geraCodigo(NULL, "IMPR")
                }

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
                        printf("ATRIBUICAO: %s\n", token);
                        strcpy(temp, token);
                } ATRIBUICAO expr {
                        //ARMZ
                        char armz[10];
                        ApontadorSimbolo a = busca(temp, tabelaSimbolo);
			if(a != NULL) {
                        	sprintf(armz, "ARMZ %d,%d", a->nivel, a->deslocamento);
                        	geraCodigo(NULL, armz);
			} else {
				sprintf(erro, "Variavel '%s' nao foi declarada!", temp);
				Erro(erro);
			}
                }
;

/*expr       :    ABRE_PARENTESES expr FECHA_PARENTESES |
                sum //|
             //or
;*/

boolexpr   :    expr | 
                expr IGUAL expr {
                                geraCodigo(NULL, "CMIG");
                        } |
                expr DIFERENTE expr {
                                geraCodigo(NULL, "CMDG");
                        } | 
                expr MENOR expr {
                                geraCodigo(NULL, "CMME");
                        } | 
                expr MAIOR expr {
                                geraCodigo(NULL, "CMMA");
                        } | 
                expr MENOR_IGUAL expr {
                                geraCodigo(NULL, "CMEG");
                        } | 
                expr MAIOR_IGUAL expr {
                                geraCodigo(NULL, "CMAG");
                        }
;

expr       :    expr MAIS termo 
                {
                        geraCodigo(NULL, "SOMA");
                } |
                expr MENOS termo
                {
                        geraCodigo(NULL, "SUBT");
                }  | 
                expr OR termo
                {
                        geraCodigo(NULL, "DISJ")
                } |
                termo
;

termo         : termo ASTERISCO val
                {
                        geraCodigo(NULL, "MULT");
                }  | 
                termo DIV val 
                {
                        geraCodigo(NULL, "DIVI");
                } | 
                termo AND val
                {
                        geraCodigo(NULL, "CONJ")
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

val        :    ABRE_PARENTESES expr FECHA_PARENTESES |
                ident | numero
;

ident      : IDENT
                {
                        ApontadorSimbolo a = busca(token, tabelaSimbolo);
                        char crvl[10];
                        sprintf(crvl, "CRVL %d,%d", a->nivel, a->deslocamento);
                        geraCodigo(NULL, crvl);
                }
;
numero     : NUMERO {
                        char crct[10];
                        sprintf(crct, "CRCT %s", token);
                        geraCodigo(NULL, crct);
                }

%%

int main (int argc, char** argv) {
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

