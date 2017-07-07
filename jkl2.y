%{
/* jkl2.y
   Especificacion yacc (bison) para el lenguaje JKL2
   (c) JosuKa Diaz 2015
   Basada en
   Especificacion yacc (bison) para el lenguaje AJK V.1
   (c) Andoni Eguiluz, JosuKa Diaz, Jorge Garcia, Ana Cabana 1998-1999
   revisi�n 1.00  - 15/02/1998
   revisi�n 1.01  - 13/11/1998
   revisi�n 1.02A - 10/03/1999
*/

#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#pragma warn -pro

int yylex();
char* basename(char* arg);
char * nuevaEtiq()
{
	static int counter;
	char * str;
	str = (char *)malloc( 10 * sizeof( char ) );
	sprintf(str, "#ET%d", ++counter);
	return str;
}
/*
Este método lo uso para que el case funcione, pero no permite anidar cases dentro de cases, pero si tener varios en un solo programa
*/
char * etiquetaFinCase(int reiniciar)
{
	static int counter;
	char * str;
	str = (char *)malloc( 10 * sizeof( char ) );
	if(reiniciar==0)
		sprintf(str, "#ETFC%d", counter);
	else
		sprintf(str, "#ETFC%d", counter++);
	return str;
}

void liberaEtiq( char * str )
{
	free( str );
	return;
}

/* Los archivos: se inician en main */

extern FILE *yyin;        /* Entrada */
       FILE *fichCod;     /* salida de c�digo MPV */

/* Las rutinas de error (definidas en lex) */

extern void yyerror( char const * );

/* Genera c�digo para las instrucciones con solo operador */

void gc0( char *code )
{
	fprintf( fichCod, "%s\n", code );
}

/* Genera c�digo para las instrucciones operador y operando */

void gc1( char *code, char *arg )
{
	fprintf( fichCod, "%s\t%s\n", code, arg );
}

/* Genera c�digo comentario */

void gcC( char *coment )
{
	fprintf( fichCod, "; %s\n", coment );
}

/* Control de debug */

#define YYERROR_VERBOSE

int yydebug;

%}

/* Definicion de los tipos de la pila para los atributos */

%union {
	int  TCodigo;
	char *TCadena;
}

/* Definicion de tokens */

%token  PIF PTHEN

%nonassoc MENOS_QUE_ELSE
%nonassoc PELSE /* Solucion del conflicto del if-then-else ambiguo */

%token  PCASE POF POTHER PWHILE PDO PFOR
%token  <TCodigo> PTODO
%token  PBEGIN PEND PPROG PVAR
%token  PREAD PWRITE PWRITC PWRITL

%token  PAR_ABR PAR_CER P_COMA PUNTO DOSPTOS
%token  <TCodigo> ASIGN OPASIGN

%token  <TCadena> NUM
%token  <TCadena> CAD
%token  <TCadena> ID

/* Precedencia y asociatividad de los operadores */

%left   OP_OR
%left   OP_AND
%left   <TCodigo> OP_REL
%left   <TCodigo> OP_ADIT
%left   <TCodigo> OP_MULT
%left   OP_UNARIO OP_NOT

%%

/* Reglas */

prog	: PPROG  ID  P_COMA
		  {
			gcC( "comienzo del programa: declaraciones globales" );
		  }
		  decl
		  {
			gcC( "comienzo del programa: instrucciones" );
			gc0( "inicio" );
		  }
		  sentc  PUNTO
		  {
			gc0( "fin" );
			gcC( "fin del programa" );
		  }
		;

decl	: /* regla vacia */
		| decl  PVAR  ID  { gc1( "globali", $3 ); }  P_COMA
		;

sentc	: PBEGIN  lsent  PEND
		;

lsent	: /* regla vacia */
		| lsent  sent
		;

