#include "listaVar.h"
#include "codigo.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


typedef struct varRep{
    char *nombre;
    int valor;
    struct varRep *sig;
}varRep;

typedef struct cadenaRep{
	char *id;
	char *cadena;
	struct cadenaRep *sig;

}cadenaRep;


int nCadena = 1;

varRep *primero,*ultimo;
cadenaRep *primCadena,*ultimoCadena;

//Método común para inicializar las listas

void inicializar(){
	primero = ultimo = NULL;
	primCadena = ultimoCadena = NULL;
}


//Métodos de la lista de variables


varRep *buscarNodo(char *x){
varRep *aux = primero;
  	while ((aux != NULL ) && (strcmp(x,aux->nombre) !=0)) {
		aux = aux->sig;
  	}
  	return aux;
}

void insertarVar(char *x,int valor){
	varRep *aux = buscarNodo(x);
	if(aux != NULL){
	aux->valor = valor;
	}
	else{
		aux=(varRep*)malloc(sizeof(varRep));
		aux->valor=valor;
		aux->nombre = x;
		aux->sig=NULL;
	if(ultimo !=NULL ){
		ultimo->sig = aux;
		ultimo=aux;
	}
	else{
		ultimo = primero = aux;
		}
	}
}

int buscarVar(char *x){
	varRep *aux = buscarNodo(x);
	if(aux!=NULL){
		return aux->valor;
	}
	return 0;
}


//Método común para borrar las listas
void borrar(){

    varRep *aux = primero;
    while (aux != NULL){
        free(aux->nombre);
		primero = aux->sig;
        free(aux);
        aux = primero;
    }

	cadenaRep *aux2 = primCadena;
	while(aux2 != NULL){
		free(aux2->id);
		primCadena = aux2->sig;
		free(aux2);
		aux2 = primCadena;
	}
}


//Métodos de la lista de cadenas

char* crearEtiquetaCadena(){
	char * aux = concatenar("$str",nCadena);
	nCadena++;
	return aux;
}


cadenaRep *buscarCadenaRep(char *valor){
  	cadenaRep *aux = primCadena;
  	while (aux != NULL ) {
		aux = aux->sig;
	}
	return aux;
}

char *buscarCadena(char *valor){
	cadenaRep *aux = buscarCadenaRep(valor);
	if(aux != NULL){
		return aux->cadena;
	}
	printf("Cadena %s no inicializada!\n",valor);
	return "";
}




void insertarCadena(char *id,char *valor){
	cadenaRep *aux = buscarCadenaRep(valor);
	if(aux != NULL){
		aux->cadena = valor;
	}
	else{

		aux=(cadenaRep *)malloc(sizeof(cadenaRep));
		aux->cadena=valor;
		aux->id = id;
		aux->sig = NULL;
		if(ultimoCadena != NULL ){
			ultimoCadena->sig = aux;
			ultimoCadena=aux;
		}
		else{
			ultimoCadena = primCadena = aux;
		}
	}
}


void imprimirTabla(){
	cadenaRep *aux = primCadena;
	printf("###################\n");
	printf("# Sección de datos\n");
	printf("\t.data\n\n");
	while(aux != NULL){
		printf("%s:\n",aux->id);
		printf("\t.asciiz %s\n",aux->cadena);
		aux = aux->sig;
	}

	varRep *aux2 = primero;
	while(aux2 != NULL){
		printf("_%s:\n",aux2->nombre);
		printf("\t.word 0\n");
		aux2 = aux2->sig;
	}

	printf("\n####################\n");
	printf("# Sección de Código\n");
	printf("\t.text\n");
	printf("\t.globl main\n");
	printf("main:\n");

}
