%{
/* jkl.lex
   Analizador l�xico del lenguaje JKL
   (c) JosuKa D�az Labrador 2006; see gpl.txt
*/

#include <string.h>
#include "jkl.tab.h"

extern void gcC( char * );
char *linea = NULL;

void yyerror( char const *msg )
{
	printf( "\nError en linea %d con '%s': %s", yylineno, yytext, msg );
}

%}

%option noyywrap
%option yylineno
%option never-interactive

/* Definiciones Regulares */

digito		[0-9]
constante	{digito}+
letra		[a-zA-Z]
id		{letra}({letra}|{digito})*
char		[^\"\t\n\r\f]
str		\"{char}*\"
sep		[ \t\n\r\f]

%%

^.*		{ free( linea );
		  linea = strdup( yytext );
		  gcC( linea );
		  yyless( 0 );
		}

";"		{ yylval.TCodigo = 0; return( P_COMA ); }

"."		{ yylval.TCodigo = 0; return( PUNTO ); }

"<"		{ yylval.TCodigo = 1; return( OP_REL ); }
"<="		{ yylval.TCodigo = 2; return( OP_REL ); }
">"		{ yylval.TCodigo = 3; return( OP_REL ); }
">="		{ yylval.TCodigo = 4; return( OP_REL ); }
"="		{ yylval.TCodigo = 5; return( OP_REL ); }
"<>"		{ yylval.TCodigo = 6; return( OP_REL ); }

"+"		{ yylval.TCodigo = 1; return( OP_ADIT ); }
"-"		{ yylval.TCodigo = 2; return( OP_ADIT ); }

"*"		{ yylval.TCodigo = 1; return( OP_MULT ); }
"/"		{ yylval.TCodigo = 2; return( OP_MULT ); }
"%"		{ yylval.TCodigo = 3; return( OP_MULT ); }

"("		{ yylval.TCodigo = 0; return( PAR_ABR ); }
")"		{ yylval.TCodigo = 0; return( PAR_CER ); }

":="		{ yylval.TCodigo = 0; return( ASIGN ); }
":"		{ yylval.TCodigo = 0; return( DOSPTOS ); }

"+:="		{ yylval.TCodigo = 0; return( OPASIGN ); }
"-:="		{ yylval.TCodigo = 1; return( OPASIGN ); }
"*:="		{ yylval.TCodigo = 2; return( OPASIGN ); }
"/:="		{ yylval.TCodigo = 3; return( OPASIGN ); }

{constante}	{ yylval.TCadena = strdup( yytext ); return( NUM ); }

{str}		{ yylval.TCadena = strdup( yytext ); return( CAD ); }

or		{ yylval.TCodigo = 0; return( OP_OR ); }
and		{ yylval.TCodigo = 0; return( OP_AND ); }
not		{ yylval.TCodigo = 0; return( OP_NOT ); }

begin		{ yylval.TCodigo = 0; return( PBEGIN ); }
end		{ yylval.TCodigo = 0; return( PEND ); }
program		{ yylval.TCodigo = 0; return( PPROG ); }
var		{ yylval.TCodigo = 0; return( PVAR ); }
read		{ yylval.TCodigo = 0; return( PREAD ); }
write		{ yylval.TCodigo = 0; return( PWRITE ); }
writec		{ yylval.TCodigo = 0; return( PWRITC ); }
writeln		{ yylval.TCodigo = 0; return( PWRITL ); }
if		{ yylval.TCodigo = 0; return( PIF ); }
then		{ yylval.TCodigo = 0; return( PTHEN ); }
else		{ yylval.TCodigo = 0; return( PELSE ); }
while		{ yylval.TCodigo = 0; return( PWHILE ); }
do		{ yylval.TCodigo = 0; return( PDO ); }
for		{ yylval.TCodigo = 0; return( PFOR ); }
to		{ yylval.TCodigo = 1; return( PTODO ); }
downto		{ yylval.TCodigo = 2; return( PTODO ); }
of		{ yylval.TCodigo = 0; return( POF ); }
case		{ yylval.TCodigo = 0; return( PCASE ); }
other		{ yylval.TCodigo = 0; return( POTHER ); }

{id}		{ yylval.TCadena = strdup( yytext ); return( ID ); }

{sep}		{ }

"//".*		{ }

.		{ yyerror( "lexical error: caracter desconocido" ); }

%%
