//definitions

%{
#include <stdio.h>  
#include <stdlib.h>
#include "ast.h"

// prototypes
treeNode* make_binop_node(treeNode* op, treeNode* left, treeNode* right);
treeNode* make_op_node(char* op);
treeNode* make_int_node(int val);
void free_tree(treeNode* t);
void visit(treeNode* t);
void yyerror(char* s);
int yylex();
%}

//declare parser traversal types
%union {
  int val;           // integer value
  treeNode* tree;    // tree node pointer
};

// declare parser token types
%token <val> INTEGER
%token PLUS
%token MINUS
%token OPEN_PARENTHESES
%token CLOSE_PARENTHESES

// decalre return types for parser rules
%type <tree> expr binaryOper

%%

// grammar rules

prog: prog expr  { printf("Parsing...\n"); visit($2); free_tree($2);}
      | // Empty Program
      ;

expr: INTEGER                                    { $$ = make_int_node($1); }
      | expr binaryOper expr                     { $$ = make_binop_node($2,$1,$3); }
      | OPEN_PARENTHESES expr CLOSE_PARENTHESES  { $$ = $2; }
      ;
  
binaryOper: PLUS     { $$ = make_op_node("PLUS"); }
            | MINUS  { $$ = make_op_node("MINUS"); }
            ;
  
%%

//subroutines
  
// create binary operator node
treeNode* make_binop_node(treeNode* op, treeNode* left, treeNode* right) {
  treeNode* t;
  
  // allocate memory for node
  if ((t = malloc(sizeof(treeNode))) == NULL){
    yyerror("out of memory");
  }
  
  t->nodeType = binopT;
  t->binop.op = op;
  t->binop.left = left;
  t->binop.right = right;
  
  return t;
  
}

// create operator node
treeNode* make_op_node(char* op) {
  treeNode* t;
  
  // allocate memory for node
  if ((t = malloc(sizeof(treeNode))) == NULL){
    yyerror("out of memory");
  }
  
  t->nodeType = opT;
  t->op.opstr = op;
  
  return t;
  
}

//create integer node
treeNode* make_int_node(int val) {
  treeNode* t;
  
  // allocate memory for node
  if ((t = malloc(sizeof(treeNode))) == NULL){
    yyerror("out of memory");
  }
  
  t->nodeType = intT;
  t->in.value = val;
  
  return t;
}

void free_tree(treeNode* t) {
  if(!t){return;}
  if(t->nodeType == binopT){
    free_tree(t->binop.left);
    free_tree(t->binop.right);
  }
  free(t);
  
}

void yyerror(char* s) {
  fprintf(stdout, "\n%s\n", s);
}

int main(void) {
  yyparse();
  return 0;
}


