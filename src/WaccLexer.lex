%{
#include <stdlib.h>
#include <string.h>
#include "ast.h"
#include "y.tab.h"
void yyerror(char *s);
%}

digit       [0-9]
letter      [A-Za-z]

%%


[A-Za-z_][A-Za-z0-9_]*          return IDENTIFIER;
{digit}+                        return INTEGER;
\#.*\n                          {printf("This is comment")}
"("                             return OPEN_PARENTHESES;
")"                             return CLOSE_PARENTHESES;
"["                             return OPEN_BRACKET;
"]"                             return CLOSE_BRACKET;
","                             return COMMA;
"begin"                         return BEGIN;
"end"                           return END;
"is"                            return IS;
"skip"                          return SKIP;
"read"                          return READ;
"free"                          return FREE;
"return"                        return RETURN;
"exit"                          return EXIT;
"print"                         return PRINT;
"println"                       return PRINTLN;
"if"                            return IF;
"then"                          return THEN;
"else"                          return ELSE;
"fi"                            return FI;
"while"                         return WHILE;
"do"                            return DO;
"done"                          return DONE;
"fst"                           return FST;
"snd"                           return SND;
"newpair"                       return NEWPAIR;
"call"                          return CALL;
"int"|"bool"|"char"|"string"    return TYPE;
"pair"                          return PAIR;
"true"                          return TRUE;
"false"                         return FALSE;
"null"                          return NULLX;

%%

%%

%%

