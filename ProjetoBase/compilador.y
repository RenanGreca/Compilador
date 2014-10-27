
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

#define _DEBUG 1

int num_vars, *temp_num, deslocamento = 0, nivel = 0, rotulo = 0, num_argumentos = 0;
int bufferVetorTipo[100], bufferVetorPassagem[100];
int paramtipo = PARAMTIPO_VALOR;
ApontadorSimbolo procedimentoBuffer;
Simbolo simboloBuffer;

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
%token PROCEDURE

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%%

programa:   {
                inicializaPilha(&pilha_tipos);
                geraCodigo (NULL, "INPP");
                deslocamento = 0;
                nivel = 0;
            }
            PROGRAM IDENT
            {
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
            ABRE_PARENTESES lista_idents FECHA_PARENTESES PONTO_E_VIRGULA 
            bloco PONTO
            {
                geraCodigo (NULL, "PARA");
                imprime(tabelaSimbolo);
            }
;

bloco:      parte_declara_vars 
            {
                // Empilha rótulo de entrada do procedimento
                int *i = malloc(sizeof(int));
                *i = rotulo;
                empilha(&pilha_rot, i);

                // Empilha número de vars do procedimento
                int *j = malloc(sizeof(int));
                *j = num_vars;
                empilha(&pilha_amem_dmem, j);

                char dsvs[10];
                imprimeRotulo(proxRotulo(), s_rotulo);
                sprintf(dsvs, "DSVS %s", s_rotulo);
                geraCodigo(NULL, dsvs);

                nivel++;
            }
            proc_list 
            {
                nivel--;
                int *i = desempilha(&pilha_rot);
                imprimeRotulo(*i, s_rotulo);
                geraCodigo(s_rotulo, "NADA");
            }
            comando_composto 
            {
                num_vars = *(int *)desempilha(&pilha_amem_dmem);    
                char dmem[10];
                sprintf(dmem, "DMEM %d", num_vars);
                geraCodigo(NULL, dmem);
            }
;

parte_declara_vars:
            var {
                num_vars = 0;
            }
;

var:        VAR declara_vars
          |
;

declara_vars:
            declara_vars declara_var 
          | declara_var 
;

declara_var:
            {
                num_vars=0;
            }
            lista_id_var DOIS_PONTOS tipo 
            {
                /* AMEM */
                printf("..............................[Aloca memoria] %d variaveis\n", num_vars);
                char amem[10];
                sprintf(amem, "AMEM %d", num_vars);
                //printf("%s\n", amem);
                geraCodigo (NULL, amem);
            }
            PONTO_E_VIRGULA
;

tipo:       INTEGER
            {
                setaTipo(tabelaSimbolo, num_vars, VARTIPO_INT);
            }
          | CHAR
            {
                setaTipo(tabelaSimbolo, num_vars, VARTIPO_CHAR);
            }
          | STRING 
            {
                setaTipo(tabelaSimbolo, num_vars, VARTIPO_STRING);
            }
          | BOOLEAN
            {
                setaTipo(tabelaSimbolo, num_vars, VARTIPO_BOOLEAN);
            }
;

lista_id_var: 
            lista_id_var VIRGULA IDENT 
            {
                /* insere última vars na tabela de símbolos */
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

lista_idents:
            lista_idents VIRGULA IDENT  
          | IDENT
;

comando_composto:
            T_BEGIN comandos_ T_END 
;

comandos_ : comandos
          |
;

comandos :  comandos comando PONTO_E_VIRGULA
          | comando PONTO_E_VIRGULA 
;

comando :   NUMERO DOIS_PONTOS
          | comando_composto
          | proc_atribuicao
          | write
          | while
          | read
          | if
;

/* COMANDO: IF */

if:         if_simples
            ELSE 
            {
                char dsvs[10];
                imprimeRotulo(proxRotulo(), s_rotulo);
                sprintf(dsvs, "DSVS %s", s_rotulo);
                geraCodigo(NULL, dsvs);
                imprimeRotulo(rotulo-2, s_rotulo);
                geraCodigo(s_rotulo, "NADA");
            }
            comando
            {
                imprimeRotulo(rotulo-1, s_rotulo);
                geraCodigo(s_rotulo, "NADA");
            }
          | if_simples
            {
                imprimeRotulo(rotulo-1, s_rotulo);
                geraCodigo(s_rotulo, "NADA");
            }
;

if_simples: IF ABRE_PARENTESES boolexpr FECHA_PARENTESES
            {
                char dsvf[10];
                imprimeRotulo(proxRotulo(), s_rotulo);
                sprintf(dsvf, "DSVF %s", s_rotulo);
                geraCodigo(NULL, dsvf);
            }
            THEN comando
;

/* COMANDO: WHILE */

while:      {
                imprimeRotulo(proxRotulo(), s_rotulo);
                geraCodigo(s_rotulo, "NADA");
            }
            WHILE ABRE_PARENTESES boolexpr FECHA_PARENTESES
            {
                char dsvf[10];
                imprimeRotulo(proxRotulo(), s_rotulo);
                sprintf(dsvf, "DSVF %s", s_rotulo);
                geraCodigo(NULL, dsvf);
            }
            comando
            {
                char temp[10];
                imprimeRotulo(rotulo-1, temp);
                imprimeRotulo(rotulo-2, s_rotulo);
                char dsvs[10];
                sprintf(dsvs, "DSVS %s", s_rotulo); 
                geraCodigo(NULL, dsvs); // rotulo de volta ao loop
                geraCodigo(temp, "NADA"); // rotulo de saida do loop
            }
;

/* COMANDO: PROCEDURE */

ident_param: IDENT  {
        Simbolo a;
        a.identificador = malloc(sizeof(token));
        strcpy(a.identificador, token);
        a.nivel = nivel;
        a.passagem = paramtipo;
        //a->identificador = token;
        tabelaSimbolo = insere(a, tabelaSimbolo, OPT_ParametroFormal);
        //printf("Adicionando simbolo a tabela\n");
        //imprime(tabelaSimbolo);
        num_vars++;
        num_argumentos++; 
      }

;

lista_param_var_proc: VAR {
                            paramtipo = PARAMTIPO_REFER;
                        } lista_param_proc
                        | lista_param_proc
;

lista_param_proc: ident_param VIRGULA lista_param_proc
    | ident_param DOIS_PONTOS tipo_param_proc  {
                int i;
                for (i=1; i<=num_vars; i++) {
                     bufferVetorPassagem[num_argumentos-i] = paramtipo;
                }
                num_vars = 0;

              }
    | ident_param DOIS_PONTOS tipo_param_proc  {
                int i;
                for (i=1; i<=num_vars; i++) {
                     bufferVetorPassagem[num_argumentos-i] = paramtipo;
                }
                num_vars = 0;
                paramtipo = PARAMTIPO_VALOR;
              }
      PONTO_E_VIRGULA lista_param_var_proc
;

tipo_param_proc: INTEGER
            {
                setaTipo(tabelaSimbolo, num_vars, VARTIPO_INT);
                bufferVetorTipo[num_argumentos-1] = VARTIPO_INT;
            }
          | CHAR
            {
                setaTipo(tabelaSimbolo, num_vars, VARTIPO_CHAR);
                bufferVetorTipo[num_argumentos-1] = VARTIPO_CHAR;
            }
          | STRING 
            {
                setaTipo(tabelaSimbolo, num_vars, VARTIPO_STRING);
                bufferVetorTipo[num_argumentos-1] = VARTIPO_STRING;
            }
          | BOOLEAN
            {
                setaTipo(tabelaSimbolo, num_vars, VARTIPO_BOOLEAN);
                bufferVetorTipo[num_argumentos-1] = VARTIPO_BOOLEAN;
            }
;

proc_list:  proc_list proc
          | proc
          |
;

proc: proc_sem_arg { printf("..............................[Criando procedimento sem argumentos]\n"); }
  PONTO_E_VIRGULA
  bloco {
      char rtpr[10];
            sprintf(rtpr, "RTPR %d, %d", nivel, 0);
            geraCodigo(NULL, rtpr);
          }
  PONTO_E_VIRGULA
      | proc_sem_arg { printf("..............................[Criando procedimento com argumentos]\n"); }
  ABRE_PARENTESES {
    paramtipo = PARAMTIPO_VALOR;
  }
  lista_param_var_proc  {
            /* insere vars na tabela de símbolos */
            ApontadorSimbolo a = busca(simboloBuffer.identificador, tabelaSimbolo);
            alterarNumeroArgumentos(a, num_argumentos, bufferVetorTipo, bufferVetorPassagem);
            setaDeslocamento(tabelaSimbolo, num_argumentos, -4);
            int k;
            printf("Vetor tipo:");
            for(k=0;k<10;k++) {
                printf("%3d", bufferVetorTipo[k]);
            }
            printf("\n");
            printf("Vetor passagem:");
            for(k=0;k<10;k++) {
                printf("%3d", bufferVetorPassagem[k]);
            }
            printf("\n");
        }
  FECHA_PARENTESES
  PONTO_E_VIRGULA
  bloco {
    char rtpr[10];
    sprintf(rtpr, "RTPR %d, %d", nivel, 0);
    geraCodigo(NULL, rtpr);
  }
  PONTO_E_VIRGULA
;

proc_sem_arg:
            PROCEDURE IDENT
            {
                num_argumentos = 0;
                deslocamento = 0;

                Simbolo a;
                a.identificador = malloc(sizeof(token));
                strcpy(a.identificador, token);
                a.deslocamento = deslocamento;
                a.nivel = nivel;
    a.n_args = 0;

                char inpr[10];
                imprimeRotulo(proxRotulo(), s_rotulo);
                a.rotulo = malloc(sizeof(s_rotulo));
                strcpy(a.rotulo, s_rotulo);
                sprintf(inpr, "INPR %d", nivel);
                geraCodigo(s_rotulo, inpr);

    simboloBuffer = a;
    tabelaSimbolo = insere(a, tabelaSimbolo, OPT_Procedimento);
                //strcpy(a.rotulo, s_rotulo);
                //printf("Adicionando simbolo a tabela\n");
                //imprime(tabelaSimbolo);
                num_vars++;
            }
;

/* COMANDO: WRITE */

write:      WRITE
            {
                //printf("Imprimindo\n");
            }
            ABRE_PARENTESES lista_vals_write FECHA_PARENTESES
;

lista_vals_write:
            numero 
            {
                geraCodigo(NULL, "IMPR");
            } 
            VIRGULA lista_vals_write
          | ident
            {
                geraCodigo(NULL, "IMPR");
            } 
            VIRGULA lista_vals_write
          | numero
            {
                geraCodigo(NULL, "IMPR");
            }
          | ident 
            {
                geraCodigo(NULL, "IMPR");
            }
;

read:       READ ABRE_PARENTESES IDENT 
            {
                ApontadorSimbolo a = busca(token, tabelaSimbolo);
                if(a != NULL) {
                    char armz[10];
                    sprintf(armz, "ARMZ %d,%d", a->nivel, a->deslocamento);
                    geraCodigo(NULL, "LEIT");
                    geraCodigo(NULL, armz);
                } else {
                    sprintf(erro, "Variavel '%s' nao foi declarada!", token);
                    Erro(erro);
                    return 1;
                }
            }
            FECHA_PARENTESES
;

proc_atribuicao:
            IDENT
            {
                strcpy(temp, token);
            }
            proc_ou_atrib
;

proc_ou_atrib:  atribuicao
          | chama_proc
;

atribuicao: ATRIBUICAO expr
            {
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
                        return 1;
                    }
                    sprintf(armz, "ARMZ %d,%d", a->nivel, a->deslocamento);
                    geraCodigo(NULL, armz);
                } else {
                    sprintf(erro, "Variavel '%s' nao foi declarada!", temp);
                    Erro(erro);
                    return 1;
                }
            }
