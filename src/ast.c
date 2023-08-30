#include "ast.h"
#include "y.tab.h"

void print_indent(int);
int indent = 2; // 缩进

void visit(treeNode *node) {
    int i;
    if (!node) {
        printf("Null ptr encountered!\n");
        return;
    }

    switch (node->type) {
        case oprType: 
            print_indent(indent);
            printf("OP(%c):\n", node->opr.op);
            indent += 2;
            for (i = 0; i < node->opr.nops; i++)
                { visit(node->opr.children[i]); }
            indent -= 2;
            break;

        case valueType:
            print_indent(indent);
            printf("VALUE:\n");
            print_indent(indent + 2);
            switch (node->val.vType) {
                case INTEGER: printf("%d\n", node->val.intval); break;
                case BOOLEAN: printf("%s\n", node->val.intval ? "true" : "false"); break;
                case CHARACTER: printf("%c\n", node->val.intval); break;
                case STRING: printf("%s\n", node->val.sval); break;
            }
            break;
        
        case idType:
            print_indent(indent);
            printf("VAR(%d)\n", node->id.i);
            break;
        
        case tpType:
            print_indent(indent);
            printf("TYPE: \n");
            print_indent(indent + 2);
            printf("%d\n", node->tp.basetype);
            break;
    }
}

void print_indent(int indent) {
  int i;
  for(i=0; i<indent; i++){
    printf(" ");
  }
}

/*
typedef struct treeNode {
    treeType type; // 节点类型
    union {
        idNode id; // 标识符
        valNode val; // 常量/值
        oprNode opr; // 操作符
    };
} treeNode;
*/