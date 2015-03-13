%{
#include "parser.h"
%}

STRING [a-z][a-z0-9_.]*
WHITESPACE [ \r\t]+
ANY_CHAR .
NEWLINE [\n]+

%option case-insensitive

%%

{WHITESPACE} /* ignore */ ;
{NEWLINE}		{return T_NEWLINE;}
"\\documentclass" 	{return T_DOCUMENTCLASS;}
"\\usepackage" 		{return T_USEPACKAGE; }
"\\title"		{return T_TITLE;}
"\\author"		{return T_AUTHOR;}
"\\maketitle"		{return T_MAKETITLE;}
"\\textbf"		{return T_TEXTBF;}
"\\textit"		{return T_TEXTIT;}
"\\includegraphics"	{return T_INCLUDEGRAPHICS;}
"\\cite"		{return T_CITE;}
"\\bibitem"		{return T_BIBITEM;}
"\\begin"		{return T_BEGIN;}
"\\end"			{return T_END;}
"\\item"		{return T_ITEM;}
"\\$"			{return T_ESCAPEDOLAR;}
"{itemize}"		{return T_ITEMIZE;}
"{thebibliography}"	{return T_THEBIBLIOGRAPHY;}
"{document}"		{return T_DOCUMENT;}
"{"			{return '{';}
"}"			{return '}';}
"("			{return '(';}
")"			{return ')';} 
"," 			{return ',';}
";"			{return ';';}
"$"			{return '$';}



{STRING} {	
	yylval.str = (char *) strdup(yytext);
	return T_STRING;
}

{ANY_CHAR} {
	printf ("Caracter %c (ASCII=%d) inesperado\n", yytext[0], yytext[0]);
}