;

/* COMANDO: CHAMADA DE PROCEDIMENTO */

lista_vals_chama_proc:  numero { num_argumentos++; } VIRGULA lista_vals_chama_proc
    | ident_proc { num_argumentos++; } VIRGULA lista_vals_chama_proc
    | numero { num_argumentos++; }
    | ident_proc { num_argumentos++; }
    |
;

chama_proc:   chama_proc_sem_arg  {
            printf("..............................[Procedimento sem parametros]\n");
            if(procedimentoBuffer->n_args == 0){
              printf("..............................[Numero ccorreto de argumentos]\n");
              char cmpr[10];
              sprintf(cmpr, "CHPR %s, %d", procedimentoBuffer->rotulo, nivel);
              geraCodigo(NULL, cmpr);
            } else {
              printf("..............................[Numero IINcorreto de argumentos]\n");
            }
          }
  |   chama_proc_sem_arg  {
            printf("..............................[Procedimento com parametros]\n");
          }
     ABRE_PARENTESES
    lista_vals_chama_proc {
            if(_DEBUG){ printf("..............................[Numero de argumentos] %d\n", num_argumentos); }
            ApontadorSimbolo a = busca(simboloBuffer.identificador, tabelaSimbolo);
            if(a != NULL) {
              if(a->n_args == num_argumentos) {
                printf("..............................[Numero correto de argumentos]\n");
                char cmpr[10];
                sprintf(cmpr, "CHPR %s, %d", procedimentoBuffer->rotulo, nivel);
                geraCodigo(NULL, cmpr);
              } else {
                printf("..............................[Numero INcorreto de argumentos]\n");
              }
            } else {
                sprintf(erro, "Procedimento '%s' nao foi declarada!", token);
                Erro(erro);
                return 1;
            }
            num_argumentos = 0;
          }
    FECHA_PARENTESES
