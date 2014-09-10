
%{
#include <stdio.h>

%}

%token NUM BOOL MAIS MENOS OR AND ASTERISCO DIV ABRE_PARENTESES FECHA_PARENTESES

%%

expr       : sum |
             or
;

sum        : sum MAIS mult { printf ("+"); } |
             sum MENOS mult { printf ("-"); } | 
             mult
;

mult       : mult ASTERISCO num  { printf ("*"); } | 
             mult DIV num  { printf ("/"); } | 
             num
;

num        : NUM { printf ("A"); }
;

or         : or OR and { printf ("or"); } | 
             and
;

and        : and AND bool { printf ("and"); } |
             bool
;

bool       : BOOL {printf ("B"); }
;

%%

main (int argc, char** argv) {
   yyparse();
}

