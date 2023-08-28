%{
#include <stdio.h>
#include <stdlib.h>
#include "ast.h"
%}

// 采用二进制表示Scope
// 0001->0011子域
%union {
   int val;
   treeNode *tree; 
}


%%

%%