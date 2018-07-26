%{
#include "codigo.h"
#include "proyecto.tab.h"

int inicio_comentario = 0;
%}
/* Declaraciones */
D	    [0-9]
L	    [a-zA-Z]
panico	[^a-zA-Z_0-9()";,+\-_.*/ \n\t\r]

/* Condición de contexto exclusiva */

%x comentario
%x string
%%
 /* Reglas */

"programa"                              { return PROGRAMA; }
"var"                                   { return VAR; }
"comienzo"                              { return COMIENZO; }
"fin"                                   { return FIN; }
"si"                                    { return SI; }
"entonces"                              { return ENTONCES; }
"si-no"                                 { return SINO; }
"mientras"                              { return MIENTRAS; }
"hacer"                                 { return HACER; }
"imprimir"                              { return IMPRIMIR; }
"leer"                                  { return LEER; }
"entero"                                { return ENTERO; }
"repetir"								{ return REPETIR; }
"desde"									{ return DESDE; }
"hasta"									{ return HASTA; }
({L}|"_")({L}|{D}|"_")*	                {  if(yyleng > 16){
                                                printf("Tamaño de identificador excedido ");
                                                yytext[16] = '\0';
                                                printf("ID: %s\n",yytext);
                                                }
										   yylval.cadena=strdup(yytext);
                                           return ID; }

{D}+                                    {       long long n = atoll(yytext);unsigned int max = 1 << 31;
                                                if( yyleng > 10 || n > max){
                                                    printf("Tamaño de entero excedido ");
                                                    strcpy(yytext, "2147483648");
                                                    printf("NUM: %s\n", yytext);
                                                    }
										  yylval.cadena=strdup(yytext);
                                          return NUM; }

";"                                     { return PYC; }
":"                                     { return DP; }
"."                                     { return PUNTO; }
","                                     { return COMA ; }
"+"                                     { return MAS; }
"-"                                     { return MENOS; }
"*"                                     { return POR; }
"/"                                     { return DIV; }
":="                                    { return ASIG; }
"="										{ return IGUAL; }
"("                                     { return PARI; }
")"                                     { return PARD; }




\"([^"\n\\]|\\.)*\"						{ yylval.cadena = strdup(yytext) ; return STR; }
"//"(.*)[\n]                            { }
"(*"									{ BEGIN(comentario); inicio_comentario = yylineno; }
<comentario>"*)"					    { BEGIN(0); }
<comentario><<EOF>>						{ printf("Error: Comentario no acabado en linea %d\n",inicio_comentario);return 0; }
<comentario>(.|\n)						{ }

\"										{ BEGIN(string); yymore(); }
<string>\"								{ BEGIN(0); return STR; }
<string>.|\\\"							{ yymore(); }
<string>\n 								{ BEGIN(0); printf("Cadena no acabada en la linea %d \n",yylineno-1); }

[ \n\r\t]+								{ }
{panico}+								{ printf("Error léxico en linea: %s %d\n",yytext,yylineno); }


%%
