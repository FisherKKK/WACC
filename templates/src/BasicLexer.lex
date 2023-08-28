  // definitions
%{
#include <stdlib.h>
#include "ast.h"
#include "y.tab.h"
void yyerror(char* s);

%}

digit [0-9]

%%

  // rules

{digit}+ {  
            yylval.val = atoi(yytext);
            return INTEGER;
         } 
  
"+"      return PLUS;
"-"      return MINUS;

"("      return OPEN_PARENTHESES;
")"      return CLOSE_PARENTHESES;

  /* anything else is an error */
.        yyerror("Unknown Character");

%%

  // subroutines

int yywrap(void) {
  return 1; // return 1 represent over
}


