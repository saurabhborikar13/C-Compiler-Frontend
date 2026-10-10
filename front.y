%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yylex(void);
void yyerror(const char *s);

#define TYPE_INT 1
#define TYPE_FLOAT 2

typedef struct {
    char name[50];
    int type;
} symbol;

symbol symtab[10];
int symcount = 0;
int current_type = TYPE_INT;
int temp_count = 0;
int label_count = 0;

char *new_temp(void) {
    char *t = malloc(20);
    if (!t) { perror("malloc"); exit(EXIT_FAILURE); }
    sprintf(t, "t%d", temp_count++);
    return t;
}

char *new_label(void) {
    char *l = malloc(20);
    if (!l) { perror("malloc"); exit(EXIT_FAILURE); }
    sprintf(l, "L%d", label_count++);
    return l;
}

void add_symbol(char *name, int type) {
    for (int i = 0; i < symcount; i++) {
        if (strcmp(symtab[i].name, name) == 0) {
            fprintf(stderr, "Error: variable '%s' declared more than once\n", name);
            exit(EXIT_FAILURE);
        }
    }

    if (symcount >= 10) {
        fprintf(stderr, "Error: maximum of 9 variables allowed\n");
        exit(EXIT_FAILURE);
    }

    strcpy(symtab[symcount].name, name);
    symtab[symcount].type = type;
    symcount++;
}

int get_type(char *name) {
    for (int i = 0; i < symcount; i++) {
        if (strcmp(symtab[i].name, name) == 0)
            return symtab[i].type;
    }

    fprintf(stderr, "Error: undeclared variable '%s'\n", name);
    exit(EXIT_FAILURE);
}

char *promote(char *place, int from, int to) {
    if (from == to)
        return strdup(place);

    char *t = new_temp();
    if (from == TYPE_INT && to == TYPE_FLOAT)
        printf("%s = (float)%s\n", t, place);
    else
        printf("%s = (int)%s\n", t, place);
    return t;
}
%}

%union {
    char *str;
    struct {
        char *place;
        int type;
    } expr_val;
}

%token <str> ID NUM FLOATNUM
%token INT FLOAT IF ELSE WHILE
%token PLUS MINUS MUL DIV ASSIGN
%token LT GT LE GE EQ NE
%token SEMI COMMA LPAREN RPAREN LBRACE RBRACE

%type <expr_val> expr condition
%type <str> M_LABEL if_header while_header

%left PLUS MINUS
%left MUL DIV
%right UMINUS UPLUS

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%%

program
    : declarations statements
    ;

declarations
    : declarations declaration
    |
    ;

declaration
    : datatype varlist SEMI
    ;

datatype
    : INT   { current_type = TYPE_INT; }
    | FLOAT { current_type = TYPE_FLOAT; }
    ;

varlist
    : ID
      { add_symbol($1, current_type); }
    | varlist COMMA ID
      { add_symbol($3, current_type); }
    ;

statements
    : statements statement
    |
    ;

M_LABEL
    : %empty
      {
          $$ = new_label();
          printf("%s:\n", $$);
      }
    ;

if_header
    : IF LPAREN condition RPAREN
      {
          $$ = new_label();
          printf("if !%s goto %s\n", $3.place, $$);
      }
    ;

while_header
    : WHILE M_LABEL LPAREN condition RPAREN
      {
          char *exit_lbl = new_label();
          $$ = malloc(50);
          if (!$$) { perror("malloc"); exit(EXIT_FAILURE); }
          sprintf($$, "%s %s", $2, exit_lbl);
          printf("if !%s goto %s\n", $4.place, exit_lbl);
      }
    ;

statement
    : ID ASSIGN expr SEMI
      {
          int lhs_type = get_type($1);
          char *rhs = promote($3.place, $3.type, lhs_type);
          printf("%s = %s\n", $1, rhs);
      }
    | while_header statement
      {
          char start_lbl[20], exit_lbl[20];
          sscanf($1, "%19s %19s", start_lbl, exit_lbl);
          printf("goto %s\n", start_lbl);
          printf("%s:\n", exit_lbl);
      }
    | if_header statement %prec LOWER_THAN_ELSE
      {
          printf("%s:\n", $1);
      }
    | if_header statement ELSE
      {
          $<str>$ = new_label();
          printf("goto %s\n", $<str>$);
          printf("%s:\n", $1);
      }
      statement
      {
          printf("%s:\n", $<str>4);
      }
    | LBRACE statements RBRACE
    | SEMI
    ;

