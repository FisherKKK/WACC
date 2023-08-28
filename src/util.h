#include <string.h>
#include <stdlib.h>
#include <stdio.h>
// 将字符串处理为字符对应的ASCII, 主要处理转义字符
int convertchar(const char* s) {
    int len = strlen(s);
    if (len == 3) return s[1];
    if (len != 4) { exit(100); printf("char length error\n"); }
    switch (s[2]) {
        case '\\': return '\\';
        case '\'': return '\'';
        case '\"': return '\"';
        case '0':  return '\0';
        case 'b':  return '\b';
        case 't':  return '\t';
        case 'n':  return '\n';
        case 'f':  return '\f';
        case 'r':  return '\r';
    }
    return 0;
}

// 最简单的字符串Hash函数, 先不考虑碰撞的问题
unsigned int BKDHash(const char *s) {
    unsigned int seed = 131;
    unsigned int hash = 0;
    while (*s) {
        hash = hash * seed + (*s++);
    }
    return hash & 0x7FFFFFFF;
}
