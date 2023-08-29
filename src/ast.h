#include <stdlib.h>
#include <stdarg.h>
#define MAXN 10000

typedef enum { oprType, valueType, idType,  tpType} treeType;
typedef enum { INTEGER, BOOLEAN, CHARACTER, STRING} literType; // 尝试进行类型检查


// 常量/值节点
typedef struct {
    literType vType; // 值类型
    union {
        int intval; // 存储整型数字
        char *sval; // 存储字符串
    };
} valNode;

// 标识符/变量节点
typedef struct idNode {
    treeNode *vt; // 变量类型
    int i; // 变量对应的id
} idNode;

// 运算符节点
typedef struct oprNode {
    int op; // 运算符
    int nops; // 操作数数目
    struct treeNode* children[]; // 操作符的操作数
} oprNode;


// 类型节点
typedef struct typeNode {
    union {
        int basetype;
        treeNode *complextype;
    };
} typeNode;

typedef struct treeNode {
    treeType type; // 节点类型
    union {
        idNode id; // 标识符
        valNode val; // 常量/值
        oprNode opr; // 操作符
        typeNode tp; // 变量类型
    };
} treeNode;

// valNode sym[MAXN]; // 符号表
treeNode *sym[MAXN]; // 符号表

void yyerror(char*);
treeNode* make_op_node(int op, int nops, ...);
treeNode* index2node(treeNode* type, int index);
treeNode* make_basetype_node(int basetype);