sent	: P_COMA
		| ID  ASIGN { gc1("valori", $1); } expr P_COMA { gc0("asignai"); }
		| ID  OPASIGN expr
		{
				gc1("valord", $1);
				if ( $2 == 0 ) gc0( "sumai" );
				else if ( $2 == 1 ) gc0( "restai" );
				else if ( $2 == 2 ) gc0( "multi" );
				else if ( $2 == 3 ) gc0( "divi" );
				else yyerror( "Error en OPASIGN" );

				gc1("valori", $1);
				gc0("cambiarii");
				gc0("asignai");
		}
		 P_COMA
		| sentc
		| PREAD  ID
		  {
			gc1( "valori", $2 );
			gc0( "leeri" );
			gc0( ":=" );
		  }
		  P_COMA
		| PWRITE  expr  { gc0( "escribiri" ); }  P_COMA
		| PWRITC  CAD  { gc1( "escribirs", $2 ); }  P_COMA
		| PWRITL  { gc0( "escribirln" ); }  P_COMA
		| PIF  expr PTHEN
			{
				$<TCadena>$ = nuevaEtiq();
				gc1("si-falso-ir-a", $<TCadena>$);
			}
			sent
			{
				gc1( "etiq", $<TCadena>4 );
				liberaEtiq( $<TCadena>4 );
			}
			%prec MENOS_QUE_ELSE
		| PIF  expr	PTHEN
			{
				$<TCadena>$ = nuevaEtiq();
				gc1("si-falso-ir-a", $<TCadena>$);
				$<TCadena>$ = nuevaEtiq();
				gc1( "ir-a", $<TCadena>$ );

			}
		 sent
			{
				gc1( "etiq", $<TCadena>4 );
				liberaEtiq( $<TCadena>4 );
			}
			PELSE	sent
			{
				gc1( "etiq", $<TCadena>6 );
				liberaEtiq( $<TCadena>6 );
			}
		| PCASE  expr  POF  lcasos  zcaso PEND
		| PWHILE
		  	{
				$<TCadena>$ = nuevaEtiq();
				gc1( "etiq", $<TCadena>$ );
			}
			expr PDO
			{
				$<TCadena>$ = nuevaEtiq();
				gc1( "si-falso-ir-a", $<TCadena>$ );
			}
			sent
			{
				gc1( "ir-a", $<TCadena>2 );
				gc1( "etiq", $<TCadena>5 );
				liberaEtiq( $<TCadena>2 );
				liberaEtiq( $<TCadena>5 );
			}

		| PDO
			{
				$<TCadena>$ = nuevaEtiq();
				gc1( "etiq", $<TCadena>$ );
			}
			sent  PWHILE  expr  P_COMA
			{
				gc1( "si-cierto-ir-a", $<TCadena>2 );
				liberaEtiq( $<TCadena>2 );
			}
		| PFOR ID
			{
				gc1("valori", $2);

			}
			ASIGN  expr  PTODO
			{
				gc0("asignai");
			}
			expr  PDO
			{
				$<TCadena>$ = nuevaEtiq();
				gc1( "etiq", $<TCadena>$ );
				gc0( "copiari" );
				gc1( "valord", $2 );
				if ( $6 == 1 ) gc0( "mayorigi" );
				else if ( $6 == 2 ) gc0( "menorigi" );
				else yyerror( "Error en PTODO!" );
			}
			{
				$<TCadena>$ = nuevaEtiq();
				gc1( "si-falso-ir-a", $<TCadena>$ );
			}
			sent
			{
				gc1( "valori", $2 );
				gc1( "valord", $2 );
				gc0( "insi 1" );
				if ( $6 == 1 ) gc0( "sumai" );
				else if ( $6 == 2 ) gc0( "restai" );
				else yyerror( "Error en PTODO!" );
				gc0("asignai");
				gc1( "ir-a", $<TCadena>10 );
				gc1( "etiq", $<TCadena>11 );
				gc0( "desapilari" );
			}
		;

lcasos	: lcasos
		{
			gc0("copiari");
		}
		NUM
		{
			gc1( "insi", $3 );
			$<TCadena>$ = nuevaEtiq();
			gc0( "iguali" );
			gc1("si-falso-ir-a", $<TCadena>$);
		}
		DOSPTOS  sent
		{
			gc1( "ir-a", etiquetaFinCase(0) );//APAÑO MUY MUY PRELIMINAL
			gc1( "etiq", $<TCadena>4 );
			liberaEtiq( $<TCadena>4 );
		}
		|
		;

zcaso	: POTHER  DOSPTOS 	sent
		{
			gc1( "etiq", etiquetaFinCase(1) );
		}
		|
		;

expr	: NUM { gc1( "insi", $1 ); }
		| ID  { gc1( "valord", $1 ); }
		| expr OP_OR expr { gc0( "or" ); }
		| expr OP_AND expr { gc0( "and" ); }
		| expr OP_REL expr
			{
				if ( $2 == 1 ) gc0( "menori" );
				else if ( $2 == 2 ) gc0( "menorigi" );
				else if ( $2 == 3 ) gc0( "mayori" );
				else if ( $2 == 4 ) gc0( "mayorigi" );
				else if ( $2 == 5 ) gc0( "iguali" );
				else if ( $2 == 6 ) gc0( "noiguali" );
				else yyerror( "OP_REL Mal" );
			}
		| expr OP_ADIT expr
		  {
			if( $2==1 ) gc0( "sumai" );
			else if( $2==2 ) gc0( "restai" );
			else yyerror( "OP_ADIT Mal" );
		  }
		| expr OP_MULT expr
			{
			if( $2 == 3)
			{//RARO NO SE COMO ARREGLAR ESTO NO SE ME OCURRE MANERA, EL MODULO SE QUEDA A POCO DE FUNCIONAR
				gc0("cambiarii");
				gc0("copiari");
			}
			}
			{
				if ( $2 == 1 ) gc0( "multi" );
				else if ( $2 == 2 ) gc0( "divi" );
				else if ( $2 == 3 )
				{
					gc0( "divi" );
					gc0( "multi" );
					gc0( "restai" );
				}
				else yyerror( "OP_MULT Mal" );
			}
		| OP_ADIT expr %prec OP_UNARIO
			{
				if ( $1 == 1 );
				else if ( $1 == 2 ) gc0( "negi" );
				else yyerror( "OP_ADIT Mal" );
			}
		| OP_NOT expr { gc0( "not" ); }
		| PAR_ABR expr PAR_CER
		;

%%

int main( int argc, char *argv[] )
{
	char fuente[256];
	char *pos;

	if( argc == 2 || argc == 3 )
	{
		if( argc == 2 )
			yydebug = 0;
		else
			yydebug = atoi( argv[2] );
		strcpy( fuente, argv[1] );
		if( ( yyin = fopen( fuente, "r" ) ) != NULL )
		{
			pos = strrchr( fuente, '.');
			if( ! strcmp( pos, ".jkl" ) ) *pos = '\0';
			strcat( fuente, ".mpv" );
			fichCod = fopen( fuente, "w" );

			/* empieza la compilaci�n */
			yyparse();
			/* ha terminado la compilaci�n */

			fclose( yyin );
			fclose( fichCod );
		}
		else printf( "No se encontro el fichero %s\n", fuente );
	}
	else
	{
		printf( "Usage: %s jkl-source-file [debug-mode]\n", basename( argv[0] ) );
		printf( "  debug-mode: 0 para no debug, 1 para debug\n");
	}
	return 0;
}
