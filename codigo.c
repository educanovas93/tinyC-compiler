#include "codigo.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#define NREG 10
// macros para maximo y mínimo
#define min(a,b) (((a)<(b))?(a):(b))
#define max(a,b) (((a)>(b))?(a):(b))

char registros[NREG] = { 0 };
int etiqueta = 0;
int NCadena = 0;

struct cuadrupla{
	char *op;
	char *res;
	char *arg1;
	char *arg2;
	struct cuadrupla *sig;
};

struct codigo{
	struct cuadrupla *prim;
	struct cuadrupla *ult;
	char *res;
};



char *concatenar(char *prefijo,int valor) {
	char aux[64];
	snprintf(aux,64,"%s%d",prefijo,valor);
	return strdup(aux);
}


char *concatenarString(char *prefijo,char *sufijo) {
	char aux[64];
	snprintf(aux,64,"%s%s",prefijo,sufijo);
	return strdup(aux);
}


char * obtener_reg(){

	int i;
	for(i = 0; i < NREG;i++) {
		if(registros[i] == 0) break;
	}
	if (i == NREG) {
		printf("Error: No quedan registros libres\n");
		exit(1);
	}
	registros[i] = 1;
	return concatenar("$t",i);

}


void liberar_reg(char * reg){
	char aux = reg[2];
	aux = aux - '0';
	registros[(int)aux] = 0;
}


cua crear_cuadrupla (char* op,char* res,char* arg1,char* arg2){

	struct cuadrupla* aux = malloc(sizeof(struct cuadrupla));

	aux->op = strdup(op);
	aux->res = (res != NULL ? strdup(res) : NULL);
	aux->arg1 = (arg1 != NULL ? strdup(arg1) : NULL);
	aux->arg2 = (arg2 != NULL ? strdup(arg2) : NULL);
	aux->sig = NULL;
	return aux;

}


struct codigo *inicializar_codigo(){
	struct codigo *aux = malloc(sizeof(struct codigo));
	aux->prim = aux->ult = NULL;
	return aux;
}


void concatenar_cuadrupla(struct codigo * l,struct cuadrupla * c){
	if(l->ult != NULL){
		l->ult->sig = c;
		l->ult = c;
		l->res = c->res;
		}else{
			l->prim = l->ult = c;
			l->res = c->res;
		}

}


void concatenar_codigo(struct codigo * l1,struct codigo * l2 ){
	if(l1->ult != NULL && l2->prim != NULL){
		l1->ult->sig = l2->prim;
		l1->ult = l2->ult;

	}else {
			*l1 = *l2;
	}

}

char * getRes(struct codigo * c){
		return c->res;
}

char *getEtiqueta(){
	etiqueta++;
	return concatenar("$l",etiqueta);
}

char *getNCadena(){
	return concatenar("$str",NCadena);

}


void imprimirCodigo(struct codigo *c){

	struct cuadrupla *cuad = c->prim;
	struct cuadrupla *aux;
	while(cuad != NULL){

		if(cuad->op[1] == 'l'){
			printf("%s: \n",cuad->op);
		}else if(cuad->res == NULL){
			printf("\t%s	\n",cuad->op);
		}else if(cuad->arg1 == NULL){
			printf("\t%s	%s\n",cuad->op,cuad->res );
		}else if(cuad->arg2 == NULL){
			printf("\t%s\t %s, %s \n",cuad->op,cuad->res,cuad->arg1);
		}else {
			printf("\t%s\t %s, %s, %s \n",cuad->op,cuad->res,cuad->arg1,cuad->arg2);
		}

		aux = cuad;
		cuad = cuad->sig;
		free(aux);
	}
	printf("\n####################\n");
	printf("# Fin\n");
	printf("    jr");
	printf("	$ra");

}

// función que usamos para saber los caracteres de diferencia que hay entre dos cadenas
int Levenshtein(char *s1,char *s2){
	int t1,t2,i,j,*m,costo,res,ancho;

    t1=strlen(s1); t2=strlen(s2);

    if (t1==0) return(t2);
    if (t2==0) return(t1);
    ancho=t1+1;


    m=(int*)malloc(sizeof(int)*(t1+1)*(t2+1));
    if (m==NULL) return(-1); // ERROR!!


    for (i=0;i<=t1;i++) m[i]=i;
    for (j=0;j<=t2;j++) m[j*ancho]=j;


    for (i=1;i<=t1;i++) for (j=1;j<=t2;j++)
       { if (s1[i-1]==s2[j-1]) costo=0; else costo=1;
         m[j*ancho+i]=min(min(m[j*ancho+i-1]+1,     // Eliminacion
                        m[(j-1)*ancho+i]+1),              // Insercion
                        m[(j-1)*ancho+i-1]+costo); }      // Sustitucion


    res=m[t2*ancho+t1];
    free(m);
    return(res);
}
