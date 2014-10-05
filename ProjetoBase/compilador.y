
// Testar se funciona corretamente o empilhamento de par�metros
// passados por valor ou por refer�ncia.


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

#define _DEBUG 1

int num_vars, *temp_num, deslocamento = 0, nivel = 0, rotulo = 0;

char temp[100], temp_if[100], erro[100], s_rotulo[10];
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

int verificaTipos(char *op) {
	int *a, *b;
	if(_DEBUG){ printf("..............................[Desempilhando (expr: %s)]...", op); }
	a = desempilha(&pilha_tipos);
	if(_DEBUG){ printf("%d...", *a); }
	b = desempilha(&pilha_tipos);
	if(_DEBUG){ printf("%d...\n", *b); }	
	if(*a != *b){
		printf("%s com tipos diferentes!\n", op);
		return 0;
	}
	empilhaTipo(&pilha_tipos, *a);
	return 1;
}

%}

%token PROGRAM ABRE_PARENTESES FECHA_PARENTESES 
%token VIRGULA PONTO_E_VIRGULA DOIS_PONTOS PONTO
%token T_BEGIN T_END VAR IDENT ATRIBUICAO NUMERO
%token WRITE MAIS MENOS ASTERISCO DIV AND OR
%token WHILE READ IGUAL DIFERENTE MAIOR MENOR
%token MENOR_IGUAL MAIOR_IGUAL
%token INTEGER CHAR STRING BOOLEAN IF ELSE THEN

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%%

programa    :{ 
		inicializaPilha(&pilha_tipos);
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
                tabelaSimbolo = insere(a, tabelaSimbolo, OPT_ParametroFormal);
		setaTipo(tabelaSimbolo, 1, VARTIPO_STRING);
                num_vars = 0;
		// AMEM para o nome do programa
                geraCodigo (NULL, "AMEM 1");
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

tipo        : 	INTEGER {
			setaTipo(tabelaSimbolo, num_vars, VARTIPO_INT);
		} | 
		CHAR {
			setaTipo(tabelaSimbolo, num_vars, VARTIPO_CHAR);
		} | 
		STRING {
			setaTipo(tabelaSimbolo, num_vars, VARTIPO_STRING);
		} | 
		BOOLEAN {
			setaTipo(tabelaSimbolo, num_vars, VARTIPO_BOOLEAN);
		}
;

lista_id_var: lista_id_var VIRGULA IDENT 
                /* insere �ltima vars na tabela de s�mbolos */
              { 
                Simbolo a;
                a.identificador = malloc(sizeof(token));
                strcpy(a.identificador, token);
                a.deslocamento = deslocamento++;
                a.nivel = nivel;
                /* insere vars na tabela de s�mbolos */
                tabelaSimbolo = insere(a, tabelaSimbolo, OPT_variavelSimples);
                //printf("Adicionando simbolo a tabela\n");
                //imprime(tabelaSimbolo);
                num_vars++;
             }
            | IDENT /* insere vars na tabela de s�mbolos */
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

comandos : comandos comando PONTO_E_VIRGULA
         | comando PONTO_E_VIRGULA {printf("FINAL DE COMANDO!!\n");}
;

comando : NUMERO DOIS_PONTOS
        | comando_composto
        | atribuicao
        | write
        | while
        | read
	| if
;

/*if	: IF ABRE_PARENTESES
          boolexpr
          FECHA_PARENTESES {
                char dsvf[10];
                imprimeRotulo(proxRotulo(), s_rotulo);
                sprintf(dsvf, "DSVF %s", s_rotulo);
                geraCodigo(NULL, dsvf);
          } THEN
          comando_composto
	  {	char dsvs[10];
		imprimeRotulo(proxRotulo(), s_rotulo);
                sprintf(dsvs, "DSVS %s", s_rotulo);
                geraCodigo(NULL, dsvs);
		}
	  ELSE
	  {
		imprimeRotulo(prevRotulo(), temp_if);
		imprimeRotulo(prevRotulo(), s_rotulo);
                geraCodigo(s_rotulo, "NADA");
	  }
	  comando_composto
	  {
                geraCodigo(temp_if, "NADA");
	  } |
	IF ABRE_PARENTESES
          boolexpr
          FECHA_PARENTESES {
                char dsvf[10];
                imprimeRotulo(proxRotulo(), s_rotulo);
                sprintf(dsvf, "DSVF %s", s_rotulo);
                geraCodigo(NULL, dsvf);
          } THEN
          comando_composto
	  {	char dsvs[10];
		imprimeRotulo(proxRotulo(), s_rotulo);
                sprintf(dsvs, "DSVS %s", s_rotulo);
                geraCodigo(NULL, dsvs);
		}
;*/

if: if_simples{printf("IF_ELSE\n");} ELSE {
		char dsvs[10];
		imprimeRotulo(proxRotulo(), s_rotulo);
                sprintf(dsvs, "DSVS %s", s_rotulo);
                geraCodigo(NULL, dsvs);		
		
		prevRotulo();
		imprimeRotulo(prevRotulo(), s_rotulo);
                geraCodigo(s_rotulo, "NADA");
	} comando {
		proxRotulo();
		imprimeRotulo(proxRotulo(), s_rotulo);
                geraCodigo(s_rotulo, "NADA");
	}
  | if_simples{
		printf("IF_SIMPLES\n");
		imprimeRotulo(prevRotulo(), s_rotulo);
                geraCodigo(s_rotulo, "NADA");
	}
  
;

if_simples: IF ABRE_PARENTESES boolexpr FECHA_PARENTESES {
		char dsvf[10];
                imprimeRotulo(proxRotulo(), s_rotulo);
                sprintf(dsvf, "DSVF %s", s_rotulo);
                geraCodigo(NULL, dsvf);
	  }
	  THEN
          comando
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
                        geraCodigo(NULL, "IMPR");
                } VIRGULA lista_vals |
                ident {
                        geraCodigo(NULL, "IMPR");
                } VIRGULA lista_vals |
                numero {
                        geraCodigo(NULL, "IMPR");
                } |
                ident {
                        geraCodigo(NULL, "IMPR");
                }

