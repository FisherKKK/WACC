# makefile for a simple C compiler buildchain

all: basic

y.tab.c: WaccParser.yacc
	yacc -d WaccParser.yacc

lex.yy.c: WaccLexer.lex WaccParser.yacc
	lex WaccLexer.lex

y.tab.o: y.tab.c lex.yy.c
	gcc -c y.tab.c lex.yy.c

basic: y.tab.o lex.yy.o ast.c
	gcc y.tab.o lex.yy.o ast.c -o basic

clean: 
	rm basic y.tab.* lex.yy.* core.*

.PHONY: clean all
