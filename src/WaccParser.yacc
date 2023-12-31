%{
#include <stdio.h>
#include <stdlib.h>
#include "ast.h"

// valNode sym[MAXN]; // 符号表
treeNode *sym[MAXN]; // 符号表, 存放变量和函数
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
int check_uniop(treeNode *od, int op);
int check_binary_op(treeNode *od1, treeNode *od2, int op, int all);
treeNode *make_function_node(int index, treeNode *fn, treeNode *params, treeNode *body);
treeNode* make_param_node(int index, treeNode *tn);
treeNode* make_params_node(treeNode *node);
treeNode* add_param(treeNode *l, treeNode *p);
treeNode* make_call_node(int index, treeNode *arg);
treeNode* make_expr_list(treeNode *tn);
treeNode* add_expr(treeNode *l, treeNode *e);
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
%type <node> stat lvalue rvalue int_liter expr type base_type func param_list param arg_list
%type <index> unary_oper binary_oper


%left GE LE EQ NE '>' '<'
%left '+' '-'
%left '*' '/'
%nonassoc UNIOP


%%

program: 
    BEGINX func_list stat END        {  /* visit($3); */ freenode($3); printf("Complete\n"); }
    ;

func_list:
    func_list func                    { }
  | // NULL
    ;

stat:
    SKIP                            { $$ = make_empty_node(); }
  | type IDENTIFIER '=' rvalue      { check_binary_op($1, $4, '=', 1);  $$ = make_op_node('=', 2, index2node($1, $2), $4); }
  | lvalue '=' rvalue               { check_binary_op($1, $3, '=', 1); $$ = make_op_node('=', 2, $1, $3);  }
  | READ lvalue                     { $$ = make_op_node(READ, 1, $2); }
  | FREE expr                       { $$ = make_op_node(FREE, 1, $2); }
  | RETURN expr                     { $$ = make_op_node(RETURN, 1, $2); }
  | EXIT expr                       { check_uniop($2, EXIT); $$ = make_op_node(EXIT, 1, $2); }
  | PRINT expr                      { check_uniop($2, PRINT);  $$ = make_op_node(PRINT, 1, $2); }
  | PRINTLN expr                    { check_uniop($2, PRINTLN); $$ = make_op_node(PRINTLN, 1, $2); }
  | IF expr THEN stat ELSE stat FI  { check_uniop($2, IF); $$ = make_op_node(IF, 3, $2, $4, $6);  }
  | WHILE expr DO stat DONE         { check_uniop($2, WHILE); $$ = make_op_node(WHILE, 2, $2, $4); }
  | BEGINX stat END                 { $$ = $2; }
  | stat ';' stat                   { $$ = make_op_node(';', 2, $1, $3); }
    ;

func:
    type IDENTIFIER '(' param_list ')' IS stat END  {  check_binary_op($1, $7, 'f', 1); $$ = make_function_node($2, $1, $4, $7);}
    ;


param_list:
    param                           { $$ = make_params_node($1); }
  | param_list ',' param            { $$ = add_param($1, $3); }
  | /* NULL */                      { $$ = make_params_node(NULL); }
    ;

param:
    type IDENTIFIER                 { $$ = make_param_node($2, $1); }
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
  | CALL IDENTIFIER '(' arg_list ')' { $$ = make_call_node($2, $4); }
    ;

arg_list:
    expr                             { $$ = make_expr_list($1); }
  | arg_list ',' expr                { $$ = add_expr($1, $3); }
  | /* NULL */                       { $$ = make_expr_list(NULL); }
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
  | unary_oper expr %prec UNIOP   { check_uniop($2, $1); $$ = make_op_node($1, 1, $2); }
  | expr binary_oper expr         { check_binary_op($1, $3, $2, 0); $$ = make_op_node($2, 2, $1, $3); }
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


int check_binary_op(treeNode *od1, treeNode *od2, int op, int all) {
  int same = (od1->tp.basetype == od2->tp.basetype); // TODO: 仅考虑基本类型
  if (!same) { puts("Must same Type"); exit(200); }
  /* if (all || op == NE || op == EQ || op == '=') return same; */
  switch (op) {
    case '*':
    case '+':
    case '-':
    case '/':
    case '%':  if (od1->tp.basetype != 0) puts("Must INT"), exit(200); break;

    case '>':
    case GE:
    case LE:
    case '<': if (!(od1->tp.basetype == 0 || od1->tp.basetype)) puts("Must INT/CHAR"), exit(200); break;

    case AND:
    case OR: if (od1->tp.basetype != 1) puts("MUST BOOLEAN"), exit(200); break;

    case 'f':
              if (!od2->istp) puts("Function MUST RETURN"), exit(200); break;
  }
  return 0;
}

int check_uniop(treeNode *od, int op) {
  switch (op) {
    case IF:
    case WHILE:
    case '!': if (od->tp.basetype != 1) puts("IF/WHILE/! Must BOOLEAN"), exit(200); break;

    case EXIT:
    case CHR:
    case '-': if (od->tp.basetype != 0) puts("EXIT/CHR/- Must INT"), exit(200); break;

    case ORD: if (od->tp.basetype != 2) puts("Must CHAR"), exit(200); break;
  }
  return 0;
}

//TODO 处理;问题
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
        { node->opr.children[i] = va_arg(ap, treeNode*); }
    va_end(ap);
    node->istp = 0;
    switch (op) {
      case ORD:
      case '+':
      case '-':
      case '*':
      case '/':
      case '%':
                node->istp = 1; 
                node->tp.isbase = 1; 
                node->tp.basetype = 0;
                break;
      case '>':
      case '<':
      case '!':
      case LE:
      case GE:
      case NE:
      case EQ:
      case AND:
      case OR: 
                node->istp = 1; 
                node->tp.isbase = 1; 
                node->tp.basetype = 1;
                break;
      case CHR:
                node->istp = 1;
                node->tp.isbase = 1;
                node->tp.basetype = 2;
                break;
      
      case ';':
              if (node->opr.children[1]->istp)
                { 
                  node->istp = 1; node->tp.isbase = 1; // 暂时未考虑复杂类型
                  node->tp.basetype = node->opr.children[1]->tp.basetype; 
                }
              break;
      case RETURN:
              node->istp = 1; node->tp.isbase = 1;
              node->tp.basetype = node->opr.children[0]->tp.basetype;
              break;
    }
    return node;
}