read   : READ ABRE_PARENTESES IDENT {
                ApontadorSimbolo a = busca(token, tabelaSimbolo);
		if(a != NULL) {
		        char armz[10];
		        sprintf(armz, "ARMZ %d,%d", a->nivel, a->deslocamento);
		        geraCodigo(NULL, "LEIT");
		        geraCodigo(NULL, armz);
		} else {
			sprintf(erro, "Variavel '%s' nao foi declarada!", temp);
			Erro(erro);
			return;
		}
          } FECHA_PARENTESES
;

atribuicao: IDENT 
                {
                        strcpy(temp, token);
                } ATRIBUICAO expr {
                        //ARMZ
                        char armz[10];
                        ApontadorSimbolo a = busca(temp, tabelaSimbolo);
			if(a != NULL) {
				int *valor_pilha;
				if(_DEBUG){
					printf("..............................[TESTE FINAL EXPR] VARIAVEL %s (tipo: %d) recebe valor de expressao.\n", a->identificador, a->tipo);
					printf("..............................Desempilhando tipo da expressao...");
				}
				valor_pilha = desempilha(&pilha_tipos);
				if(_DEBUG){ printf("%d...\n", *valor_pilha); }
				// Checa valor da pilha de valores
				if(*valor_pilha != a->tipo){
					printf("Tipo errado!\n");
					return;
				}
                        	sprintf(armz, "ARMZ %d,%d", a->nivel, a->deslocamento);
                        	geraCodigo(NULL, armz);
			} else {
				sprintf(erro, "Variavel '%s' nao foi declarada!", temp);
				Erro(erro);
				return;
			}
                }
;

/*expr       :    ABRE_PARENTESES expr FECHA_PARENTESES |
                sum //|
             //or
;*/

boolexpr   :    expr | 
                expr IGUAL expr {
				if (verificaTipos("IGUAL")) {
                                	geraCodigo(NULL, "CMIG");
				} else {
					return;				
				}
                        } |
                expr DIFERENTE expr {
				if (verificaTipos("DIFERENTE")) {
                                	geraCodigo(NULL, "CMDG");
				} else {
					return;				
				}
                        } | 
                expr MENOR expr {
				if (verificaTipos("MENOR")) {
                                	geraCodigo(NULL, "CMME");
				} else {
					return;				
				}
                        } | 
                expr MAIOR expr {
				if (verificaTipos("MAIOR")) {
                                	geraCodigo(NULL, "CMMA");
				} else {
					return;				
				}
                        } | 
                expr MENOR_IGUAL expr {
				if (verificaTipos("MENOR_IGUAL")) {
                                	geraCodigo(NULL, "CMEG");
				} else {
					return;				
				}
                        } | 
                expr MAIOR_IGUAL expr {
				if (verificaTipos("MAIOR_IGUAL")) {
                                	geraCodigo(NULL, "CMAG");
				} else {
					return;				
				}
                        }
;

expr       :    expr MAIS termo 
                {
			if (verificaTipos("ADICAO")) {
                        	geraCodigo(NULL, "SOMA");
			} else {
				return;				
			}
                } |
                expr MENOS termo
                {
			if (verificaTipos("SUBTRACAO")) {
                        	geraCodigo(NULL, "SUBT");
			} else {
				return;				
			}

                }  | 
                expr OR termo
                {
			if (verificaTipos("OR")) {
                        	geraCodigo(NULL, "DISJ");
			} else {
				return;				
			}
                } |
                termo
;

termo         : termo ASTERISCO val
                {
			if (verificaTipos("MULTIPLICACAO")) {
                        	geraCodigo(NULL, "MULT");
			} else {
				return;				
			}
                }  | 
                termo DIV val 
                {
			if (verificaTipos("DIVISAO")) {
                        	geraCodigo(NULL, "DIVI");
			} else {
				return;				
			}
                } | 
                termo AND val
                {
			if (verificaTipos("AND")) {
                        	geraCodigo(NULL, "CONJ");
			} else {
				return;				
			}
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
			if(a != NULL) {
				// Empilha na pilha de tipos
				if(_DEBUG){ printf("..............................[Empilhando] %s (tipo: %d)\n", a->identificador, a->tipo); }
				int tipo_tmp = a->tipo;
				empilhaTipo(&pilha_tipos, tipo_tmp);

				char crvl[10];
				sprintf(crvl, "CRVL %d,%d", a->nivel, a->deslocamento);
				geraCodigo(NULL, crvl);
			} else {
				printf("Variavel %s nao declarada.\n", a->identificador);
				return;
			}
                }
;
numero     : NUMERO {
			// Empilha na pilha de tipos
			if(_DEBUG){ printf("..............................[Empilhando] CONSTANTE (tipo: 0)\n"); }
			int i;
			i = VARTIPO_INT;	
			empilhaTipo(&pilha_tipos, i);
                        
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
 *  Inicia a Tabela de S�mbolos
 * ------------------------------------------------------------------- */

   yyin=fp;
   yyparse();

   return 0;
}

