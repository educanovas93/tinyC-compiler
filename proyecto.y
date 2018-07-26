%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "codigo.h"
#include "listaVar.h"
#include "proyecto.tab.h"
// macro para cambiar el color a rojo y resetearlo
#define RED    "\x1b[31m"
#define ROSA    "\x1b[35m"
#define GREEN    "\x1b[32m"
#define RESET   "\x1b[0m"


int contador;
int nErrores = 0;
int flag = 1;
void yyerror (char const *msg);

extern int yylineno;
extern int yydebug;
extern FILE *yyin;
extern int yylex();

%}




/* Definición de tipos de datos para símbolos de la gramática */

%union{
    char *cadena;
	cod c;
}


%token PROGRAMA VAR ENTERO COMIENZO FIN SI ENTONCES SINO MIENTRAS HACER IMPRIMIR LEER PYC DP PUNTO COMA MAS MENOS POR DIV ASIG PARI PARD IGUAL REPETIR DESDE HASTA
%token SCANEOF 0


%token <cadena> ID STR NUM

%type <c> expression print_item statement statement_list print_list read_list program compound_statement optional_statements;



/*tipo de datos de los no terminales */



/*Indicacion de precedencia y asociatividad*/

%left MAS MENOS
%left POR DIV
%left UMENOS


%%


program             : PROGRAMA ID PARI PARD PYC declarations compound_statement PUNTO {
																						$$ = inicializar_codigo();
																						concatenar_codigo($$,$7);
																						if (nErrores == 0){
																							imprimirTabla();
																							imprimirCodigo($$);
																							}else {
																								fprintf(stderr,"Numero de errores: %d\n",nErrores);
																							}
																						}

                    ;

declarations        : declarations VAR identifier_list DP type PYC {  }

                    | {;} //Lambda

                    ;

identifier_list     : ID {
							if(buscarVar($1) == 0){
								insertarVar($1,flag);
							}else{
								   fprintf(stderr,RED"Error"RESET" en la linea %d : Nombre de variable ya en uso '%s'\n",yylineno,$1);
								   nErrores++;
								 }

						 }

                    | identifier_list COMA ID {
												if(buscarVar($3) == 0){
													insertarVar($3,flag);
												}else{ fprintf(stderr,RED"Error"RESET" en la linea %d : Nombre de variable ya en uso '%s'\n",yylineno,$3);
													   nErrores++;
												 	 }
											   }

                    ;




type                : ENTERO { }


					//regla de produccion para capturar errores

					| ID {  	nErrores++;
								if(Levenshtein($1,"entero") <= 2){
									fprintf(stderr,RED"Error"RESET" en la línea %d : Palabra no reconocida '"ROSA"%s",yylineno,$1);
									fprintf(stderr,RESET"' ¿Querías decir '"GREEN"entero"RESET"'?\n");
								}else {fprintf(stderr,RED"Error"RESET" en la línea : %d\n",yylineno);}
						 }

                    ;

compound_statement  : COMIENZO optional_statements FIN { $$ = inicializar_codigo();
 														 concatenar_codigo($$,$2); }


					//regla de producción para capturar errores
					| ID optional_statements FIN { 	nErrores++;
													if(Levenshtein($1,"comienzo") <= 2){
														fprintf(stderr,RED"Error"RESET" en la línea %d : Palabra no reconocida '"ROSA"%s",yylineno,$1);
														fprintf(stderr,RESET"' ¿Querías decir '"GREEN"comienzo"RESET"'?\n");
													}else {fprintf(stderr,RED"Error"RESET" en la línea : %d\n",yylineno);}
												  }

                    ;

optional_statements : statement_list { $$ = inicializar_codigo();
									   concatenar_codigo($$,$1); }

                    | { $$ = inicializar_codigo(); }

                    ;

statement_list      : statement PYC { $$ = inicializar_codigo();
 									  concatenar_codigo($$,$1);
								  	}

                    | statement_list statement PYC {
													 $$ = inicializar_codigo();
													 concatenar_codigo($$,$1);
												 	 concatenar_codigo($$,$2);
												    }

					| error PYC { 	$$ = inicializar_codigo();
									fprintf(stderr,RED"Error"ROSA" 'durante el analisis de un statement'\n"RESET);
				 				   }

                    ;

