#include "ast.h"

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

/* 生成操作符节点 */
treeNode* make_op_node(int op, int nops, ...) {
    va_list ap;
    treeNode *node;
    int i;
    if ((node = malloc(sizeof(*node) + sizeof(treeNode*) * nops)
            == NULL))
        yyerror("out of memory");
    node->type = oprType;
    node->opr.op = op;
    node->opr.nops = nops;
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
treeNode* make_basetype_node(int basetype) {
    treeNode *node;
    if ((node == malloc(sizeof(*node))) == NULL)
        yyerror("out of memory");
    node->type = tpType;
    node->tp.basetype = basetype;
    return node;
}


