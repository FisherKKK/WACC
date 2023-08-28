%{
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "util.h"
// #include "ast.h"
// #include "y.tab.h"
void yyerror(char *s);
%}

digit       [0-9]

%%
[-()<>\[\]=+*/;{}.,]            return *yytext;
">="                            return GE;
"<="                            return LE;
"!="                            return NE;
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

'[^'\n\"\\]'|'\\[0btnfr\"'\\]'  { 
                                    yylval.val.intval = convertchar(yytext); 
                                    yyval.val.vType = CHARACTER; 
                                    return CHAR_CONSTANT;
                                }

[A-Za-z_][A-Za-z0-9_]*          {
                                    yyval.index = BKDHash(yytext);
                                    return IDENTIFIER;
                                }

{digit}+                        { 
                                    yylval.val.intval = atoi(yytext); 
                                    yyval.val.vType = INTEGER; 
                                    return INTEGER_CONSTANT; 
                                }


#.*\n                           // 注释语句不处理
[ \t\n]                         
.                               yyerror("Unknown Character");
%%

int yywrap(void) {
  return 1; // return 1 represent over
}