statement           : ID ASIG expression { if(buscarVar($1) == 0){
										   		nErrores++;
												fprintf(stderr,RED"Error "RESET);
												fprintf(stderr,"en la línea %d : variable '"ROSA"%s"RESET"' no declarada\n",yylineno,$1);
											}
											else if(buscarVar($1) == 1){
												$$ = inicializar_codigo();
												concatenar_codigo($$,$3);
												cua c = crear_cuadrupla("sw",getRes($3),concatenarString("_",$1),NULL);
												liberar_reg(getRes($3));
												concatenar_cuadrupla($$,c);
												}
										  }

                    | compound_statement { $$ = inicializar_codigo();
					 					   concatenar_codigo($$,$1); }

                    | SI expression ENTONCES statement SINO statement { $$ = inicializar_codigo();
																		if(nErrores == 0){
																			concatenar_codigo($$,$2);
																			char *et = getEtiqueta();
																			cua c = crear_cuadrupla("beqz",getRes($2),et,NULL);
																			liberar_reg(getRes($2));
																			concatenar_cuadrupla($$,c);
																			concatenar_codigo($$,$4);
																			char *et1 = getEtiqueta();
																			cua c1 = crear_cuadrupla("b",et1,NULL,NULL);
																			concatenar_cuadrupla($$,c1);
																			cua c2 = crear_cuadrupla(et,NULL,NULL,NULL);
																			concatenar_cuadrupla($$,c2);
																			concatenar_codigo($$,$6);
																			cua c3 = crear_cuadrupla(et1,NULL,NULL,NULL);
																			concatenar_cuadrupla($$,c3);
																		}
																	  }

                    | SI expression ENTONCES statement { $$ = inicializar_codigo();
														 if(nErrores == 0){
															 concatenar_codigo($$,$2);
															 char *et = getEtiqueta();
															 cua c = crear_cuadrupla("beqz",getRes($2),et,NULL);
															 liberar_reg(getRes($2));
															 concatenar_cuadrupla($$,c);
															 concatenar_codigo($$,$4);
															 cua c1 = crear_cuadrupla(et,NULL,NULL,NULL);
															 concatenar_cuadrupla($$,c1);
													 	 }
													  	}

                    | MIENTRAS expression HACER statement { $$ = inicializar_codigo();
															if(nErrores == 0){
																char *et = getEtiqueta();
																cua c = crear_cuadrupla("b",et,NULL,NULL);
																cua c1 = crear_cuadrupla(et,NULL,NULL,NULL);
																concatenar_cuadrupla($$,c1);
																concatenar_codigo($$,$2);
																char *et1 = getEtiqueta();
																cua c2 = crear_cuadrupla("beqz",getRes($2),et1,NULL);
																liberar_reg(getRes($2));
																concatenar_cuadrupla($$,c2);
																concatenar_codigo($$,$4);
																concatenar_cuadrupla($$,c);
																cua c3 = crear_cuadrupla(et1,NULL,NULL,NULL);
																concatenar_cuadrupla($$,c3);
														    }
														 }

				    | REPETIR statement MIENTRAS expression { $$ = inicializar_codigo();
															  if(nErrores == 0){
																  char *et = getEtiqueta();
																  cua c = crear_cuadrupla("bnez",getRes($4),et,NULL);
																  liberar_reg(getRes($4));
																  cua c1 = crear_cuadrupla(et,NULL,NULL,NULL);
																  concatenar_cuadrupla($$,c1);
																  concatenar_codigo($$,$2);
																  concatenar_codigo($$,$4);
																  concatenar_cuadrupla($$,c);
														  	  }
														  	}

				    | DESDE expression HASTA expression statement {	   $$ = inicializar_codigo();
								 									   if (nErrores == 0){
																		   char *reg1 = obtener_reg();
																		   char *reg2 = obtener_reg();
																		   char *et = getEtiqueta();
																		   char *et1 = getEtiqueta();
																		   concatenar_codigo($$,$2);
																		   concatenar_codigo($$,$4);
																		   cua c = crear_cuadrupla("li",reg2,"1",NULL);
																		   cua c1 = crear_cuadrupla("sub",reg1,getRes($4),getRes($2));
																		   cua c2 = crear_cuadrupla(et,NULL,NULL,NULL);
																		   cua c3 = crear_cuadrupla("beqz",reg1,et1,NULL);
																		   liberar_reg(getRes($4));
																		   liberar_reg(getRes($2));
																		   concatenar_cuadrupla($$,c);
																		   concatenar_cuadrupla($$,c1);
																		   concatenar_cuadrupla($$,c2);
																		   concatenar_cuadrupla($$,c3);
																		   concatenar_codigo($$,$5);
																		   cua c4 = crear_cuadrupla("sub",reg1,reg1,reg2);
																		   cua c5 = crear_cuadrupla("b",et,NULL,NULL);
																		   cua c6 = crear_cuadrupla(et1,NULL,NULL,NULL);
																		   concatenar_cuadrupla($$,c4);
																		   concatenar_cuadrupla($$,c5);
																		   concatenar_cuadrupla($$,c6);
																		   liberar_reg(reg1);
																		   liberar_reg(reg2);
														   	   			}
															 }

                    | IMPRIMIR print_list { $$ = inicializar_codigo();
											concatenar_codigo($$,$2); }

                    | LEER read_list { $$ = inicializar_codigo();
									   concatenar_codigo($$,$2); }

					// A partir de aquí estas reglas de producción son para capturar errores
					// Son a la vez las que estan generando algunos conflictor desplaza reduce pero no influyen en el correcto desarrollo del compilador





					| ID print_list { 	$$ = inicializar_codigo();
						  				nErrores++;
										if(Levenshtein($1,"imprimir") <= 2){
											fprintf(stderr,RED"Error"RESET" en la línea %d : Palabra no reconocida '"ROSA"%s",yylineno,$1);
											fprintf(stderr,RESET"' ¿Querías decir '"GREEN"imprimir"RESET"'?\n");
										}else {fprintf(stderr,RED"Error"RESET" en la línea : %d\n",yylineno);}
									}


					| MIENTRAS expression ID statement {	$$ = inicializar_codigo();
															nErrores++;
															if(Levenshtein($3,"hacer") <= 2){
																fprintf(stderr,RED"Error"RESET" en la línea %d : Palabra no reconocida '"ROSA"%s",yylineno,$3);
																fprintf(stderr,RESET"' ¿Querías decir '"GREEN"hacer"RESET"'?\n");
															}else {fprintf(stderr,RED"Error"RESET" en la línea : %d\n",yylineno);}
														}

					| ID expression HACER statement {	$$ = inicializar_codigo();
										  				nErrores++;
														if(Levenshtein($1,"mientras") <= 2){
															fprintf(stderr,RED"Error"RESET" en la línea %d : Palabra no reconocida '"ROSA"%s",yylineno,$1);
															fprintf(stderr,RESET"' ¿Querías decir '"GREEN"mientras"RESET"'?\n");
														}else {fprintf(stderr,RED"Error"RESET" en la línea : %d\n",yylineno);}
													}

					| SI expression ID statement SINO statement { 	$$ = inicializar_codigo();
													  				nErrores++;
																	if(Levenshtein($3,"entonces") <= 2){
																		fprintf(stderr,RED"Error"RESET" en la línea %d : Palabra no reconocida '"ROSA"%s",yylineno,$3);
																		fprintf(stderr,RESET"' ¿Querías decir '"GREEN"entonces"RESET"'?\n");
																	}else {fprintf(stderr,RED"Error"RESET" en la línea : %d\n",yylineno);}
																}

					| SI expression ID statement		{ 	$$ = inicializar_codigo();
													  		nErrores++;
															if(Levenshtein($3,"entonces") <= 2){
																fprintf(stderr,RED"Error"RESET" en la línea %d : Palabra no reconocida '"ROSA"%s",yylineno,$3);
																fprintf(stderr,RESET"' ¿Querías decir '"GREEN"entonces"RESET"'?\n");
															}else {fprintf(stderr,RED"Error"RESET" en la línea : %d\n",yylineno);}
														}

					| ID statement MIENTRAS expression {	$$ = inicializar_codigo();
										  					nErrores++;
															if(Levenshtein($1,"repetir") <= 2){
																fprintf(stderr,RED"Error"RESET" en la línea %d : Palabra no reconocida '"ROSA"%s",yylineno,$1);
																fprintf(stderr,RESET"' ¿Querías decir '"GREEN"repetir"RESET"'?\n");
																}else {fprintf(stderr,RED"Error"RESET" en la línea : %d\n",yylineno);}
														}
					| REPETIR statement ID expression { $$ = inicializar_codigo();
										  				nErrores++;
														if(Levenshtein($3,"mientras") <= 2){
															fprintf(stderr,RED"Error"RESET" en la línea %d : Palabra no reconocida '"ROSA"%s",yylineno,$3);
															fprintf(stderr,RESET"' ¿Querías decir '"GREEN"mientras"RESET"'?\n");
														}else {fprintf(stderr,RED"Error"RESET" en la línea : %d\n",yylineno);} }


                    ;

