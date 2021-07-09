%{
#include <stdio.h>
#include <ctype.h>
#include <math.h>

extern int yylex();
extern int yyparse();
extern FILE* yyin;
extern FILE* yyout;

void yyerror(const char* s);
%}

%union {
    int ival;
    char *sval;
    float fval;
}

%token COMMENT 401
%token OPENING_PAR 402
%token CLOSING_PAR 403
%token OPENING_BR 404
%token CLOSING_BR 405
%token OPENING_SBR 406
%token CLOSING_SBR 407
%token ASSIGN_OP 408
%token DOT 409
%token COMMA 410
%token SEMICOLON 411
%token COLON 412
%token INT 101
%token DOUBLE 102
%token STR 103
%token BOOL 104
%token VECTOR 105
%token BLOCK 106
%token TABLE 107
%token DATA_TYPE 501
%token IN 503
%token CONTINUE 504
%token BREAK 505
%token RETURN 506
%token FOR 507
%token WHILE 508
%token IF 509
%token THEN 510
%token ELSE 511
%token PRINT 512
%token LOAD 513
%token CONST 531
%token GT 108
%token LT 109
%token GE 110
%token LE 111
%token EQ 112
%token NE 113
%token RELAT_OP 514
%token ADD 114
%token SUB 115
%token MUL 116
%token DIV 117
%token POW 118
%token MOD 119
%token ARITME_OP 515
%token AND 120
%token OR 121
%token NOT 122
%token LOGICAL_OP 516
%token SIN 123
%token COS 124
%token TAN 125
%token CTG 126
%token SEC 127
%token CSC 128
%token ABS 129
%token FLOOR 130
%token CEIL 131
%token SQRT 132
%token LN 133
%token LOG 134
%token EULER 135
%token MATH_FUNC 517
%token ID 518
%token I_NUMBER 601
%token R_NUMBER 602
%token STRING 603
%token SIZE 519
%token ROWS 520
%token COLS 521
%token RANGE 522
%token RANGE_M 523
%token RANGE_V 524
%token VARIANCE 525
%token EXPECTED_VALUE 526
%token COVARIANCE 527
%token K 528
%token K_STAR 529
%token T 530

%type <ival> I_NUMBER
%type <sval> INT DOUBLE STR BOOL VECTOR BLOCK TABLE PRINT LOAD GT GE LT LE EQ 
%type <sval> NE ADD SUB MUL DIV POW MOD AND OR NOT SIN COS TAN CTG SEC CSC ABS
%type <sval> FLOOR CEIL SQRT LN LOG EULER ID STRING SIZE ROWS COLS RANGE RANGE_M 
%type <sval> RANGE_V VARIANCE EXPECTED_VALUE COVARIANCE K K_STAR T
%type <fval> R_NUMBER

%left '+' '-'
%left '*' '/'

%start block

%%
block: ifClause
        | forClause
        | whileClause
        | instruction
;

ifClause: IF OPENING_PAR expression CLOSING_PAR
         THEN OPENING_BR block CLOSING_BR
         (ELSE ( IF OPENING_PAR expression CLOSING_PAR)? )
         OPENING_BR block CLOSING_BR *
         {if ($3 == true) {
             $7
         } else if ($12 == true) {
             $15
         } else {
             $15
         }}
;
forClause: FOR OPENING_PAR DATA_TYPE names IN names CLOSING_BR OPENING_BR block CLOSING_BR;
{for (int i = 0; i < size($6); i++) {$9}}
for (int val in collection) {
    print(val);
}
whileClause: WHILE OOPENING_PAR expression CLOSING_PAR OPENING_BR block CLOSING_BR;
funcDeclaration: DATA_TYPE names OPENING_PAR (DATA_TYPE names COMMA) OPENING_BR block CLOSING_BR;
relatOp: EQ
        | NE
        | LT
        | LE
        | GT
        | GE
;
aritmOp: ADD 
        | SUB 
        | MUL
        | DIV
        | MOD
        | POW
;
logicalOp: AND
        | OR
;
binaryOp: relatOp
        | aritmOp
        | logicalOp
        | IN
;
unaryOp: SUB
        | ADD
        | NOT
        | /* empty */
; 
declaration: CONST? DATA_TYPE names (assignment)?;
assignment: names? ASSIGN_OP expression;
names: ID;
dataType: INT
        | DOUBLE
        | STR
        | BOOL
        | VECTOR
        | BLOCK
        | TABLE
;
text: STRING;
comment: COMMENT;
number: R_NUMBER
        | I_NUMBER
;
item: names
        | number 
        | BOOL
        | friedman
        | function
;
expression: expression binaryOp expression  {$$ = binary_operation($1, $2, $3);}
        | unaryOp expression                {$$ = unary_operation($1, $2);}
        | OPENING_BR expression CLOSING_BR
        | item
;
function: names OPENING_BR (((item | expression | text) COMMA?)+ | /*empty*/ ) CLOSING_BR
;
instruction: ( function
            | assignment
            | declaration
            | BREAK
            | CONTINUE
            | RETURN (item | text)?) SEMICOLON
;
index: I_NUMBER
    | /* empty */
;
friedman: names DOT (RANGE | RANGE_M | RANGE_V) OPENING_SBR index COLON index COLON index CLOSING_SBR;
%%

#include "lex.yy.c"

typedef struct parameter_list {
    char **elements;
} parameter_list;

void unary_operation(char* operation, void* first) {
    switch (operation) {
        case "+":
            return first;
            break;
        case "-":
            return -first;
            break;
        case "not":
            return !first;
            break;
    }
}

void binary_operation(void* first, char* operation, void* second) {
    switch (operation) {
        case "<":
            return first < second;
            break;
        case "<=":
            return first <= second;
            break;
        case ">":
            return first > second;
            break;
        case ">=":
            return first >= second;
            break;
        case "!=":
            return first != second;
            break;
        case "==":
            return first == second;
            break;
        case "+":
            return first + second;
            break;
        case "-":
            return first - second;
            break;
        case "*":
            return first * second;
            break;
        case "/":
            return first / second;
            break;
        case "%":
            return first % second;
            break;
        case "^":
            return first ^ second;
            break;
        case "and":
            return first && second;
            break;
        case "or"
            return first || second;
            break;
    }
}

void conditional(bool result) {
    
}

void execute_function(char* name, parameter_list parameters) {
    switch (name) {
        case "load":
            break;
        case "sin":
            
    }
}

void yyerror(const char* s) {
	fprintf(stderr, "Parse error: %s\n", s);
	exit(1);
}

int main(int argc, char* argv[]) {
    if (argc < 2) {
        perror("Not enough arguments.\n");
        exit(FAILURE);
    }

    id_table = new_symbol_table();
    number_table = new_symbol_table();
    string_table = new_symbol_table();

    FILE *input;
    FILE *output;

    input = fopen(argv[1], "r");
    if (!input) {
        perror("Could not read input file.\n");
        exit(FAILURE);
    }
    yyin = input;

    output = fopen("lex_analysis.out", "w");
    if (!output) {
        perror("Could not open output file.\n");
        exit(FAILURE);
    }
    yyout = output;

    do {
        yyparse();
    } while (!feof(yyin));
    
    fclose(yyin);

    fprintf(yyout, "\nSymbol table - ids\n");
    print_elements(id_table);
    fprintf(yyout, "\nSymbol table - numbers\n");
    print_elements(number_table);
    fprintf(yyout, "\nSymbol table - strings\n");
    print_elements(string_table);
    fclose(yyout);

    return 0;
}
