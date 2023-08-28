typedef enum { binopT, opT, intT } treeType;
typedef enum { INTEGER, BOOLEAN, CHARACTER, STRING} valueType; // 尝试进行类型检查


// 实际存储的值
typedef struct {
    valueType vType; // 值类型
    union {
        int intval; // 存储整型数字
        char *sval; // 存储字符串
    };
} valStorage;


// operator node
typedef struct {
    char* opstr;    // operator name
} opNode;

// integer node
typedef struct {
    int value;  // value of integer
} intNode;

// binary operator node
typedef struct {
    struct treeNode* op;       // operator node
    struct treeNode* left;     // left subtree
    struct treeNode* right;    // right subtree
} binopNode;

// general tree node wrapper
typedef struct treeNode {
    treeType nodeType;      // type of node
    union {
        binopNode binop;    // binary operator
        opNode op;          // operators
        intNode in;         // integers
    };  
} treeNode;