condition
    : expr LT expr
      {
          int rt = ($1.type == TYPE_FLOAT || $3.type == TYPE_FLOAT) ? TYPE_FLOAT : TYPE_INT;
          char *a = promote($1.place, $1.type, rt);
          char *b = promote($3.place, $3.type, rt);
          $$.type = TYPE_INT;
          $$.place = new_temp();
          printf("%s = %s < %s\n", $$.place, a, b);
      }
    | expr GT expr
      {
          int rt = ($1.type == TYPE_FLOAT || $3.type == TYPE_FLOAT) ? TYPE_FLOAT : TYPE_INT;
          char *a = promote($1.place, $1.type, rt);
          char *b = promote($3.place, $3.type, rt);
          $$.type = TYPE_INT;
          $$.place = new_temp();
          printf("%s = %s > %s\n", $$.place, a, b);
      }
    | expr LE expr
      {
          int rt = ($1.type == TYPE_FLOAT || $3.type == TYPE_FLOAT) ? TYPE_FLOAT : TYPE_INT;
          char *a = promote($1.place, $1.type, rt);
          char *b = promote($3.place, $3.type, rt);
          $$.type = TYPE_INT;
          $$.place = new_temp();
          printf("%s = %s <= %s\n", $$.place, a, b);
      }
    | expr GE expr
      {
          int rt = ($1.type == TYPE_FLOAT || $3.type == TYPE_FLOAT) ? TYPE_FLOAT : TYPE_INT;
          char *a = promote($1.place, $1.type, rt);
          char *b = promote($3.place, $3.type, rt);
          $$.type = TYPE_INT;
          $$.place = new_temp();
          printf("%s = %s >= %s\n", $$.place, a, b);
      }
    | expr EQ expr
      {
          int rt = ($1.type == TYPE_FLOAT || $3.type == TYPE_FLOAT) ? TYPE_FLOAT : TYPE_INT;
          char *a = promote($1.place, $1.type, rt);
          char *b = promote($3.place, $3.type, rt);
          $$.type = TYPE_INT;
          $$.place = new_temp();
          printf("%s = %s == %s\n", $$.place, a, b);
      }
    | expr NE expr
      {
          int rt = ($1.type == TYPE_FLOAT || $3.type == TYPE_FLOAT) ? TYPE_FLOAT : TYPE_INT;
          char *a = promote($1.place, $1.type, rt);
          char *b = promote($3.place, $3.type, rt);
          $$.type = TYPE_INT;
          $$.place = new_temp();
          printf("%s = %s != %s\n", $$.place, a, b);
      }
    ;

expr
    : expr PLUS expr
      {
          $$.type = ($1.type == TYPE_FLOAT || $3.type == TYPE_FLOAT) ? TYPE_FLOAT : TYPE_INT;
          char *a = promote($1.place, $1.type, $$.type);
          char *b = promote($3.place, $3.type, $$.type);
          $$.place = new_temp();
          printf("%s = %s + %s\n", $$.place, a, b);
      }
    | expr MINUS expr
      {
          $$.type = ($1.type == TYPE_FLOAT || $3.type == TYPE_FLOAT) ? TYPE_FLOAT : TYPE_INT;
          char *a = promote($1.place, $1.type, $$.type);
          char *b = promote($3.place, $3.type, $$.type);
          $$.place = new_temp();
          printf("%s = %s - %s\n", $$.place, a, b);
      }
    | expr MUL expr
      {
          $$.type = ($1.type == TYPE_FLOAT || $3.type == TYPE_FLOAT) ? TYPE_FLOAT : TYPE_INT;
          char *a = promote($1.place, $1.type, $$.type);
          char *b = promote($3.place, $3.type, $$.type);
          $$.place = new_temp();
          printf("%s = %s * %s\n", $$.place, a, b);
      }
    | expr DIV expr
      {
          $$.type = ($1.type == TYPE_FLOAT || $3.type == TYPE_FLOAT) ? TYPE_FLOAT : TYPE_INT;
          char *a = promote($1.place, $1.type, $$.type);
          char *b = promote($3.place, $3.type, $$.type);
          $$.place = new_temp();
          printf("%s = %s / %s\n", $$.place, a, b);
      }
    | MINUS expr %prec UMINUS
      {
          $$.type = $2.type;
          $$.place = new_temp();
          printf("%s = -%s\n", $$.place, $2.place);
      }
    | PLUS expr %prec UPLUS
      {
          $$ = $2;
      }
    | ID
      {
          $$.place = strdup($1);
          $$.type = get_type($1);
      }
    | NUM
      {
          $$.place = strdup($1);
          $$.type = TYPE_INT;
      }
    | FLOATNUM
      {
          $$.place = strdup($1);
          $$.type = TYPE_FLOAT;
      }
    | LPAREN expr RPAREN
      {
          $$ = $2;
      }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Syntax error: %s\n", s);
}

int main(void) {
    printf("--- Generating Three-Address Code ---\n");
    if (yyparse() == 0)
        printf("--- TAC generation complete ---\n");
    return 0;
}
