%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>

    extern int yylineno;    
    extern int yycolumn;    

    void yyerror(const char *s);
    int yylex();

    int tempCount = 0;
    int labelCount = 0;
    // int status[100] = {0};

    // int curr=0;
    // int front=0;
    // int sep=-1;
    // char*ifprint[100];
    // char*expr[100]={NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL};
    // char*expr1[100]={NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL};
    char* newTemp() {
        char * temp = (char*)malloc(10 * sizeof(char));
        sprintf(temp, "t%d", tempCount++);
        return temp;
    }
    char* newLabel() {
        char * temp = (char*)malloc(10 * sizeof(char));
        sprintf(temp, "l%d", labelCount++);
        return temp;
    }
%}

%union {
    int num;
    double decimal;
    char *id;
    char *str;
    char *str1;
    char *str2;
    char *str3;
    char *str4;
    char *str5;
    char *str6;
    char character;
}

%token DEFINE INCLUDE IF ELSE OPERATOR DIRECTIVE LESSTHANEQUALTO GREATERTHANEQUALTO LESSTHAN GREATERTHAN NOTEQUALTO EQUALEQUALTO LOGICAL BOOLEAN LEFTSQUAREBRACE RIGHTSQUAREBRACE RETURN
%token ASSIGN SEMICOLON LPAREN RPAREN LBRACE RBRACE COMMA PLUS MINUS MUL DIV MOD SELFADD SELFDIVIDE SELFMULTIPLY SELFSUBTRACT INCREMENT DECREMENT

%token <num> NUMBER
%token <id> IDENTIFIER
%token <decimal> FLOAT
%token <str> STRING
%token <character> CHARACTER
%token <str1> DATATYPE

%type <id> expression
%type <id> T
%type <id> F
%type <id> assignment declaration if_statement
%type <str2> preprogram
%type <str3> preprogram1
%type <str4> cond
%type <str5> preprogram2
%type <str5> preprogram3

%%
program:
    | preprocessor_directives program
    | function_call program
    | statements program
    | function_dec program
    ;
cond:
    NUMBER {
    	char buffer[20];
        sprintf(buffer, "%d", $1);
        $$ = strdup(buffer);
    }

    | IDENTIFIER ASSIGN expression{
    	char*temp=newTemp();
    	printf("TAC: %s = %s\n", temp, $3);
    	printf("TAC: %s = %s\n", $1,temp);
    	$$=temp;
    }
    | IDENTIFIER{
    	char*temp=newTemp();
    	printf("TAC: %s = %s\n",temp,$1);
    	$$=temp;
    }
    | expression{
    	$$=$1;
    }
    | cond LESSTHAN cond {
    	char*t=(char*)malloc(100*sizeof(char));
    	sprintf(t,"%s < %s",$1,$3);
    	$$=t;
    }
    | cond GREATERTHAN cond{
    	char*t=(char*)malloc(100*sizeof(char));
    	sprintf(t,"%s > %s",$1,$3);
    	$$=t;
    }
    | cond LESSTHANEQUALTO cond{
    	char*t=(char*)malloc(100*sizeof(char));
    	sprintf(t,"%s <= %s",$1,$3);
    	$$=t;
    }
    | cond GREATERTHANEQUALTO cond{
    	char*t=(char*)malloc(100*sizeof(char));
    	sprintf(t,"%s >= %s",$1,$3);
    	$$=t;
    }
    | cond NOTEQUALTO cond{
    	char*t=(char*)malloc(100*sizeof(char));
    	sprintf(t,"%s != %s",$1,$3);
    	$$=t;
    }
    | cond EQUALEQUALTO cond{
    	char*t=(char*)malloc(100*sizeof(char));
    	sprintf(t,"%s == %s",$1,$3);
    	$$=t;
    }
    ;
function_call:
    IDENTIFIER LPAREN all_data_types RPAREN SEMICOLON
    ;
function_call1:
    IDENTIFIER LPAREN all_data_types RPAREN
all_data_types:
    | NUMBER all_data_types1
    | FLOAT all_data_types1
    | CHARACTER all_data_types1
    | STRING all_data_types1
    | BOOLEAN all_data_types1
    | IDENTIFIER all_data_types1
    | function_call1 all_data_types1
    ;
all_data_types1:
    | COMMA NUMBER all_data_types1
    | COMMA FLOAT all_data_types1
    | COMMA CHARACTER all_data_types1
    | COMMA STRING all_data_types1
    | COMMA BOOLEAN all_data_types1
    | COMMA IDENTIFIER all_data_types1
    | COMMA function_call1 all_data_types1
    ;
function_dec:
    DATATYPE IDENTIFIER LPAREN argument RPAREN LBRACE function_dec1 RBRACE
    ;
