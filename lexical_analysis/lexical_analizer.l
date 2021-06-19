%{
/* definitions of manifest constants */
#define COMMENT 401
#define OPENING_PAR 402
#define CLOSING_PAR 403
#define OPENING_BR 404
#define CLOSING_BR 405
#define OPENING_SBR 406
#define CLOSING_SBR 407
#define ASSIGN_OP 408
#define DOT 409
#define COMMA 410
#define SEMICOLON 411
#define INT 101
#define DOUBLE 102
#define STR 103
#define BOOL 104
#define VECTOR 105
#define BLOCK 106
#define TABLE 107
#define DATA_TYPE 501
#define FUNCTION 502
#define IN 503
#define CONTINUE 504
#define BREAK 505
#define RETURN 506
#define FOR 507
#define WHILE 508
#define IF 509
#define THEN 510
#define ELSE 511
#define PRINT 512
#define LOAD 513
#define GT 108
#define LT 109
#define GE 110
#define LE 111
#define EQ 112
#define NE 113
#define RELAT_OP 514
#define ADD 114
#define SUB 115
#define MUL 116
#define DIV 117
#define POW 118
#define MOD 119
#define ARITME_OP 515
#define AND 120
#define OR 121
#define NOT 122
#define LOGICAL_OP 516
#define SIN 123
#define COS 124
#define TAN 125
#define CTG 126
#define SEC 127
#define CSC 128
#define ABS 129
#define FLOOR 130
#define CEIL 131
#define SQRT 132
#define LN 133
#define LOG 134
#define EULER 135
#define MATH_FUNC 517
#define ID 518
#define I_NUMBER 601
#define R_NUMBER 602
#define STRING 603
#define SIZE 519
#define ROWS 520
#define COLS 521
#define RANGE 522
#define VARIANCE 523
#define EXPECTED_VALUE 524
#define COVARIANCE 525
#define K 526
#define K_STAR 527
#define T 528

/* required libraries */
#include <stdio.h>
#include <errno.h>
#include <string.h>

/* symbol tables - current position */
unsigned int current_tid = 0;
unsigned int current_tnum = 0;
unsigned int current_tstr = 0;

typedef struct symbol_table {
    char **elements;
    int capacity;
    int size;
} symbol_table;

#define INITIAL_CAPACITY 10
#define MAX_TOSTRING 1024
#define MAX_STRING_VALUE 32

symbol_table* new_symbol_table() {
    symbol_table *list = (symbol_table*) malloc(sizeof(symbol_table));
    list->elements = (char**) malloc(INITIAL_CAPACITY * sizeof(char*));
    list->capacity = INITIAL_CAPACITY;
    list->size = 0;
    return list;
}

void insert(symbol_table *table, int index, char* value) {
    if (index < 0 || index > table->size) {
        perror("Invalid index.\n");
        exit(EXIT_FAILURE);
    }
    if (table->size == table->capacity) {
        char **new_array = (char**) malloc(2 * table->capacity * sizeof(char*));
        for (int i = 0; i < table->size; i++) {
            new_array[i] = table->elements[i];
        }
        table->capacity *= 2;
        table->elements = new_array;
    }
    for (int i = table->size; i >= index; i--) {
        table->elements[i] = table->elements[i - 1];
    }
    table->elements[index] = value;
    table->size++;
}

void add_entry(symbol_table *table, char* value) {
    insert(table, table->size, value);
}

int find(symbol_table *table, char* element) {
    for (int i = 0; i < table->size; i++)
        if (strcmp(table->elements[i], element) == 0) {
            return i;
        }
    return -1;
}

void print_elements(symbol_table *table) {
   if (table->size == 0) {
        fprintf(yyout, "[]\n");
    } else {
        for (int i = 0; i < table->size; i++) {
            fprintf(yyout, "[%d] -> %s\n", i, table->elements[i]);
        }
    }
}

/* symbol tables for ids, numbers and strings */
symbol_table *id_table;
symbol_table *number_table;
symbol_table *string_table;
%}

/* regular definitions */
delim       [ \t\n]
ws          {delim}+
comment     \/\*[a-zA-Z0-9 \t\n]*\*\/
letter      [a-zA-Z]
digit       [0-9]
id          {letter}([_]|{letter}|{digit})*
integer     {digit}+
real        (({digit}+)|({digit}*\.{digit}+)([eE][-+]?{digit}+)?)
string      \"[^\n]*\"

%%

