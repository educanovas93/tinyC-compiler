#ifndef _CODIGO_H_
#define _CODIGO_H_


typedef struct cuadrupla* cua;
typedef struct codigo* cod;


cua crear_cuadrupla(char *op, char* res,char* arg1, char* arg2);
cod inicializar_codigo();
void concatenar_cuadrupla(cod l , cua c);
void concatenar_codigo(cod l1,cod l2);
char *obtener_reg();
void liberar_reg(char *reg);
char * getRes(cod c);
char *getEtiqueta();
char *getNCadena();
void imprimirCodigo(cod c);
int Levenshtein(char *s1,char *s2);


char * concatenarString(char * prefijo, char * sufijo);
char * concatenar(char *prefijo,int valor);


#endif
