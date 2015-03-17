%{
#include <stdio.h>
#include <stdarg.h>
#include <string.h>
#include <stdlib.h>

char *concat(int count, ...);

char *title;

int bib_count=0;


%}
 
%union{
	char *str;
	int  *intval;
}

%token <str> T_STRING
%token T_BEGIN_DOCUMENT
%token T_END_DOCUMENT
%token T_BEGIN_ITEMIZE
%token T_END_ITEMIZE
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
%token T_BEGIN_THEBIBLIOGRAPHY
%token T_END_THEBIBLIOGRAPHY
%token T_NEWLINE

%type <str> begin_document_stmt end_document_stmt math_stmt textbf_stmt textit_stmt texto
	includegraphics_stmt maketitle_stmt itemize_stmt_begin itemize_stmt_end item values_list

%start stmt_list

%error-verbose
 
%%

stmt_list:
		cabecalho begin_document_stmt documento end_document_stmt
;

cabecalho:
		elem_cabecalho cabecalho
	|	elem_cabecalho
;

elem_cabecalho:
		document_class
	|	use_package
	|	title
	|	author
	|	T_NEWLINE
;

document_class:
		T_DOCUMENTCLASS '{' T_STRING '}' T_NEWLINE
	|	T_DOCUMENTCLASS '[' T_STRING ']' '{' T_STRING '}' T_NEWLINE
;

use_package:
		T_USEPACKAGE '{' T_STRING '}' T_NEWLINE	
	|	T_USEPACKAGE '[' T_STRING ']' '{' T_STRING '}' T_NEWLINE
;

title:
		T_TITLE	'{' values_list '}' T_NEWLINE	{ title = strdup($3);}
		
;

author:
		T_AUTHOR '{' values_list '}' T_NEWLINE
;

begin_document_stmt:
		T_BEGIN_DOCUMENT T_NEWLINE 	{
							FILE *F = fopen("saida.html", "w"); 
							fprintf(F, "<html>\n<head>\n\n\n<script type='text/x-mathjax-config'>  MathJax.Hub.Config({tex2jax: {inlineMath: [['$','$'], ['\\(','\\)']]}}); </script> <script type='text/javascript' src='https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML'> </script> </head>\n<body>\n");
							fclose(F);
						}
;

end_document_stmt:
		T_END_DOCUMENT T_NEWLINE 	{
							FILE *F = fopen("saida.html", "a"); 
							fprintf(F, "\n</body>\n</html>");
							fclose(F);
							return 0;
						}
;

documento:
		elem_documento documento
	|	elem_documento
;

elem_documento:
		math_stmt	
	|	textbf_stmt	
	|	textit_stmt
	|	includegraphics_stmt
	|	maketitle_stmt T_NEWLINE
	|	itemize_stmt_begin T_NEWLINE
	|	itemize_stmt_end T_NEWLINE
	|	item T_NEWLINE
	|	cite
	|	texto
	|	bib_begin T_NEWLINE
	|	bib_end T_NEWLINE
	|	bib_item
	|	T_NEWLINE	{
						FILE *F = fopen("saida.html", "a"); 
						fprintf(F, "<br/>");
						fclose(F);  
				}

;


math_stmt:
		'$' values_list '$'	{
						FILE *F = fopen("saida.html", "a"); 
						fprintf(F, "$%s$\n", $2);
						fclose(F);
					}
;

textbf_stmt:
		T_TEXTBF '{' values_list '}'	{
							FILE *F = fopen("saida.html", "a"); 
							fprintf(F, "<b>%s</b>\n", $3);
							fclose(F);
						}
;

textit_stmt:
		T_TEXTIT '{' values_list '}'	{
							FILE *F = fopen("saida.html", "a"); 
							fprintf(F, "<i>%s</i>\n", $3);
							fclose(F);
						}
;

includegraphics_stmt:
		T_INCLUDEGRAPHICS '{' T_STRING '}'	{
								FILE *F = fopen("saida.html", "a"); 
								fprintf(F, "<img src='%s'>\n", $3);
								fclose(F);
							}
;

cite:
		T_CITE '{' T_STRING '}'			{
								FILE *F = fopen("saida.html", "a"); 
								fprintf(F, "[%s]", $3);
								fclose(F);								
								
							}

;

bib_begin:
		T_BEGIN_THEBIBLIOGRAPHY 		{
								FILE *F = fopen("saida.html", "a"); 
								fprintf(F, "<ol start=0>\n");
								fclose(F);	
							}
;

bib_end:
		T_END_THEBIBLIOGRAPHY 			{
								FILE *F = fopen("saida.html", "a"); 
								fprintf(F, "</ol>\n");
								fclose(F);	
							}
;

bib_item:
		T_BIBITEM '{' T_STRING '}'		{
								FILE *F = fopen("saida.html", "a");
								char command[300];
								fprintf(F, "<a name='bib.%d'><li value=%d> ", bib_count, bib_count);
								fclose(F);
								sprintf(command, "sed -i 's/%s/<a href='#bib.%d'>%d<\\/a>/g' saida.html", $3, bib_count++, bib_count); 
								system(command);
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

itemize_stmt_begin:
		T_BEGIN_ITEMIZE 					{
										FILE *F = fopen("saida.html", "a"); 
										fprintf(F, "<ul>\n");;
										fclose(F);
									}
;

itemize_stmt_end:
		T_END_ITEMIZE						{
										FILE *F = fopen("saida.html", "a"); 
										fprintf(F, "</ul>\n");
										fclose(F);
									}
;



item:
		T_ITEM values_list		{ 
							FILE *F = fopen("saida.html", "a"); 							
							fprintf(F, "<li>%s</li>\n", $2); 
							fclose(F);
						}
;

texto:
	values_list 	{ 
				FILE *F = fopen("saida.html", "a"); 							
				fprintf(F, "%s\n", $1); 
				fclose(F);
			}
;

values_list:
		T_STRING 				{ $$ = $1; }
	| 	values_list T_STRING 			{ $$ = concat(3, $1, " ", $2); }
	| 	'[' values_list ']'		  	{ $$ = concat(3, "[", $2, "]"); }

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