print_list          : print_item { $$ = inicializar_codigo();
 							       concatenar_codigo($$,$1); }

                    | print_list COMA print_item { $$ = inicializar_codigo();
												   concatenar_codigo($$,$1);
												   concatenar_codigo($$,$3); }

                    ;

print_item          : expression { $$ = inicializar_codigo();
								   if(nErrores == 0){
									   concatenar_codigo($$,$1);
									   cua c = crear_cuadrupla("li","$v0","1",NULL);
									   cua c1 = crear_cuadrupla("move","$a0",getRes($1),NULL);
									   liberar_reg(getRes($1));
									   concatenar_cuadrupla($$,c1);
									   concatenar_cuadrupla($$,c);
									   cua c2 = crear_cuadrupla("syscall",NULL,NULL,NULL);
									   concatenar_cuadrupla($$,c2);
							   	   }
							   	 }

                    | STR { $$ = inicializar_codigo();
							if(nErrores == 0){

								char* str =  crearEtiquetaCadena();
								cua c = crear_cuadrupla("la","$a0",str,NULL);
								concatenar_cuadrupla($$,c);
								cua c1 = crear_cuadrupla("li","$v0","4",NULL);
								concatenar_cuadrupla($$,c1);
								cua c2 = crear_cuadrupla("syscall",NULL,NULL,NULL);
								concatenar_cuadrupla($$,c2);
								insertarCadena(str,$1);
							}
						  }

                    ;

