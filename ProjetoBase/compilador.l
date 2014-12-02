%{


#include<stdio.h>
#include<string.h>

#include "compilador.h"
#include "compilador.tab.h"

//#define IMPRIME(STR) {};
#define IMPRIME(STR) printf("%s    # %s \n", STR, token);

int nl = 1;  

%}

pulo_linha [\n]

descarte [\t ]+

ident [a-zA-Z][a-zA-Z1-9]*

numero [0-9]+

comentario "(*"(.|{pulo_linha})*"*)"

%%

{pulo_linha} {nl++;} 

{descarte}

{comentario}

program { simbolo  = simb_program;  
          strncpy (token, yytext, TAM_TOKEN);
          IMPRIME("program ");
          return PROGRAM;
 }

integer { simbolo = simb_integer;
	  strncpy (token, yytext, TAM_TOKEN);
	  IMPRIME("Integer");
	  return INTEGER;
	}

char { simbolo = simb_char;
	  strncpy (token, yytext, TAM_TOKEN);
	  IMPRIME("Char");
	  return CHAR;
	}

string { simbolo = simb_string;
	  strncpy (token, yytext, TAM_TOKEN);
	  IMPRIME("String");
	  return STRING;
	}

boolean { simbolo = simb_boolean;
	  strncpy (token, yytext, TAM_TOKEN);
	  IMPRIME("Boolean");
	  return BOOLEAN;
	}

var      { simbolo = simb_var;  
          strncpy (token, yytext, TAM_TOKEN);
          IMPRIME("var  ");
          return VAR;
 }
 
label   { simbolo = simb_label;
          strncpy (token, yytext, TAM_TOKEN);
          IMPRIME ("label  ");
          return LABEL;
        }

begin { simbolo = simb_begin;
          strncpy (token, yytext, TAM_TOKEN);
          IMPRIME("begin ");
          return T_BEGIN;
 }

end { simbolo = simb_end;
          strncpy (token, yytext, TAM_TOKEN);
          IMPRIME("end  ");
          return T_END;
 }

write {simbolo = simb_write;
          strncpy (token, yytext, TAM_TOKEN);
          IMPRIME("write ");
          return WRITE;}
read {simbolo = simb_write;
          strncpy (token, yytext, TAM_TOKEN);
          IMPRIME("read ");
          return READ;}

while {simbolo = simb_while;
          strncpy (token, yytext, TAM_TOKEN);
          IMPRIME("while ");
          return WHILE;}

do {simbolo = simb_do;
          strncpy (token, yytext, TAM_TOKEN);
          IMPRIME("do ");
          return DO;}

goto {simbolo = simb_goto;
          strncpy (token, yytext, TAM_TOKEN);
          IMPRIME("goto ");
          return GOTO;}

if	{simbolo = simb_if;
          strncpy (token, yytext, TAM_TOKEN);
          IMPRIME("if ");
          return IF;}

then	{simbolo = simb_then;
          strncpy (token, yytext, TAM_TOKEN);
          IMPRIME("then ");
          return THEN;}

else	{simbolo = simb_else;
          strncpy (token, yytext, TAM_TOKEN);
          IMPRIME("else ");
          return ELSE;}

procedure {simbolo = simb_proc;
	  strncpy (token, yytext, TAM_TOKEN);
          IMPRIME("procedure ");
          return PROCEDURE;}
          
function {simbolo = simb_func;
          strncpy (token, yytext, TAM_TOKEN);
          IMPRIME("procedure ");
          return FUNCTION;}

:= { simbolo = simb_atribuicao;  
          strncpy (token, yytext, TAM_TOKEN);
          IMPRIME(" atribuicao  ");
          return ATRIBUICAO;  
 }

\; { simbolo = simb_ponto_e_virgula;  
          strncpy (token, yytext, TAM_TOKEN);
          IMPRIME(" pt_virgula  ");
          return PONTO_E_VIRGULA;
 }

\: { simbolo = simb_dois_pontos;  
          strncpy (token, yytext, TAM_TOKEN);
          IMPRIME(" dois pontos ");
          return DOIS_PONTOS;
 }

\, { simbolo = simb_virgula;  
          strncpy (token, yytext, TAM_TOKEN);
          IMPRIME(" virgula  ");
          return VIRGULA;
 }


\. { simbolo = simb_ponto;  
          strncpy (token, yytext, TAM_TOKEN);
          IMPRIME(" ponto  ");
          return PONTO; 
    }

\(  { simbolo = simb_abre_parenteses;  
          strncpy (token, yytext, TAM_TOKEN);
          IMPRIME(" abre_parenteses  ");
          return ABRE_PARENTESES;
    }

\)  { simbolo = simb_fecha_parenteses;  
          strncpy (token, yytext, TAM_TOKEN);
          IMPRIME(" fecha_parenteses ");
          return FECHA_PARENTESES;
 }

\=  {
      simbolo = simb_igual;
      strncpy (token, yytext, TAM_TOKEN);
      IMPRIME(" igual ");
      return IGUAL;
     }

\<>  {
      simbolo = simb_diferente;
      strncpy (token, yytext, TAM_TOKEN);
      IMPRIME(" diferente ");
      return DIFERENTE;
     }

\>  {
      simbolo = simb_maior;
      strncpy (token, yytext, TAM_TOKEN);
      IMPRIME(" maior ");
      return MAIOR;
     }

\<  {
      simbolo = simb_menor;
      strncpy (token, yytext, TAM_TOKEN);
      IMPRIME(" menor ");
      return MENOR;
     }

\>=  {
      simbolo = simb_maior_igual;
      strncpy (token, yytext, TAM_TOKEN);
      IMPRIME(" maior ou igual ");
      return MAIOR_IGUAL;
     }

\<=  {
      simbolo = simb_menor_igual;
      strncpy (token, yytext, TAM_TOKEN);
      IMPRIME(" menor ou igual ");
      return MENOR_IGUAL;
     }

{numero} { simbolo = simb_numero;
		strncpy (token, yytext, TAM_TOKEN);
		IMPRIME(" numero");
		return NUMERO;
	}

\+    { IMPRIME(" mais  ");
          return MAIS; }
\-    { return MENOS; }
\*    { return ASTERISCO;  }
\/    { return DIV; }
div   { return DIV;  }
and   { return AND; }
or    { return OR; }

{ident} { simbolo = simb_identificador; 
          strncpy (token, yytext, TAM_TOKEN);
          IMPRIME(" ident  ");
          return IDENT;
        }

%%

