%{
#include <stdio.h>
#include <stdarg.h>
#include <string.h>
#include <stdlib.h>

char *concat(int count, ...);

%}
 
%union{
	char *str;
	int  *intval;
}

%token <str> T_STRING
%token T_BEGIN
%token T_END
%token T_NEWLINE
%token T_DOCUMENTCLASS
%token T_USEPACKAGE
%token T_TITLE
%token T_AUTHOR
%token T_MAKETITLE
%token T_TEXTBF
%token T_TEXTIT
%token T_INCLUDEGRAPHICS
%token T_CITE
%token T_BIBITEM
%token T_ITEM
%token T_ESCAPEDOLAR
%token T_ITEMIZE
%token T_THEBIBLIOGRAPHY
%token T_DOCUMENT

%type <str> begin_document_stmt end_document_stmt math_stmt col_list  values_list 

%start stmt_list

%error-verbose
 
%%

stmt_list: 	stmt_list stmt 
	 |	stmt 
;

stmt:
		create_stmt ';'	{printf("%s",$1);}
	|	insert_stmt ';'	{printf("%s",$1);}

;

begin_document_stmt:
	T_BEGIN T_DOCUMENT 	{
					FILE *F = fopen("saida.html", "w"); 
					fprintf(F, "<html><head></head><body>teste");
					fclose(F);
				}
;

begin_document_stmt:
	T_END T_DOCUMENT 	{
					FILE *F = fopen("saida.html", "a"); 
					fprintf(F, "fim</body></html>");
					fclose(F);
				}
;

math_stmt:
	'$' T_STRING '$'	{
					FILE *F = fopen("saida.html", "a"); 
					fprintf(F, "<html><head></head><body>teste</body></html>");
					fclose(F);
				}
;

col_list:
		T_STRING 		{ $$ = $1; }
	| 	col_list ',' T_STRING 	{ $$ = concat(3, $1, ";", $3); }
;

values_list:
		T_STRING 		{ $$ = $1; }
	| 	col_list ',' T_STRING 	{ $$ = concat(3, $1, ";", $3); }
;


 
%%
 
char* concat(int count, ...)
{
    va_list ap;
    int len = 1, i;

    va_start(ap, count);
    for(i=0 ; i<count ; i++)
        len += strlen(va_arg(ap, char*));
    va_end(ap);

    char *result = (char*) calloc(sizeof(char),len);
    int pos = 0;

    // Actually concatenate strings
    va_start(ap, count);
    for(i=0 ; i<count ; i++)
    {
        char *s = va_arg(ap, char*);
        strcpy(result+pos, s);
        pos += strlen(s);
    }
    va_end(ap);

    return result;
}


int yyerror(const char* errmsg)
{
	printf("\n*** Erro: %s\n", errmsg);
}
 
int yywrap(void) { return 1; }
 
int main(int argc, char** argv)
{
     yyparse();
     return 0;
}