;

chama_proc_sem_arg: {
                num_argumentos = 0;
                printf("..............................[Procurando pelo procedimento] %s\n", temp);
                ApontadorSimbolo a = busca(temp, tabelaSimbolo);
                if(a != NULL) {
                    procedimentoBuffer = a;
                } else {
                    sprintf(erro, "Procedimento '%s' nao foi declarado!", temp);
                    Erro(erro);
                    return 1;
                }
            }
;

ident_proc      : IDENT
                {
                      ApontadorSimbolo a = busca(token, tabelaSimbolo);
                      if(a != NULL) {
                        // Empilha na pilha de tipos
                        if(_DEBUG){ printf("..............................[Empilhando] %s (tipo: %d)\n", a->identificador, a->tipo); }
                        int tipo_tmp = a->tipo;

                        // Busca funcao
                        ApontadorSimbolo b = busca(temp, tabelaSimbolo);
                        if(b->tiposParam[num_argumentos] != a->tipo) {
                            printf("O parametro %s nao e o tipo esperado.\n", token);
                            return 1;
                        }
                        printf("CHAMADA PROC - ARG: %s NUM_ARGUMENTOS : %d\n", a->identificador, num_argumentos);
                        if(a->categoria == OPT_variavelSimples) {
                            if(b->passagemParam[num_argumentos] == PARAMTIPO_VALOR) {
                                char crvl[10];
                                sprintf(crvl, "CRVL %d,%d", a->nivel, a->deslocamento);
                                geraCodigo(NULL, crvl);
                            } else if(b->passagemParam[num_argumentos] == PARAMTIPO_REFER) {
                                char crvl[10];
                                sprintf(crvl, "CREN %d,%d", a->nivel, a->deslocamento);
                                geraCodigo(NULL, crvl);
                            }
                        } else if(a->categoria == OPT_ParametroFormal) {
                            if(a->passagem == PARAMTIPO_VALOR) {
                                if(b->passagemParam[num_argumentos] == PARAMTIPO_VALOR) {
                                    char crvl[10];
                                    sprintf(crvl, "CRVL %d,%d", a->nivel, a->deslocamento);
                                    geraCodigo(NULL, crvl);
                                } else if(b->passagemParam[num_argumentos] == PARAMTIPO_REFER) {
                                    char crvl[10];
                                    sprintf(crvl, "CREN %d,%d", a->nivel, a->deslocamento);
                                    geraCodigo(NULL, crvl);
                                }
                            } else if(a->passagem == PARAMTIPO_REFER) {
                                if(b->passagemParam[num_argumentos] == PARAMTIPO_VALOR) {
                                    char crvl[10];
                                    sprintf(crvl, "CRVI %d,%d", a->nivel, a->deslocamento);
                                    geraCodigo(NULL, crvl);
                                } else if(b->passagemParam[num_argumentos] == PARAMTIPO_REFER) {
                                    char crvl[10];
                                    sprintf(crvl, "CRVL %d,%d", a->nivel, a->deslocamento);
                                    geraCodigo(NULL, crvl);
                                }

                            }
                        }
                        
                        
                      } else {
                        printf("Variavel %s nao declarada.\n", token);
                        return 1;
                      }
                }
