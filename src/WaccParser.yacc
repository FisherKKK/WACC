%{
#include <stdio.h>
#include <stdlib.h>
#include "ast.h"

// valNode sym[MAXN]; // 符号表
treeNode *sym[MAXN]; // 符号表
int current_scope = 0; // 当前作用
int scope[MAXN]; // 作用域, 采用并查集的思想

void yyerror(char*);
int yylex();
treeNode* make_op_node(int op, int nops, ...);
treeNode* index2node(treeNode* type, int index);
treeNode* make_basetype_node(valNode vn);
treeNode* liter2node(valNode vn);
treeNode *make_empty_node();
void visit(treeNode *node);
void freenode(treeNode *node);
int check_type(treeNode* t1, treeNode *t2);
int check_int(treeNode* node);
int check_boolean(treeNode *node);

%}

%union {
    int index;
    valNode val;
    treeNode *node; 
}

%token LEN ORD CHR GE LE NE EQ AND OR
%token BEGINX END IS SKIP READ FREE
%token RETURN EXIT PRINT PRINTLN IF
%token THEN ELSE FI WHILE DO DONE
%token FST SND NEWPAIR CALL
%token PAIR NULLX
%token <val> CHAR_CONSTANT STRING_CONSTANT INTEGER_CONSTANT BOOLEAN_CONSTANT
%token <val> INT_TYPE BOOLEAN_TYPE CHAR_TYPE STRING_TYPE
%token <index> IDENTIFIER
%type <node> stat lvalue rvalue int_liter expr type base_type func
%type <index> unary_oper binary_oper


%left GE LE EQ NE '>' '<'
%left '+' '-'
%left '*' '/'
%nonassoc UNIOP


%%

program: 
    BEGINX func_list stat END        {  visit($3); freenode($3); printf("Complete\n"); }
    ;

func_list:
    func_list func
  | // NULL
    ;

stat:
    SKIP                            { $$ = make_empty_node(); }
  | type IDENTIFIER '=' rvalue      { $$ = make_op_node('=', 2, index2node($1, $2), $4); check_type($1, $4); }
  | lvalue '=' rvalue               { $$ = make_op_node('=', 2, $1, $3); check_type($1, $3); }
  | READ lvalue                     { $$ = make_op_node(READ, 1, $2); }
  | FREE expr                       { $$ = make_op_node(FREE, 1, $2); }
  | RETURN expr                     { $$ = make_op_node(RETURN, 1, $2); }
  | EXIT expr                       { $$ = make_op_node(EXIT, 1, $2); check_int($2); }
  | PRINT expr                      { $$ = make_op_node(PRINT, 1, $2); }
  | PRINTLN expr                    { $$ = make_op_node(PRINTLN, 1, $2); }
  | IF expr THEN stat ELSE stat FI  { $$ = make_op_node(IF, 3, $2, $4, $6); check_boolean($2); }
  | WHILE expr DO stat DONE         { $$ = make_op_node(WHILE, 2, $2, $4); check_boolean($2); }
  | BEGINX stat END                 { $$ = $2; }
  | stat ';' stat                   { $$ = make_op_node(';', 2, $1, $3); }
    ;

func:
    type IDENTIFIER '(' param_list ')' IS stat END  { $$ = make_empty_node(); }
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
    expr                          { $$ = $1; }
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
    base_type                       { $$ = $1; }
  | array_type                      
  | pair_type
    ;
  
base_type:
    INT_TYPE                        { $$ = make_basetype_node($1); }            
  | CHAR_TYPE                       { $$ = make_basetype_node($1); }
  | STRING_TYPE                     { $$ = make_basetype_node($1); }
  | BOOLEAN_TYPE                    { $$ = make_basetype_node($1); }
    ;

array_type:
    type '[' ']'
    ;

pair_type:
    PAIR '(' pair_elem_type ',' pair_elem_type ')'
    ;

pair_elem_type:
    base_type
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
  | unary_oper expr %prec UNIOP   { $$ = make_op_node($1, 1, $2); }
  | expr binary_oper expr         { $$ = make_op_node($2, 2, $1, $3); }
  | '(' expr ')'                  { $$ = $2; }
    ;

unary_oper:
    '!'                           { $$ = '!'; }
  | '-'                           { $$ = '-'; }
  | LEN                           { $$ = LEN; }
  | ORD                           { $$ = ORD; }
  | CHR                           { $$ = CHR; }
    ;

binary_oper:
    '*'                           { $$ = '*'; }
  | '/'                           { $$ = '/'; }
  | '%'                           { $$ = '%'; }
  | '+'                           { $$ = '+'; }
  | '-'                           { $$ = '-'; }
  | '>'                           { $$ = '>'; }
  | GE                            { $$ = GE; }
  | '<'                           { $$ = '<'; }
  | LE                            { $$ = LE; }
  | EQ                            { $$ = EQ; }
  | NE                            { $$ = NE; }
  | AND                           { $$ = AND; }
  | OR                            { $$ = OR; }
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

treeNode* make_op_node(int op, int nops, ...) {
    va_list ap;
    treeNode *node;
    int i;
    if ((node = malloc(sizeof(*node) + sizeof(treeNode*) * nops))
            == NULL)
        yyerror("out of memory");
    node->type = oprType;
    node->opr.op = op;
    node->opr.nops = nops;
    va_start(ap, nops);
    for (i = 0; i < nops; i++)
        node->opr.children[i] = va_arg(ap, treeNode*);
    va_end(ap);
    return node;
}

/* 将标识符id转换为节点 */
treeNode* index2node(treeNode *type, int index) {
    treeNode *node;
    if ((node = malloc(sizeof(*node))) == NULL)
        yyerror("out of memory");
    node->type = idType;
    node->id.i = index;
    node->id.vt = type;
    return sym[index] = node;
}

// 将常量转换为节点
treeNode* liter2node(valNode vn) {
  treeNode *node;
  if ((node = malloc(sizeof(*node))) == NULL)
      yyerror("out of memory\n");
  node->type = valueType;
  node->val = vn;
  return node;
}

// 将类型转换为节点
treeNode* make_basetype_node(valNode vn) {
  treeNode *node;
  if ((node = malloc(sizeof(*node))) == NULL)
    yyerror("out of memory");
  node->type = tpType;
  node->tp.basetype = vn.intval;
  return node;
}

// skip类型的空节点
treeNode *make_empty_node() {
  treeNode *node;
  if ((node = malloc(sizeof(*node))) == NULL)
    yyerror("out of memory");
  node->type = skipType;
  return node;
}

void yyerror(char *s) {
  fprintf(stdout, "%s\n", s);
}

void freenode(treeNode *node) {
  if (node == NULL) return;
  switch (node->type) {
    case oprType:
      for (int i = 0; i < node->opr.nops; i++)
        freenode(node->opr.children[i]);
      free(node);
      break;

    case valueType:
      if (node->val.vType == STRING) free(node->val.sval);
      free(node);
      break;
    case idType:
      /* free(node->id.vt); */
    case tpType:
      break; // 暂时不考虑复杂类型
  }
  return;
}

int check_type(treeNode* t1, treeNode *t2) {
  if (t1->type == t2->type && t1->type = tpType) {
    return t1->tp.basetype == t2->tp.basetype;
  }
  return 0;
}

treeNode* copy(treeNode *t) {
  treeNode *node;
  return node;
}

int main(void) {
  yyparse();
  return 0;
}