{ws}        {/* no action and no return */}
{comment}   {write_token(COMMENT); return COMMENT;}
"("         {write_token(OPENING_PAR); return OPENING_PAR;}
")"         {write_token(CLOSING_PAR); return CLOSING_PAR;}
"{"         {write_token(OPENING_BR); return OPENING_BR;}
"}"         {write_token(CLOSING_BR); return CLOSING_BR;}
"["         {write_token(OPENING_SBR); return OPENING_SBR;}
"]"         {write_token(CLOSING_SBR); return CLOSING_SBR;}
">"         {write_token(GT); return RELAT_OP;}
"<"         {write_token(LT); return RELAT_OP;}
">="        {write_token(GE); return RELAT_OP;}
"<="        {write_token(LE); return RELAT_OP;}
"=="        {write_token(EQ); return RELAT_OP;}
"!="        {write_token(NE); return RELAT_OP;}
"="         {write_token(ASSIGN_OP); return ASSIGN_OP;}
"."         {write_token(DOT); return DOT;}
","         {write_token(COMMA); return COMMA;}
";"         {write_token(SEMICOLON); return SEMICOLON;}
int         {write_token(INT); return DATA_TYPE;}
double      {write_token(DOUBLE); return DATA_TYPE;}
str         {write_token(STR); return DATA_TYPE;}
bool        {write_token(BOOL); return DATA_TYPE;}
vector      {write_token(VECTOR); return DATA_TYPE;}
block       {write_token(BLOCK); return DATA_TYPE;}
table       {write_token(TABLE); return DATA_TYPE;}
function    {write_token(FUNCTION); return FUNCTION;}
in          {write_token(IN); return IN;}
continue    {write_token(CONTINUE); return CONTINUE;}
break       {write_token(BREAK); return BREAK;}
return      {write_token(RETURN); return RETURN;}
for         {write_token(FOR); return FOR;}
while       {write_token(WHILE); return WHILE;}
if          {write_token(IF); return IF;}
then        {write_token(THEN); return THEN;}
else        {write_token(ELSE); return ELSE;}
print       {write_token(PRINT); return PRINT;}
load        {write_token(LOAD); return LOAD;}
"+"         {write_token(ADD); return ARITME_OP;}
"-"         {write_token(SUB); return ARITME_OP;}
"*"         {write_token(MUL); return ARITME_OP;}
"/"         {write_token(DIV); return ARITME_OP;}
"^"         {write_token(POW); return ARITME_OP;}
"%"         {write_token(MOD); return ARITME_OP;}
and         {write_token(AND); return LOGICAL_OP;}
or          {write_token(OR); return LOGICAL_OP;}
not         {write_token(NOT); return LOGICAL_OP;}
sin         {write_token(SIN); return MATH_FUNC;}
cos         {write_token(COS); return MATH_FUNC;}
tan         {write_token(TAN); return MATH_FUNC;}
ctg         {write_token(CTG); return MATH_FUNC;}
sec         {write_token(SEC); return MATH_FUNC;}
csc         {write_token(CSC); return MATH_FUNC;}
abs         {write_token(ABS); return MATH_FUNC;}
floor       {write_token(FLOOR); return MATH_FUNC;}
ceil        {write_token(CEIL); return MATH_FUNC;}
sqrt        {write_token(SQRT); return MATH_FUNC;}
ln          {write_token(LN); return MATH_FUNC;}
log         {write_token(LOG); return MATH_FUNC;}
euler       {write_token(EULER); return MATH_FUNC;}
size        {write_token(SIZE); return SIZE;}
rows        {write_token(ROWS); return ROWS;}
cols        {write_token(COLS); return COLS;}
range       {write_token(RANGE); return RANGE;}
var         {write_token(VARIANCE); return MATH_FUNC;}
ev          {write_token(EXPECTED_VALUE); return MATH_FUNC;}
cov         {write_token(COVARIANCE); return MATH_FUNC;}
k           {write_token(K); return MATH_FUNC;}
k_star      {write_token(K_STAR); return MATH_FUNC;}
t           {write_token(T); return MATH_FUNC;}
{id}        {install_id(); return ID;}
{integer}   {install_number(0); return I_NUMBER;}
{real}      {install_number(1); return R_NUMBER;}
{string}    {install_string(); return STRING;}

%%

/*
    yytext -> pointer to the beginning of the lexeme
    yyleng -> length of the lexeme found
    yylval -> shared variable with YACC, it holds the lexeme's attribute (simulate)
    TODO:
    -> Complete vocabulary and lexical categories with friedman's test
*/

