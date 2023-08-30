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
void visit(treeNode *node);
void freenode(treeNode *node);

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
%type <node> stat lvalue rvalue int_liter expr type base_type
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
  | BEGINX stat END                  { printf("begin op\n");}
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

void yyerror(char *s) {
  fprintf(stdout, "%s\n", s);
}

void freenode(treeNode *node) {
  if (node == NULL) return;
  switch (node->type) {
    case oprType:
      for (int i = 0; i < node->opr.nops; i++)
        freenode(node->opr.children[i]);
      break;
    case valueType:
      if (node->val.vType == STRING) free(node->val.sval);
      break;
    case idType:
      free(node->id.vt);
    case tpType:
      break; // 暂时不考虑复杂类型
  }
  return;
}

int main(void) {
  yyparse();
  return 0;
}

