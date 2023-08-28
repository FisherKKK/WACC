%{
#include <stdio.h>
#include <stdlib.h>
#include "ast.h"
#define MAXN 10000

valStorage sym[MAXN];
%}

// 采用二进制表示Scope
// 0001->0011子域
%union {
    int index;
    valStorage val;
    treeNode *tree; 
}


%%

%%