/* code represents the token, entry represents the attr */
void write_token(int code) {
    switch (code) {
        case 401:
            fprintf(yyout, "<comment>\n");
            break;
        case 402:
            fprintf(yyout, "<'('>\n");
            break;
        case 403:
            fprintf(yyout, "<')'>\n");
            break;
        case 404:
            fprintf(yyout, "<'{'>\n");
            break;
        case 405:
            fprintf(yyout, "<'}'>\n");
            break;
        case 406:
            fprintf(yyout, "<'['>\n");
            break;
        case 407:
            fprintf(yyout, "<']'>\n");
            break;
        case 408:
            fprintf(yyout, "<'='>\n");
            break;
        case 409:
            fprintf(yyout, "<'.'>\n");
            break;
        case 410:
            fprintf(yyout, "<','>\n");
            break;
        case 411:
            fprintf(yyout, "<';'>\n");
            break;
        case 101:
        case 102:
        case 103:
        case 104:
        case 105:
        case 106:
        case 107:
            fprintf(yyout, "<data_type, %s>\n", yytext);
            break;
        case 502:
            fprintf(yyout, "<function>\n");
            break;
        case 503:
            fprintf(yyout, "<in>\n");
            break;
        case 504:
            fprintf(yyout, "<continue>\n");
            break;
        case 505:
            fprintf(yyout, "<break>\n");
            break;
        case 506:
            fprintf(yyout, "<return>\n");
            break;
        case 507:
            fprintf(yyout, "<for>\n");
            break;
        case 508:
            fprintf(yyout, "<while>\n");
            break;
        case 509:
            fprintf(yyout, "<if>\n");
            break;
        case 510:
            fprintf(yyout, "<then>\n");
            break;
        case 511:
            fprintf(yyout, "<else>\n");
            break;
        case 512:
            fprintf(yyout, "<print>\n");
            break;
        case 513:
            fprintf(yyout, "<load>\n");
            break;
        case 108:
        case 109:
        case 110:
        case 111:
        case 112:
        case 113:
            fprintf(yyout, "<relat_op, '%s'>\n", yytext);
            break;
        case 114:
        case 115:
        case 116:
        case 117:
        case 118:
        case 119:
            fprintf(yyout, "<aritme_op, '%s'>\n", yytext);
            break;
        case 120:
        case 121:
        case 122:
            fprintf(yyout, "<logical_op, '%s'>\n", yytext);
            break;
        case 123:
        case 124:
        case 125:
        case 126:
        case 127:
        case 128:
        case 129:
        case 130:
        case 131:
        case 132:
        case 133:
        case 134:
        case 135:
        case 523:
        case 524:
        case 525:
        case 526:
        case 527:
        case 528:
            fprintf(yyout, "<math_func, '%s'>\n", yytext);
            break;
        case 519:
            fprintf(yyout, "<size>\n");
            break;
        case 520:
            fprintf(yyout, "<rows>\n");
            break;
        case 521:
            fprintf(yyout, "<cols>\n");
            break;
        case 522:
            fprintf(yyout, "<range>\n");
            break;
        default:
            perror("Code not recognized\n");
            exit(EXIT_FAILURE);
    }
}

char* get_lexeme() {
    char *result = malloc(yyleng);
    for (int i = 0; i < yyleng; i++) {
        result[i] = yytext[i];
    }
    return result;
}

/* function for install an id token in the symbol table */
int install_id() {
    char* lexeme = get_lexeme();
    int find_lexeme = find(id_table, lexeme);
    if (find_lexeme != -1) {
        fprintf(yyout, "<id, %d>\n", find_lexeme);
        return find_lexeme;
    }
    add_entry(id_table, lexeme);
    fprintf(yyout, "<id, %d>\n", current_tid);
    current_tid++;
    return current_tid - 1;
}

/* function for install a number token in the symbol table */
int install_number(int type) {
    char* lexeme = get_lexeme();
    int find_lexeme = find(number_table, lexeme);
    if (find_lexeme != -1) {
        if (type == 0) {
            fprintf(yyout, "<i_number, %d>\n", find_lexeme);
        } else {
            fprintf(yyout, "<r_number, %d>\n", find_lexeme);
        }
        return find_lexeme;
    }
    add_entry(number_table, lexeme);
    if (type == 0) {
        fprintf(yyout, "<i_number, %d>\n", current_tnum);
    } else {
        fprintf(yyout, "<r_number, %d>\n", current_tnum);
    }
    current_tnum++;
    return current_tnum - 1;
}

/* function for install a string token in the symbol table */
int install_string() {
    char* lexeme = get_lexeme();
    int find_lexeme = find(string_table, lexeme);
    if (find_lexeme != -1) {
        fprintf(yyout, "<string, %d>\n", find_lexeme);
        return find_lexeme;
    }
    add_entry(string_table, lexeme);
    fprintf(yyout, "<string, %d>\n", current_tstr);
    current_tstr++;
    return current_tstr - 1;
}

/*
    main function:
    -> open input & output files (if an error arise it stops
    the program execution)
    -> call the function yylex() to start lexical analysis
    -> close input & output streams
*/
int main(int argc, char* argv[]) {
    /*if (argc < 2) {
        perror("Not enough arguments.\n");
        exit(EXIT_FAILURE);
    }*/

    id_table = new_symbol_table();
    number_table = new_symbol_table();
    string_table = new_symbol_table();

    FILE *input;
    FILE *output;

    input = fopen("program.txt", "r");
    if (!input) {
        perror("Could not read input file.\n");
        exit(EXIT_FAILURE);
    }
    yyin = input;

    output = fopen("lex_analysis.out", "w");
    if (!output) {
        perror("Could not open output file.\n");
        exit(EXIT_FAILURE);
    }
    yyout = output;

    while (yylex()) {}
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