/* 将标识符id转换为节点 */
treeNode* index2node(treeNode *type, int index) {
    treeNode *node;
    if ((node = malloc(sizeof(*node))) == NULL)
        yyerror("out of memory");
    node->type = idType;
    node->id.i = index;
    node->istp = 1;
    node->tp = type->tp;
    return sym[index] = node;
}

// 将常量转换为节点, 设置结果类型
treeNode* liter2node(valNode vn) {
  treeNode *node;
  if ((node = malloc(sizeof(*node))) == NULL)
      yyerror("out of memory\n");
  node->type = valueType;
  node->val = vn;
  node->tp.isbase = 1;
  node->istp = 1; // 具备结果类型
  switch (vn.vType) {
    case INTEGER:  node->tp.basetype = 0; break;
    case BOOLEAN:  node->tp.basetype = 1; break;
    case CHARACTER: node->tp.basetype = 2; break;
    case STRING: node->tp.basetype = 3; break;
  }
  return node;
}

// 将类型转换为节点, 是个类型标识, 本身不具有结果类型
treeNode* make_basetype_node(valNode vn) {
  treeNode *node;
  if ((node = malloc(sizeof(*node))) == NULL)
    yyerror("out of memory");
  node->type = tpType;
  node->tp.basetype = vn.intval;
  node->istp = 0; // 本身不具有类型
  return node;
}

// skip类型的空节点
treeNode *make_empty_node() {
  treeNode *node;
  if ((node = malloc(sizeof(*node))) == NULL)
    yyerror("out of memory");
  node->type = skipType;
  node->istp = 0; // 不具备结果类型
  return node;
}

void yyerror(char *s) {
  /* fprintf(stdout, "%s\n", s); */
  exit(100);
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

// 拷贝节点, 防止多个指针引用同一个地址
treeNode* copy(treeNode *t) {
  treeNode *node;
  return node;
}

treeNode *make_function_node(int index, treeNode *fn, treeNode *params, treeNode *body) {
  treeNode *node;
  if ((node = malloc(sizeof(*node))) == NULL)
    yyerror("out of memory");
  node->type = funcType;
  node->istp = 0; // 不属于结果类型, 但是具有类型
  node->tp = fn->tp; // 按照道理应该使用copy方法
  node->func.component[0] = params;
  node->func.component[1] = body;
  return sym[index] = node;
}

treeNode* make_param_node(int index, treeNode *tn) {
    treeNode *node;
    if ((node = malloc(sizeof(*node))) == NULL)
        yyerror("out of memory\n");
    node->type = paramType;
    node->tp = tn->tp; // 内存泄漏问题
    return sym[index] = node;
}

treeNode* make_params_node(treeNode *tn) {
    treeNode *node;
    if ((node = malloc(sizeof(*node))) == NULL)
        yyerror("out of memory\n");
    node->type = listType;
    node->list.size = 0;
    if (tn != NULL) {
      node->list.items[0] = tn;
      node->list.size++;
    }
    return node;
}


treeNode* add_param(treeNode *l, treeNode *p) {
    int *sz = &l->list.size;
    l->list.items[*sz] = p;
    (*sz)++;
    return l;
}

treeNode* make_call_node(int index, treeNode *arg) {
    treeNode *node;
    if ((node = malloc(sizeof(*node))) == NULL)
        yyerror("out of memory\n");
    node->type = callType;
    node->istp = 1;
    node->tp = sym[index]->tp;
    node->call.args = arg;
    node->call.fn = index;
    return node;
}

treeNode* make_expr_list(treeNode *tn) {
    treeNode *node;
    if ((node = malloc(sizeof(*node))) == NULL)
        yyerror("out of memory\n");
    node->type = listType;
    node->list.size = 0;
    if (tn != NULL) {
      node->list.items[0] = tn;
      node->list.size++;
    }
    return node;
}

treeNode* add_expr(treeNode *l, treeNode *e) {
    int *sz = &l->list.size;
    l->list.items[*sz] = e;
    (*sz)++;
    return l;
}

int main(void) {
  yyparse();
  return 0;
}

