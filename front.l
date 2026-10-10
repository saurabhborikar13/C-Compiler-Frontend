%{
#include "front.tab.h"
#include <string.h>
#include <stdlib.h>
%}

%%
[ \t\r\n]+                  ;

"int"                       { return INT; }
"float"                     { return FLOAT; }
"if"                        { return IF; }
"else"                      { return ELSE; }
"while"                     { return WHILE; }

"=="                        { return EQ; }
"!="                        { return NE; }
"<="                        { return LE; }
">="                        { return GE; }
"<"                         { return LT; }
">"                         { return GT; }

"="                         { return ASSIGN; }
"+"                         { return PLUS; }
"-"                         { return MINUS; }
"*"                         { return MUL; }
"/"                         { return DIV; }

";"                         { return SEMI; }
","                         { return COMMA; }
"("                         { return LPAREN; }
")"                         { return RPAREN; }
"{"                         { return LBRACE; }
"}"                         { return RBRACE; }

[0-9]+"."[0-9]+             { yylval.str = strdup(yytext); return FLOATNUM; }
[0-9]+                      { yylval.str = strdup(yytext); return NUM; }
[a-zA-Z_][a-zA-Z0-9_]*      { yylval.str = strdup(yytext); return ID; }

.                           { fprintf(stderr, "Unknown character: %s\n", yytext); return yytext[0]; }
%%

int yywrap(void) { return 1; }
