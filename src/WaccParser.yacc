%{
#include <stdio.h>
#include <stdlib.h>
#include "ast.h"
#define MAXN 10000
valStorage sym[MAXN]; // 符号表

%}

%union {
    int index;
    valStorage val;
    treeNode *node; 
}

%token LEN ORD CHR GE NE EQ AND OR
%token BEGIN END IS SKIP READ FREE
%token RETURN EXIT PRINT PRINTLN IF
%token THEN ELSE FI WHILE DO DONE
%token FST SND NEWPAIR CALL BASETYPE
%token PAIR TRUE FALSE NULLX
%token CHAR_CONSTANT IDENTIFIER


%%

program: 
    BEGIN func_list stat END
    ;

func_list:
    func_list func
  | // NULL
    ;

stat:
    SKIP
  | type IDENTIFIER '=' rvalue
  | lvalue '=' rvalue
  | READ lvalue
  | FREE expr
  | RETURN expr
  | EXIT expr
  | PRINT expr
  | PRINTLN expr
  | IF expr THEN stat ELSE stat FI
  | WHILE expr DO stat DONE
  | BEGIN stat END
  | stat ';' stat
    ;

func:
    type IDENTIFIER '(' param_list ')' IS stat END
    ;


param_list:
    param param_with_comma
  | // NULL
    ;

param_with_comma:
    param_with_comma ',' param
  | // NULL
    ;

param:
    type IDENTIFIER
    ;

lvalue:
    IDENTIFIER
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
    BASETYPE
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
    int_liter
  | bool_liter
  | char_liter
  | str_liter
  | pair_liter
  | IDENTIFIER
  | array_elem
  | unary_oper expr
  | expr binary_oper expr
  | '(' expr ')'
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
    int_sign INTEGER_CONSTANT
    ;

int_sign:
    '+'
  | '-'
  | // NULL
    ;

bool_liter:
    TRUE
  | FALSE
    ;

array_liter:
    '[' ']'
  | '[' expr expr_with_comma ']'
    ;

pair_liter:
    NULLX
    ;
%%