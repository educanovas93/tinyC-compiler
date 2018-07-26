#ifndef __LISTAVAR__
#define __LISTAVAR__


void inicializar();
void borrar();

void insertarVar(char *x,int valor);
int buscarVar(char *x);

char* crearEtiquetaCadena();
struct cadenaRep *buscarCadenaRep(char *valor);
char *buscarCadena(char *valor);
void insertarCadena(char *id,char *valor);


void imprimirTabla();

#endif