read_list           : ID { $$ = inicializar_codigo();
						   cua c = crear_cuadrupla("li","$v0","5",NULL);
						   concatenar_cuadrupla($$,c);
						   cua c1 = crear_cuadrupla("syscall",NULL,NULL,NULL);
						   concatenar_cuadrupla($$,c1);
						   cua c2 = crear_cuadrupla("sw","$v0",concatenarString("_",$1),NULL);
						   concatenar_cuadrupla($$,c2); }

                    | read_list COMA ID { $$ = inicializar_codigo();
										  concatenar_codigo($$,$1);
										  cua c = crear_cuadrupla("li","$v0","5",NULL);
			   						   	  concatenar_cuadrupla($$,c);
			   						      cua c1 = crear_cuadrupla("syscall",NULL,NULL,NULL);
			   						      concatenar_cuadrupla($$,c1);
			   						      cua c2 = crear_cuadrupla("sw","$v0",concatenarString("_",$3),NULL);
			   						      concatenar_cuadrupla($$,c2); }

                    ;

expression          : expression MAS expression { char *reg = obtener_reg();
	  											  concatenar_codigo($1,$3);
												  cua cuad = crear_cuadrupla(strdup("add"),reg,getRes($1),getRes($3));
												  $$ = $1;
												  liberar_reg(getRes($1));
												  liberar_reg(getRes($3));
												  concatenar_cuadrupla($$,cuad); }

                    | expression MENOS expression { char *reg = obtener_reg();
						  							concatenar_codigo($1,$3);
													cua cuad = crear_cuadrupla("sub",reg,getRes($1),getRes($3));
													$$ = $1;
													liberar_reg(getRes($1));
													liberar_reg(getRes($3));
													concatenar_cuadrupla($$,cuad);  }

                    | expression POR expression { char *reg = obtener_reg();
						  					      concatenar_codigo($1,$3);
												  cua cuad = crear_cuadrupla("mul",reg,getRes($1),getRes($3));
												  $$ = $1;
												  liberar_reg(getRes($1));
												  liberar_reg(getRes($3));
												  concatenar_cuadrupla($$,cuad); }

                    | expression DIV expression { 	char *reg = obtener_reg();
						  							concatenar_codigo($1,$3);
													cua cuad = crear_cuadrupla("div",reg,getRes($1),getRes($3));
													$$ = $1;
													liberar_reg(getRes($1));
													liberar_reg(getRes($3));
													concatenar_cuadrupla($$,cuad); }

                    | MENOS expression %prec UMENOS { $$ = inicializar_codigo();
													  char *reg = obtener_reg();
												  	  cua c = crear_cuadrupla("neg",reg,getRes($2),NULL);
												  	  liberar_reg(getRes($2)); }

                    | PARI expression PARD { $$ = inicializar_codigo();
												concatenar_codigo($$,$2); }

                    | ID {
						   if(buscarVar($1) == 0){
							   nErrores++;
							   fprintf(stderr,RED"Error "RESET"en la línea %d : variable '"ROSA"%s"RESET"' no declarada\n",yylineno,$1);
						   }else {
							   char * reg = obtener_reg();
							   cua cuad = crear_cuadrupla("lw",reg,concatenarString("_",$1),NULL);
							   $$ = inicializar_codigo();
							   concatenar_cuadrupla($$,cuad); }


					 	  }

                    | NUM { $$ = inicializar_codigo();
							char *reg = obtener_reg();
					 		cua cuad = crear_cuadrupla("li",reg,$1,NULL);
							concatenar_cuadrupla($$,cuad);


						}

                    ;


%%


/* Tratamiento de errores */

void yyerror(char const *msg){
	 nErrores++;
     fprintf(stderr,RED"Error "RESET"Sintactico en linea %d: %s \n" ,yylineno,msg);

}


int main(int argc, char *argv[]){
    if (argc != 2){
        printf("Uso: %s fichero\n", argv[0]);
        exit(1);
    }
    FILE *f_in = fopen(argv[1],"r");
    if (f_in == NULL){
        printf("Archivo %s no existe",argv[1]);
        exit(2);
    }
    yyin = f_in;


	inicializar();
    yyparse();
    borrar();
    fclose(f_in);
    return 0;

}
