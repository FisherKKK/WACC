typedef enum { oprType, valueType, idType } treeType;
typedef enum { INTEGER, BOOLEAN, CHARACTER, STRING} valueType; // 尝试进行类型检查


// 常量/值节点
typedef struct {
    valueType vType; // 值类型
    union {
        int intval; // 存储整型数字
        char *sval; // 存储字符串
    };
} valNode;

// 标识符/变量节点
typedef struct idNode {
    valueType vt; // 变量类型
    int i; // 变量对应的id
} idNode;

// 运算符节点
typedef struct oprNode {
    int op; // 运算符
    int nops; // 操作数数目
    struct treeNode* children[]; // 操作符的操作数
} oprNode;


typedef struct treeNode {
    treeType type; // 节点类型
    union {
        idNode id; // 标识符
        valNode val; // 常量/值
        oprNode opr; // 操作符
    }
} treeNode;

