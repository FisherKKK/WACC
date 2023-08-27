typedef enum { binopT, opT, intT } treeType;

// operator node
typedef struct {
    char* opstr;    // operator name
} opNode;

// integer node
typedef struct {
    int value;  //value of integer
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

