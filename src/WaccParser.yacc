%{
#include <stdio.h>
#include <stdlib.h>
#include "ast.h"


%}

%union {
    int index;
    valNode val;
    treeNode *node; 
}

%token LEN ORD CHR GE LE NE EQ AND OR
%token BEGIN END IS SKIP READ FREE
%token RETURN EXIT PRINT PRINTLN IF
%token THEN ELSE FI WHILE DO DONE
%token FST SND NEWPAIR CALL BASETYPE
%token PAIR NULLX
%token <val> CHAR_CONSTANT STRING_CONSTANT INTEGER_CONSTANT BOOLEAN_CONSTANT
%token <index> IDENTIFIER
%type <node> stat lvalue int_liter expr type



%%

program: 
    BEGIN func_list stat END        { visit($2); visit($3); freenode($2); freenode($3); printf("Complete\n"); }
    ;

func_list:
    func_list func
  | // NULL
    ;

stat:
    SKIP                            { }
  | type IDENTIFIER '=' rvalue      { $$ = make_op_node('=', 2, index2node($1, $2), $4); }
  | lvalue '=' rvalue               { $$ = make_op_node('=', 2, $1, $3); }
  | READ lvalue                     { printf("read op\n"); }
  | FREE expr                       { printf("free op\n"); }
  | RETURN expr                     { printf("return op\n"); }
  | EXIT expr                       { printf("exit op\n"); }
  | PRINT expr                      { printf("print op\n"); }
  | PRINTLN expr                    { printf("println op\n");}
  | IF expr THEN stat ELSE stat FI  { printf("IF op\n"); }
  | WHILE expr DO stat DONE         { printf("while op\n");}
  | BEGIN stat END                  { printf("begin op\n");}
  | stat ';' stat                   { printf("stat op\n"); }
    ;

func:
    type IDENTIFIER '(' param_list ')' IS stat END  { printf("function\n"); }
    ;


param_list:
    param param_with_comma          { printf("param list\n"); }
  | // NULL
    ;

param_with_comma:
    param_with_comma ',' param      { printf("param with comma\n"); }
  | // NULL
    ;

param:
    type IDENTIFIER
    ;

lvalue:
    IDENTIFIER                      { $$ = sym[$1]; }
  | array_elem
  | pair_elem
    ;

pair_elem:
    FST lvalue
  | SND lvalue
    ;

rvalue:
    expr
  | array_liter
  | NEWPAIR '(' expr ',' expr ')'
  | pair_elem
  | CALL IDENTIFIER '(' arg_list ')'
    ;

arg_list:
    expr expr_with_comma
  | // NULL
    ;

expr_with_comma:
    expr_with_comma ',' expr
  | // NULL
    ;

type:
    BASETYPE                      { $$ = make_type_node($1); }
  | array_type
  | pair_type
    ;

array_type:
    type '[' ']'
    ;

pair_type:
    PAIR '(' pair_elem_type ',' pair_elem_type ')'
    ;

pair_elem_type:
    BASETYPE
  | array_type
  | PAIR
    ;

expr:
    int_liter                     { $$ = $1; }
  | BOOLEAN_CONSTANT              { $$ = liter2node($1); }
  | CHAR_CONSTANT                 { $$ = liter2node($1); }
  | STRING_CONSTANT               { $$ = liter2node($1); }
  | pair_liter
  | IDENTIFIER                    { $$ = sym[$1]; }
  | array_elem
  | unary_oper expr
  | expr binary_oper expr
  | '(' expr ')'                  { $$ = $2; }
    ;

unary_oper:
    '!'
  | '-'
  | LEN
  | ORD
  | CHR
    ;

binary_oper:
    '*'
  | '/'
  | '%'
  | '+'
  | '-'
  | '>'
  | GE
  | '<'
  | LE
  | EQ
  | NE
  | AND
  | OR
    ;

array_elem:
    IDENTIFIER expr_with_bracket
    ;

expr_with_bracket:
    '[' expr ']'
  | expr_with_bracket '[' expr ']'
    ;

int_liter:
    '+' INTEGER_CONSTANT            { $$ = liter2node($2); } 
  | '-' INTEGER_CONSTANT            { $2.val.intval = -$2.val.intval; $$ = liter2node($2); }
  | INTEGER_CONSTANT                { $$ = liter2node($1); }
    ;

array_liter:
    '[' ']'
  | '[' expr expr_with_comma ']'
    ;

pair_liter:
    NULLX
    ;
%%

