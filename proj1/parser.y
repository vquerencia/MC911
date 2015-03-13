%{
#include <stdio.h>
#include <stdarg.h>
#include <string.h>
#include <stdlib.h>

char *concat(int count, ...);

char *title;

%}
 
%union{
	char *str;
	int  *intval;
}

%token <str> T_STRING
%token T_BEGIN
%token T_END
%token T_DOCUMENT
%token T_TEXTBF
%token T_TEXTIT
%token T_DOCUMENTCLASS
%token T_USEPACKAGE
%token T_TITLE
%token T_AUTHOR
%token T_MAKETITLE
%token T_INCLUDEGRAPHICS
%token T_CITE
%token T_BIBITEM
%token T_ITEM
%token T_ESCAPEDOLAR
%token T_ITEMIZE
%token T_THEBIBLIOGRAPHY
%token T_NEWLINE

%type <str> begin_document_stmt end_document_stmt math_stmt textbf_stmt textit_stmt 
	includegraphics_stmt maketitle_stmt item_list itemize_stmt aux

%start stmt_list

%error-verbose
 
%%

stmt_list:
		cabecalho begin_document_stmt documento end_document_stmt

;

cabecalho:
		cabecalho elem_cabecalho
	|	elem_cabecalho
	|

;

elem_cabecalho:
		document_class
	|	use_package
	|	title
	|	author
;

document_class:
		T_DOCUMENTCLASS '{' T_STRING '}' T_NEWLINE
;

use_package:
		use_package T_USEPACKAGE T_NEWLINE
	|	T_USEPACKAGE '{' T_STRING '}' T_NEWLINE	
;

title:
		T_TITLE	'{' T_STRING '}' T_NEWLINE	{ title = strdup($3);}
		
;

author:
		T_AUTHOR '{' T_STRING '}' T_NEWLINE
;

documento:
		documento elem_documento
	|	elem_documento
;

elem_documento:
		math_stmt T_NEWLINE	
	|	textbf_stmt T_NEWLINE	
	|	textit_stmt T_NEWLINE	
	|	includegraphics_stmt T_NEWLINE
	|	maketitle_stmt T_NEWLINE
	|	itemize_stmt T_NEWLINE
	|

;

begin_document_stmt:
		T_BEGIN T_DOCUMENT T_NEWLINE 	{
							FILE *F = fopen("saida.html", "w"); 
							fprintf(F, "<html>\n<head>\n\n</head>\n<body>\n");
							fclose(F);
						}
;

end_document_stmt:
		T_END T_DOCUMENT T_NEWLINE 	{
							FILE *F = fopen("saida.html", "a"); 
							fprintf(F, "\n</body>\n</html>");
							fclose(F);
						}
;

math_stmt:
		'$' T_STRING '$'	{
						FILE *F = fopen("saida.html", "a"); 
						fprintf(F, "%s", $2);
						fclose(F);
					}
;

textbf_stmt:
		T_TEXTBF '{' T_STRING '}'	{
							FILE *F = fopen("saida.html", "a"); 
							fprintf(F, "<b>%s</b>", $3);
							fclose(F);
						}
;

textit_stmt:
		T_TEXTIT '{' T_STRING '}'	{
							FILE *F = fopen("saida.html", "a"); 
							fprintf(F, "<i>%s</i>", $3);
							fclose(F);
						}
;

includegraphics_stmt:
		T_INCLUDEGRAPHICS '{' T_STRING '}'	{
								FILE *F = fopen("saida.html", "a"); 
								fprintf(F, "<img src='%s'>", $3);
								fclose(F);
							}
;

maketitle_stmt:
		T_MAKETITLE 				{
								FILE *F = fopen("saida.html", "r");
								FILE *output = fopen("aux.html", "w");
								char * line = NULL;
								size_t len = 0;
								ssize_t read;
								int i;

								while ((read = getline(&line, &len, F)) != -1) 
								{
									if (i==2)
									{
										fprintf(output, "<title>%s</title>\n", title);
									}
									else
									{
										fprintf(output, "%s", line);
									}

									i+=1;
								}

								fclose(F);
								fclose(output);

								system("mv aux.html saida.html");

							}
;

itemize_stmt:
		T_BEGIN T_ITEMIZE T_NEWLINE item_list T_END T_ITEMIZE	{
										FILE *F = fopen("saida.html", "a"); 
										//fprintf(F, "<ul>%s</ul>", $4);
										printf("<ul>%s</ul>", $4);
										fclose(F);
									}
;


item_list:
		item_list aux		{ $$ = concat(2, $1, $2); }
	|	
		
	//	item_list itemize_stmt T_NEWLINE item_list { $$ = concat(3, $1, $2, $4); printf("A%s\n", $$);}
	//|	item_list T_ITEM T_STRING T_NEWLINE	{ $$ = concat(4, $1, "<li>", $3, "</li>\n"); printf("B%s\n", $$);}
	//|	T_ITEM T_STRING T_NEWLINE		{ $$ = concat(3, "<li>", $2, "</li>\n"); }
	//|
;

aux:
		T_ITEM T_STRING T_NEWLINE	{ $$ = concat(3, "<li>", $2, "</li>\n"); }
	|	T_BEGIN T_ITEMIZE T_NEWLINE item_list T_END T_ITEMIZE T_NEWLINE	{ $$ = concat(3, "<ul>", $4, "</ul>\n"); }

 
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


