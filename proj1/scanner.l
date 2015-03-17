%{
#include "parser.h"
%}

STRING [a-zA-Z0-9\-:,.][a-zA-Z0-9_.*\-^+=!&(),:/]*
WHITESPACE [ \r\t]+
NEWLINE [\n]
ANY_CHAR .

%option case-insensitive

%%

{WHITESPACE} /* ignore */ ;
{NEWLINE}			{return T_NEWLINE;}
"\\documentclass" 		{return T_DOCUMENTCLASS;}
"\\usepackage" 			{return T_USEPACKAGE; }
"\\title"			{return T_TITLE;}
"\\author"			{return T_AUTHOR;}
"\\maketitle"			{return T_MAKETITLE;}
"\\textbf"			{return T_TEXTBF;}
"\\textit"			{return T_TEXTIT;}
"\\includegraphics"		{return T_INCLUDEGRAPHICS;}
"\\cite"			{return T_CITE;}
"\\bibitem"			{return T_BIBITEM;}
"\\begin{itemize}"		{return T_BEGIN_ITEMIZE;}
"\\end{itemize}"		{return T_END_ITEMIZE;}
"\\item"			{return T_ITEM;}
"\\begin{document}"		{return T_BEGIN_DOCUMENT;}
"\\end{document}"		{return T_END_DOCUMENT;}
"\\$"				{return T_ESCAPEDOLAR;}
"\\begin{thebibliography}"	{return T_BEGIN_THEBIBLIOGRAPHY;}
"\\end{thebibliography}"	{return T_END_THEBIBLIOGRAPHY;}
"{"				{return '{';}
"}"				{return '}';}
"["				{return '[';}
"]"				{return ']';} 
"("				{return '(';}
")"				{return ')';} 
"$"				{return '$';}
"\\"				{return '\\';}



{STRING} {	
	yylval.str = (char *) strdup(yytext);
	return T_STRING;
}

{ANY_CHAR} {
	printf ("Caracter %c (ASCII=%d) inesperado\n", yytext[0], yytext[0]);
}


