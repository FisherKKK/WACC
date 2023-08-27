#include <stdio.h>
#include "ast.h"
#include "y.tab.h"

void print_indent(int indent);
int indent = 2;

// basic tree visitor (prints tree representation)
void visit(treeNode* t) {

  if(!t){
    printf("Null ptr encountered!");
    return;
  }

  switch(t->nodeType){
    case opT:  print_indent(indent);
               printf("OP(%s)\n", t->op.opstr);
               break;

    case intT: print_indent(indent);
               printf("INT(%d)\n", t->in.value);
               break;

    case binopT: print_indent(indent);
                 printf("BINOP:\n");
                 indent += 2;
                 visit(t->binop.op);
                 visit(t->binop.left);
                 visit(t->binop.right);
                 indent -= 2;
                 break;

    default: printf("Unexpected Case! \n");
  }

}

// printing helper
void print_indent(int indent) {
  for(int i=0; i<indent; i++){
    printf(" ");
  }
}