function_dec1:
    | statements function_dec1
    | function_call function_dec1
    ;
argument:
    | DATATYPE IDENTIFIER arg1
    ;
arg1:
    | COMMA DATATYPE IDENTIFIER arg1
    ;
preprocessor_directives:
    DEFINE IDENTIFIER NUMBER
    | INCLUDE DIRECTIVE
    ;
statements:
    | statements statement
    ;

statement:
    declaration
    | assignment
    | if_statement
    | function_call
    | ret SEMICOLON
    ;
ret:
    | RETURN BOOLEAN
    | RETURN NUMBER
    | RETURN FLOAT
    | RETURN CHARACTER
    | RETURN STRING
;

assignment:
    IDENTIFIER ASSIGN expression SEMICOLON {
        char temp[1000];
        printf("TAC: %s = %s\n", $1, $3);
    }
    | IDENTIFIER INCREMENT SEMICOLON {
        char *t = newTemp();
        printf("TAC: %s = %s + 1\n", t, $1);
        printf("TAC: %s = %s\n", $1, t);
    }
    | IDENTIFIER DECREMENT SEMICOLON {
        char *t = newTemp();
        printf("TAC: %s = %s - 1\n", t, $1);
        printf("TAC: %s = %s\n", $1, t);
    }
    ;

declaration:
    DATATYPE IDENTIFIER ASSIGN expression SEMICOLON {
        printf("TAC: %s = %s\n", $2, $4);
    }
    | DATATYPE IDENTIFIER SEMICOLON {
        printf("TAC: %s = 0\n", $2);
    }
    ;
preprogram:
	LPAREN expression RPAREN LBRACE {
		char*l1=newLabel();
		printf("TAC: if NOT %s goto %s\n",$2,l1);
		$$ = l1;
	};
preprogram1:
	preprogram statements RBRACE ELSE{
		char*l2=newLabel();
		printf("TAC: goto %s\n",l2);
		printf("%s:\n",$1);
		$$=l2;
	};
preprogram2:
	LPAREN cond RPAREN LBRACE {
		char*l1=newLabel();
		printf("TAC: if NOT %s goto %s\n",$2,l1);
		$$ = l1;
	};
preprogram3:
	preprogram2 statements RBRACE ELSE{
		char*l2=newLabel();
		printf("TAC: goto %s\n",l2);
		printf("%s:\n",$1);
		$$=l2;
	};
if_statement:
    IF preprogram1  LBRACE statements RBRACE {
        printf("%s:\n",$2);
       	
    }
    |IF preprogram3  LBRACE statements RBRACE {
        printf("%s:\n",$2);
       	
    }
    |IF preprogram statements RBRACE {
       printf("%s:\n",$2);
    }
    |IF preprogram2 statements RBRACE {
       printf("%s:\n",$2);
    }
    |IF preprogram1 if_statement{
        printf("%s:\n",$2);
       	
    }
    |IF preprogram3 if_statement{
        printf("%s:\n",$2);
       	
    }
    ;
expression:
    expression PLUS T {
        char *t = newTemp();
        char temp[1000];
        	
        printf("TAC: %s = %s + %s\n", t, $1, $3);
        $$ = t;
    }
    | expression MINUS T {
        char *t = newTemp();
       
        char temp[1000];
        printf("TAC: %s = %s - %s\n", t, $1, $3);
    
        $$ = t;
    }
    | T {
        $$ = $1;
    }
    ;

T:
    T MUL F {
        char *t = newTemp();
        char temp[1000];
        printf("TAC: %s = %s * %s\n", t, $1, $3);
        	
        $$ = t;
    }
    | T DIV F {
        char *t = newTemp();
        printf("TAC: %s = %s / %s\n", t, $1, $3);

        $$ = t;
    }
    | F {
        $$ = $1;
    }
    ;

F:
    IDENTIFIER {
        $$ = $1;
    }
    | NUMBER {
        char buffer[20];
        sprintf(buffer, "%d", $1);
        $$ = strdup(buffer);
    }
    | FLOAT {
        char buffer[20];
        sprintf(buffer, "%f", $1);
        $$ = strdup(buffer);
    }
    | STRING {
        $$ = strdup($1);
    }
    | CHARACTER {
        char buffer[5];
        sprintf(buffer, "'%c'", $1);
        $$ = strdup(buffer);
    }
    | LPAREN expression RPAREN {
        $$ = $2;
    }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Syntax error at line %d, column %d: %s\n", yylineno, yycolumn, s);
}

int main(void) {
    printf("Parsing Mini-C and generating TAC...\n");
    yyparse();
    return 0;
}