;

boolexpr:   expr
          | expr IGUAL expr
            {
        if (verificaTipos("IGUAL")) {
                                  geraCodigo(NULL, "CMIG");
        } else {
          return 1;       
        }
                        } |
                expr DIFERENTE expr {
        if (verificaTipos("DIFERENTE")) {
                                  geraCodigo(NULL, "CMDG");
        } else {
          return 1;       
        }
                        } | 
                expr MENOR expr {
        if (verificaTipos("MENOR")) {
                                  geraCodigo(NULL, "CMME");
        } else {
          return 1;       
        }
                        } | 
                expr MAIOR expr {
        if (verificaTipos("MAIOR")) {
                                  geraCodigo(NULL, "CMMA");
        } else {
          return 1;       
        }
                        } | 
                expr MENOR_IGUAL expr {
        if (verificaTipos("MENOR_IGUAL")) {
                                  geraCodigo(NULL, "CMEG");
        } else {
          return 1;       
        }
                        } | 
                expr MAIOR_IGUAL expr {
        if (verificaTipos("MAIOR_IGUAL")) {
                                  geraCodigo(NULL, "CMAG");
        } else {
          return 1;       
        }
                        }
;

expr       :    expr MAIS termo 
                {
      if (verificaTipos("ADICAO")) {
                          geraCodigo(NULL, "SOMA");
      } else {
        return 1;       
      }
                } |
                expr MENOS termo
                {
      if (verificaTipos("SUBTRACAO")) {
                          geraCodigo(NULL, "SUBT");
      } else {
        return 1;       
      }

                }  | 
                expr OR termo
                {
      if (verificaTipos("OR")) {
                          geraCodigo(NULL, "DISJ");
      } else {
        return 1;       
      }
                } |
                termo
;

termo         : termo ASTERISCO val
                {
      if (verificaTipos("MULTIPLICACAO")) {
                          geraCodigo(NULL, "MULT");
      } else {
        return 1;       
      }
                }  | 
                termo DIV val 
                {
      if (verificaTipos("DIVISAO")) {
                          geraCodigo(NULL, "DIVI");
      } else {
        return 1;       
      }
                } | 
                termo AND val
                {
      if (verificaTipos("AND")) {
                          geraCodigo(NULL, "CONJ");
      } else {
        return 1;       
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
        printf("Variavel %s nao declarada.\n", token);
        return 1;
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
 *  Inicia a Tabela de Símbolos
 * ------------------------------------------------------------------- */

   yyin=fp;
   yyparse();

   return 0;
}

