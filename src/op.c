// c语言测试文件
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
typedef struct {
    int size;
    char* x[2];
} mulValue;

int main() {
    mulValue *p = malloc(sizeof(mulValue) + sizeof(char*) * 2);
    p->x[0] = "hello";
    p->x[1] = "dasdad";
    p->x[2] = "wwww";
    p->x[3] = "ccccc";
    p->x[4] = "world";
    p->x[5] = "wdada";
    for (int i = 0; i < 6; i++) {
        printf("%s\n", p->x[i]);
    }
    free(p);
    return 0;
}