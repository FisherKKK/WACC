%{
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "util.h"
#define MAXL 10000
#include "ast.h"
#include "y.tab.h"
void yyerror(char *s);
char buf[MAXL], *str;
%}

digit       [0-9]
%x STRINGMOD

%%
[-()<>\[\]=+*/;{}.,!%]          return *yytext;
"len"                           return LEN;
"ord"                           return ORD;
"chr"                           return CHR;
">="                            return GE;
"<="                            return LE;
"!="                            return NE;
"=="                            return EQ;
"&&"                            return AND;
"||"                            return OR;
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
"int"|"bool"|"char"|"string"    return BASETYPE;
"pair"                          return PAIR;
"true"                          return TRUE;
"false"                         return FALSE;
"null"                          return NULLX;

'[^'\n\"\\]'|'\\[0btnfr\"'\\]'  { 
                                    yylval.val.intval = convertchar(yytext); 
                                    yyval.val.vType = CHARACTER; 
                                    return CHAR_CONSTANT;
                                }

\"                              { BEGIN STRINGMOD; str = buf; }   
<STRINGMOD>\\\\                 { *str++ = '\\'; }
<STRINGMOD>\\\"                 { *str++ = '\"'; }
<STRINGMOD>\\0                  { *str++ = '\0'; }
<STRINGMOD>\\b                  { *str++ = '\b'; }
<STRINGMOD>\\t                  { *str++ = '\t'; }
<STRINGMOD>\\n                  { *str++ = '\n'; }
<STRINGMOD>\\f                  { *str++ = '\f'; }
<STRINGMOD>\\r                  { *str++ = '\r'; }
<STRINGMOD>\"                   { 
                                    *str = '\0'; BEGIN 0;
                                    yyval.val.sval = strdup(buf);
                                    yyval.val.vType = STRING;
                                    return STRING_CONSTANT
                                }
<STRINGMOD>\n                   { exit(100); }
<STRINGMOD>.                    { *str++ = *yytext; }


[A-Za-z_][A-Za-z0-9_]*          {
                                    yyval.index = BKDHash(yytext);
                                    return IDENTIFIER;
                                }

{digit}+                        { 
                                    yylval.val.intval = atoi(yytext); 
                                    yyval.val.vType = INTEGER; 
                                    return INTEGER_CONSTANT; 
                                }


#.*\n                           { } // 注释语句不处理
[ \t\n]                         { } // 不处理空白符
.                               yyerror("Unknown Character");
%%

int yywrap(void) {
  return 1; // return 1 represent over
}

