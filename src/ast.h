#ifndef __AST_H
#define __AST_H
#include <stdlib.h>
#include <stdarg.h>
#include <stdio.h>
#define MAXN 10000

typedef enum { oprType, valueType, idType,  tpType, skipType, funcType, paramType, listType, callType} treeType;
typedef enum { INTEGER, BOOLEAN, CHARACTER, STRING, TYPEKIND} literType; // 尝试进行类型检查


// 常量/值节点
typedef struct valNode {
    literType vType; // 值类型
    union {
        int intval; // 存储整型数字
        char *sval; // 存储字符串
    };
} valNode;

// 标识符/变量节点
typedef struct idNode {
    int i; // 变量对应的id
    int scope; // 变量作用域
} idNode;

// 运算符节点
typedef struct oprNode {
    int op; // 运算符
    int nops; // 操作数数目
    struct treeNode* children[]; // 操作符的操作数
} oprNode;

// call节点
typedef struct callNode {
    int fn;
    struct treeNode *args;
} callNode;


// 类型节点
typedef struct typeNode {
    int isbase; // 0-complex 1-base
    union {
        int basetype;
        struct treeNode *complextype;
    };
} typeNode;

typedef struct funcNode {
    struct treeNode* component[2]; // 参数列表, 函数体
} funcNode;

typedef struct listNode {
    int size;
    struct treeNode* items[1000]; // 先固定大小, 可以链表优化
} listNode;

typedef struct treeNode {
    treeType type; // 节点类型
    typeNode tp; // 节点所属的变量类型
    int istp; // 节点是否具有变量类型, 例如if没有, 但是 = >存在
    union {
        idNode id; // 标识符
        valNode val; // 常量/值
        oprNode opr; // 操作符
        funcNode func;
        listNode list;
        callNode call;
    };
} treeNode;
#endif

