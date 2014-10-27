// Tipo de itens na tabela de simbolos
#define 	OPT_variavelSimples 	0
#define 	OPT_ParametroFormal 	1
#define 	OPT_Procedimento 	2

#define		VARTIPO_INT 		0
#define		VARTIPO_CHAR		1
#define		VARTIPO_STRING		2
#define		VARTIPO_BOOLEAN		3

#define		PARAMTIPO_VALOR		0
#define 	PARAMTIPO_REFER		1

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
	int n_args;
	int* tiposParam;
	int* passagemParam;
}Simbolo;

// Insere atributo na tabela
ApontadorSimbolo insere(Simbolo simbolo, ApontadorSimbolo topo, int categoria);

// Retira simbolo da tabela
void retira(ApontadorSimbolo* topo, int index);

// Busca simbolo na tabela
ApontadorSimbolo busca(char* nome, ApontadorSimbolo topo);

void alterarNumeroArgumentos(ApontadorSimbolo procedure, int nArgumentos, int *vetorTipo, int *vetorPassagem);

// Imprime um simbolo
void imprimeSimbolo(ApontadorSimbolo a);

void imprimeTabela(ApontadorSimbolo topo);

// Imprime pilha
void imprime(ApontadorSimbolo topo);

// Seta as primeiras n_posicoes com um certo tipo
void setaTipo(ApontadorSimbolo, int, int);
