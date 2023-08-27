# makefile for a simple C compiler buildchain

all: basic

y.tab.c: BasicParser.yacc
	yacc -d BasicParser.yacc

lex.yy.c: BasicLexer.lex BasicParser.yacc
	lex BasicLexer.lex

y.tab.o: y.tab.c lex.yy.c
	gcc -c y.tab.c lex.yy.c

basic: y.tab.o lex.yy.o BasicVisitor.c 
	gcc y.tab.o lex.yy.o BasicVisitor.c -o basic

clean: 
	rm basic y.tab.* lex.yy.*

.PHONY: clean all
