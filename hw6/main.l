%option noyywrap
%{
    #include"common.h"
    #include"main.tab.hh"
    #include <stack>
    using namespace std;
    //为了实现作用域，必须存储作用域的结构，即哪个zone属于哪个zone 
    //zone栈，为了找父节点用 
    stack<int>zone_stack;

    extern action_zone zone[20];

    //从p节点向上找是否前面定义过标识符id
    int find_zone(int p,string id){
	    int i;
        while(p>=0){
        	for(i=0;i<zone[p].id_list.size();++i){
        		if(zone[p].id_list[i].name==id){
        			return p; 
				}
        	}
        	p=zone[p].father;
		}
		return -1;
	}
    void printer(string a,string b){
        return;
        cerr<<setw(8)<<a<<setw(8)<<b<<endl;
    }
    void printer(string a,string b,int c,string type){
        return;
        cerr<<setw(8)<<a<<setw(8)<<b<<setw(8)<<c<<setw(8)<<type<<endl;
    }
    int zone_cnt=0;//zone总数 
    int zone_now=0;//当前作用域 
    int zone_switch_flag=0;//是否需要切换作用域（一个id前面有没有int ） 

    bool init_stack=false;//栈初始化
    bool for_flag=false;//for的花括号不影响作用域，是一个特例

    int now_line=1;//当前行数

    string last_type;//最近遇到的type关键字，作为变量定义时的属性。
%}
BLOCKCOMMENT \/\*([^\*^\/]*|[\*^\/*]*|[^\**\/]*)*\*\/
LINECOMMENT \/\/[^\n]*

FLOAT_VAL [0-9]*\.[0-9]+
INT_VAL [0-9]+
ID [[:alpha:]_][[:alpha:][:digit:]_]*
CHAR_VAL \'.+\'
STRING_VAL \".+\"
EOL (\r\n|\n)
WHITE [\t ]
%%
{BLOCKCOMMENT} {cerr<<"COMMENT:"<<yytext<<endl;} /* do nothing */
{LINECOMMENT}  {cerr<<"COMMENT:"<<yytext<<endl;}/* do nothing */

"true" {
    TreeNode *node = new TreeNode(NODE_BOOL);//布尔型
    node->bool_val = true;
    yylval = node;
    node->lineno=now_line;//行号
    return TRUE;
}
"false" {
    TreeNode *node = new TreeNode(NODE_BOOL);
    node->bool_val = false;
    yylval = node;
    node->lineno=now_line;
    return FALSE;
}

"int" {
    if(init_stack==false){//初始化栈
        zone_stack.push(0);
        init_stack=true;
    }
    zone_switch_flag=1;//新定义了变量
    last_type="int";
    return INT;
}
"float" {
    if(init_stack==false){//初始化栈
        zone_stack.push(0);
        init_stack=true;
    }
    zone_switch_flag=1;//新定义了变量
    last_type="float";
    return FLOAT;
}
"void" {
    if(init_stack==false){
        zone_stack.push(0);
        init_stack=true;
    }
    zone_switch_flag=1;
    last_type="void";
    return VOID;
}
"char" {
    if(init_stack==false){
        zone_stack.push(0);
        init_stack=true;
    }
    zone_switch_flag=1;
    last_type="char";
    return CHAR;
}

"if" {
    return IF;
}
"while" {
    return WHILE;
}
"else" {
    return ELSE;
}
"for" {//注意for里面定义的i作用域变化
    for_flag=true;
    zone_cnt++;     //作用域总数++
    zone[zone_cnt].father=zone_now;     //设置父节点
    zone_now=zone_cnt;      //当遇到for，当前作用域必然是新的作用域
    zone_stack.push(zone_now);
    return FOR;
}
"return" {
    return RETURN;
}

"printf" {
    return PRINTF;
}
"scanf" {
    return SCANF;
}

"==" return EQUAL;
"=" {
    return ASSIGN;
}

"+" return ADD;
"-" return SUB;
"*" return MUL;
"/" return DIV;
"%" return MOD;
">" return LARGER;
"<" return SMALLER;
">=" return LARGER_EQUAL;
"<=" return SMALLER_EQUAL;
"!=" return NOT_EQUAL;
"&&" return AND;
"||" return OR;
"+=" {
    return ADD_SELF;
}
"-=" {
    return SUB_SELF;
}
"++" {
    return ADD_ONE;
}
"--" {
    return SUB_ONE;
}

"!" return NOT;

"&" return GET_ADDR;//取地址

"\"" {//遇到双引号，表明是string类型，但是右双引号怎么办？要计数器判断奇偶吗

    return QUOTA;
}
"," return COMMA;
";" {
    zone_switch_flag=0;
    return SEMICOLON;
}
"(" return LPAREN;
")" return RPAREN;
"{" {
    zone_switch_flag=0;
    if(for_flag==true){//如果在for后面，作用域不变
        return LBRACE;
    }
    zone_cnt++;     //作用域总数++
    zone[zone_cnt].father=zone_now;     //设置父节点
    zone_now=zone_cnt;      //当遇到左花括号，当前作用域必然是新的作用域
    zone_stack.push(zone_now);
    return LBRACE;
}
"}" {
    if(for_flag==true){
        for_flag=false;//结束for的作用域
    }
    zone_stack.pop();//遇到右括号，就从栈中pop掉一个zone
    zone_now=zone_stack.top();
    return RBRACE;
}

{STRING_VAL} {
    TreeNode *node = new TreeNode(NODE_CONST);
    node->string_val = yytext;
    node->varType=VAR_STRING;
    yylval = node;
    printer("STRING",yytext);
    node->lineno=now_line;
    return STRING_VAL;
}

{INT_VAL} {
    TreeNode *node = new TreeNode(NODE_CONST);
    node->int_val = atoi(yytext);
    node->varType=VAR_INTEGER;
    yylval = node;
    printer("INT",yytext);
    node->lineno=now_line;
    return INT_VAL;
}

{FLOAT_VAL} {
    TreeNode *node = new TreeNode(NODE_CONST);
    node->float_val = atof(yytext);
    node->varType=VAR_FLOAT;
    yylval = node;
    printer("FLOAT",yytext);
    node->lineno=now_line;
    return FLOAT_VAL;
}
{CHAR_VAL} {
    TreeNode* node = new TreeNode(NODE_CONST);
    //特别判断\n和\t
    string s=yytext;
    if(s[1]=='\\'&&s[2]=='t'){
        node->char_val=(char)9;
    }
    else if(s[1]=='\\'&&s[2]=='n'){
        node->char_val=(char)10;
    }
    else node->char_val = yytext[1];
    node->varType=VAR_CHAR;
    yylval = node;
    printer("INT",yytext);
    node->lineno=now_line;
    return CHAR_VAL;
}
{ID} {
    TreeNode *node = new TreeNode(NODE_VAR);
    node->var_name = string(yytext);
    yylval = node;

    if(zone_switch_flag==1){//如果前面有int，相当于新的id
        int i;
        for(i=0;i<zone[zone_now].id_list.size();++i){
            //如果当前作用域内已经定义过该变量，那么报错
            if(zone[zone_now].id_list[i].name==yytext){
                cerr<<"error,'"<<yytext<<"' has been declared in this zone"<<endl;
                break;
            }
        }
        //如果没定义过，成功创建新id，【加入当前作用域的符号表】
        if(i==zone[zone_now].id_list.size()){
            zone[zone_now].id_list.push_back(identifier(yytext,zone_now,last_type));
            printer("ID",yytext,zone_now,last_type);
            if(last_type=="int"){
                node->varType=VAR_INTEGER;
            }
            else if(last_type=="char"){
                node->varType=VAR_CHAR;
            }
            else if(last_type=="void"){
                node->varType=VAR_VOID;
            }
            else if(last_type=="float"){
                node->varType=VAR_FLOAT;
            }
            node->zone=zone_now;
        }
    }
    //如果前面没有type，向上找是不是定义过id
    else{
        int p=zone_now;
        int find_zone_result=find_zone(p,yytext);
        //如果找不到，未定义error
        if(find_zone_result==-1){ 
            cerr<<"error,'"<<yytext<<"' has not been declared"<<endl;
        }
        //找到了正确的作用域 
        else{
            p=find_zone_result;
            for(int i=0;i<zone[p].id_list.size();++i){
                if(zone[p].id_list[i].name==yytext){
                    identifier this_id=zone[p].id_list[i];
                    printer("ID",this_id.name,this_id.no,this_id.type);

                    node->zone=zone[p].id_list[i].no;
                    break;
                }
            }
        } 
    }
    node->lineno=now_line;
    return ID;
}
{EOL} {//换行
    now_line++;
}
{WHITE}


%%

