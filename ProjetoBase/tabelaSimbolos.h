// Tipo de itens na tabela de simbolos
#define 	OPT_variavelSimples 	0
#define 	OPT_ParametroFormal 	1
#define 	OPT_Procedimento 	2

typedef struct Simbolo* ApontadorSimbolo;

typedef struct Simbolo {
	// Simbolo informacoes
	ApontadorSimbolo proximo;
	int categoria;
	// Geral
	char* identificador;
	int nivel;
	int tipo;
	int deslocamento;
	// Parametro formal
	int passagem;
	// Procedimento
	char* rotulo;
	int n;
	int* tiposParam;
	int* passagemParam;
}Simbolo;

// Insere atributo na tabela
ApontadorSimbolo insere(Simbolo simbolo, ApontadorSimbolo topo, int categoria);

// Retira simbolo da tabela
void retira(ApontadorSimbolo* topo, int index);

// Busca simbolo na tabela
ApontadorSimbolo busca(char* nome, ApontadorSimbolo topo);

// Imprime um simbolo
void imprimeSimbolo(ApontadorSimbolo a);

// Imprime pilha
void imprime(ApontadorSimbolo topo);
