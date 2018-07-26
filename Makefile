prueba : lex.yy.c proyecto.tab.c listaVar.c listaVar.h codigo.h
	gcc -g lex.yy.c proyecto.tab.c listaVar.c codigo.c -ll -o prueba


lex.yy.c : proyecto.l proyecto.tab.h
	flex --yylineno proyecto.l

proyecto.tab.c proyecto.tab.h : proyecto.y
	bison -d -v -t proyecto.y

clean :
	rm -rf prueba lex.yy.c salida*.s proyecto.output prueba.dSYM proyecto.tab.*

run : prueba prueba.txt
	./prueba prueba.txt > salida.s

run2 : prueba prueba2.txt
	./prueba prueba2.txt > salida2.s

run3 : prueba prueba3.txt
	./prueba prueba3.txt > salida3.s
