// lex测试文件
%{
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "util.h"
#define MAXL 10000
// #include "ast.h"
// #include "y.tab.h"
// void yyerror(char *s);
char buf[MAXL], *str;
%}

digit       [0-9]
%x STRINGMOD

%%
[-()<>\[\]=+*/;{}.,!%]          putchar(*yytext); putchar('\n');
">="                            puts("GE");
"<="                            puts("LE");
"!="                            puts("NE");
"=="                            puts("EQ");
"&&"                            puts("AND");
"||"                            puts("OR");
"begin"                         puts("BEGIN");
"end"                           puts("END");
"is"                            puts("IS");
"skip"                          puts("SKIP");
"read"                          puts("READ");
"free"                          puts("FREE");
"return"                        puts("RETURN");
"exit"                          puts("EXIT");
"print"                         puts("PRINT");
"println"                       puts("PRINTLN");
"if"                            puts("IF");
"then"                          puts("THEN");
"else"                          puts("ELSE");
"fi"                            puts("FI");
"while"                         puts("WHILE");
"do"                            puts("DO");
"done"                          puts("DONE");
"fst"                           puts("FST");
"snd"                           puts("SND");
"newpair"                       puts("NEWPAIR");
"call"                          puts("CALL");
"int"|"bool"|"char"|"string"    puts("TYPE");
"pair"                          puts("PAIR");
"true"                          puts("TRUE");
"false"                         puts("FALSE");
"null"                          puts("NULLX");

'[^'\n\"\\]'|'\\[0btnfr\"'\\]'  { 
                                    // yylval.val.intval = convertchar(yytext); 
                                    // yyval.val.vType = CHARACTER; 
                                    puts("CHAR_CONSTANT");
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
                                    *str = 0; BEGIN 0;
                                    char *p = strdup(buf);
                                    printf("%d\n", strlen(p));
                                    free(p);
                                }
<STRINGMOD>\n                   { printf("error\n"); exit(100); }
<STRINGMOD>.                    { *str++ = *yytext; }


[A-Za-z_][A-Za-z0-9_]*          {
                                    // yyval.index = BKDHash(yytext);
                                    puts("IDENTIFIER");
                                }

{digit}+                        { 
                                    // yylval.val.intval = atoi(yytext); 
                                    // yyval.val.vType = INTEGER; 
                                    puts("INTEGER_CONSTANT"); 
                                }


#.*\n                           { puts("comments"); } // 注释语句不处理
[ \t\n]                         { puts("blank"); } // 不处理空白符
.                               puts("Unknown Character");
%%

int yywrap(void) {
  return 1; // return 1 represent over
}

