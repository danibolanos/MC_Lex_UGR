	/*----- Sección de Declaraciones --------------*/
%{
#include <stdio.h>
#include <string.h>
#include <stdbool.h>
#include <math.h>

//Constantes

#define BOLETOS 30					//Máx. Boletos del fichero
#define ADMINISTRACIONES 5			//Máx. Administraciones del fichero
#define PARTICIPANTES 10			//Máx. Participantes del fichero
#define STRINGS 40					//Letras del string

//premios contiene los premios del sorteo tipo etiq_premio numeros_premiados
//boletos contiene todos los boletos vendidos en cada Administracion registrada por ID
//struct Administracion contiene los datos de una Administracion de venta de boletos
//struct Participante contiene los datos de un Participante DNI y boletos comprados

struct Administracion {
   int id;
	int tlf;
	int 	boletos[BOLETOS];
   char  nombre[STRINGS];
   char  ciudad[STRINGS];
   char  direccion[STRINGS];
	char  url[STRINGS];
};

struct Participante {
	int boletos[BOLETOS];
	char dni[10];
};

char *numerito;		//Temporales
int *premios, *boletos_vendidos, *boletos_comprados;
struct Administracion vector_admin[ADMINISTRACIONES];
struct Participante vector_part[PARTICIPANTES];

int inicio, final;	//Auxiliares
int k, modo, tam_vec[5];

//FUNCIONES

//Funciones estadísticas
int mostrar_premiados (struct Participante p, int *premios, int s, int premio);
int es_premiado (int *v, int s, int numero);
int ranking_ciudades (struct Administracion a, int *premios, int s, int premio);

//Funciones auxiliares
void escribir_datos (int *v, int s);
void escribir_datos_int (int *v, int i, int f);
void obtener_intervalos(int *v, int etiq, int s, int *i, int *f, int cifra);
void obtener_premios(int *v, int premio, int s, int *i, int *f);
void imprime_administraciones(struct Administracion * v);
void imprime_participantes(struct Participante * v);
%}

letra [a-zA-Z|\ñ]
letraM [ABCDEFGHJKLMNPQRSTVWXYZ]
digito [0-9]

numero_loteria {digito}{digito}{digito}{digito}{digito}
id {digito}{digito}{digito}{digito}{digito}{digito}
start [\t ]
end	[\n\t ]
https (?:https\:\/\/)
http (?:http\:\/\/)
www (?:www\.)
dni {digito}{digito}{digito}{digito}{digito}{digito}{digito}{digito}{letraM}
telefono (9){digito}({digito}|""){digito}{digito}{digito}{digito}{digito}{digito}

premios1 {start}{numero_loteria}{end}
premios2 ^{numero_loteria}{end}
tipo_premio ([1-5]"ºpremio")
identificador1 {start}{id}{end}
identificador2 ^{id}{end}
nombre_administracion ("Adm\."|"Administracion")(" "|{letra})+({end}|\.)
ciudad ({letra})+(\,|\," ")({letra})+({end}|\.)
direccion ("C/"|"Calle"|"Av\."|"Avenida"|"Plaza"|"Plz.")(" "|{letra})+({end}|\.)
url ({https}|{http}|{www})?([a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(?:\??)[a-zA-Z0-9\-\._\?\,\'\/\\\+&%\$#\=~]+)
num_ven1 {start}(\-){numero_loteria}(\-){end}
num_ven2 ^(\-){numero_loteria}(\-){end}
dni1 {start}{dni}{end}
dni2 ^{dni}{end}
jugados1 {start}(\+){numero_loteria}(\+){end}
jugados2 ^(\+){numero_loteria}(\+){end}
num_tlf1 {start}{telefono}{end}
num_tlf2 ^{telefono}{end}

%%
	/*----- Sección de Reglas ----------------*/

{tipo_premio} { numerito = yytext;
					 if(strcmp(numerito, "1ºpremio")==0){
						premios[tam_vec[0]]=-1;
						++tam_vec[0];
					 }		
					 else if(strcmp(numerito, "2ºpremio")==0){
						premios[tam_vec[0]]=-2;
						++tam_vec[0];
					 }		
					 else if(strcmp(numerito, "3ºpremio")==0){
						premios[tam_vec[0]]=-3;
						++tam_vec[0];
					 }						
					 else if(strcmp(numerito, "4ºpremio")==0){
						premios[tam_vec[0]]=-4;
						++tam_vec[0];
					 }						
					 else{
						premios[tam_vec[0]]=-5;
						++tam_vec[0];
					 }										
}

{premios1} { numerito = yytext;		  
					  premios[tam_vec[0]]=atoi(numerito);
					  ++tam_vec[0];
}

{premios2} { numerito = yytext; 
					  premios[tam_vec[0]]=atoi(numerito);
					  ++tam_vec[0];
}

{identificador1} { numerito = yytext;
						boletos_vendidos[tam_vec[1]]=atoi(numerito);
						vector_admin[tam_vec[2]].id=atoi(numerito);
						++tam_vec[1];
}

{identificador2} { numerito = yytext;
						boletos_vendidos[tam_vec[1]]=atoi(numerito);
						vector_admin[tam_vec[2]].id=atoi(numerito);
						++tam_vec[1];
}

{nombre_administracion} { strcpy(vector_admin[tam_vec[2]].nombre, yytext); }

{ciudad} { strcpy(vector_admin[tam_vec[2]].ciudad, yytext); }

{direccion} { strcpy(vector_admin[tam_vec[2]].direccion, yytext); }

{num_tlf1} { numerito = yytext;
				 vector_admin[tam_vec[2]].tlf=atoi(numerito);
}

{num_tlf2} { numerito = yytext;
				 vector_admin[tam_vec[2]].tlf=atoi(numerito);
}

{url} { strcpy(vector_admin[tam_vec[2]].url, yytext); ++tam_vec[2]; }

{num_ven1} { numerito = yytext;  
				 boletos_vendidos[tam_vec[1]]=abs(atoi(numerito));
				 ++tam_vec[1];
}

{num_ven2} { numerito = yytext; 
				 boletos_vendidos[tam_vec[1]]=abs(atoi(numerito));
				 ++tam_vec[1];
}

{dni1} { numerito = yytext;	
			strcpy(vector_part[tam_vec[3]].dni, yytext);
			boletos_comprados[tam_vec[4]]=atoi(numerito);
			++tam_vec[3]; ++tam_vec[4];
}

{dni2} { numerito = yytext;	
			strcpy(vector_part[tam_vec[3]].dni, yytext);
			boletos_comprados[tam_vec[4]]=atoi(numerito);
			++tam_vec[3]; ++tam_vec[4];
}

{jugados1} { numerito = yytext;  
				 boletos_comprados[tam_vec[4]]=abs(atoi(numerito));
				 ++tam_vec[4];
}

{jugados2} { numerito = yytext;  
				 boletos_comprados[tam_vec[4]]=abs(atoi(numerito));
				 ++tam_vec[4];
}

\n {}

.	{}

%%
	/*----- Sección de Procedimientos --------*/
int main (int argc, char *argv[]) {
	if (argc == 2) {
		yyin = fopen (argv[1], "rt");
		if (yyin == NULL) {
			printf ("El fichero %s no se puede abrir\n", argv[1]);
			exit (-1);
		}
	}
	else yyin = stdin;
//--------------------------------------------------

	for(int i=0; i < 6; i++)
		tam_vec[i]=0;

	premios = (int*)malloc(BOLETOS*sizeof(int));								//Reservo los boletos vendidos, en principio
   if (premios==NULL){
      perror("Problemas reservando memoria");
		return 1;
	}
	boletos_vendidos = (int*)malloc(BOLETOS*sizeof(int));					//Reservo los boletos vendidos
   if (boletos_vendidos==NULL){
      perror("Problemas reservando memoria");
		return 1;
	}
	boletos_comprados = (int*)malloc(BOLETOS*sizeof(int));				//Reservo los boletos comprados
   if (boletos_comprados==NULL){
      perror("Problemas reservando memoria");
		return 1;
	}

	yylex ();																			//Aplico el procesamiento del A. Léxico
	
	inicio=0;
	final=0;
	
	k=0;

	//Adjudicar boletos a su Administración correspondiente
	for(int i=0; i < ADMINISTRACIONES; i++){
		k=0;
		obtener_intervalos(boletos_vendidos, vector_admin[i].id, BOLETOS, &inicio, &final, 100000);
		for(int j=inicio; j < final; j++){
			vector_admin[i].boletos[k] = boletos_vendidos[j];
			k++;
		}
	}

	inicio=0;
	final=0;

	//Adjudicar boletos a su comprador correspondiente
	for(int i=0; i < PARTICIPANTES; i++){
		k=0;
		obtener_intervalos(boletos_comprados, atoi(vector_part[i].dni), BOLETOS, &inicio, &final, 100000);
		for(int j=inicio; j < final; j++){
			vector_part[i].boletos[k] = boletos_comprados[j];
			k++;
		}
	}

	//Una vez que hemos leido los premios, compradores y administraciones...
	//Podemos hacer un estudio de lo que queramos.

	modo=0;

	printf("\nSELECCIONA UNA DE LAS OPCIONES: \n");
	printf("\n1. Participantes desde fichero premiados. \n");
	printf("\n2. Ranking de Administraciones que más premios han vendido. \n");
	printf("\n3. Detector de boletos premiados. \n");
	printf("\nEn otro caso, muestra los datos de todas las Administraciones registradas. \n");

	printf("\nIntroduzca el número de su selección: "); //Solicitando al usuario que ingrese un numero
	scanf("%d",&modo); //Leyendo el número solicitado

	switch(modo){

	case 1:

	//Participantes que han sido premiados
	printf ("\n-----------------------------------------\n");
	printf("\nPARTICIPANTES DEL FICHERO PREMIADOS\n");

	for(int j=0; j < PARTICIPANTES; j++){
		int premiado=0;
		printf("\n*El participante con DNI %s", vector_part[j].dni);
		for(int i=1; i < 6; i++)
			premiado += mostrar_premiados (vector_part[j], premios, tam_vec[0], i);
		if(premiado==5)
			printf("\nNo ha sido premiado :-(\n");
	}

	break;

	case 2:

	//Ranking de ciudades que han vendido más premios
	
	printf ("\n-----------------------------------------\n");
	printf("\nRANKING CIUDADES CON MÁS PREMIOS\n");

	for(int j=0; j < ADMINISTRACIONES; j++){
		int premiado=0;
		printf("\nLa localidad %s", vector_admin[j].ciudad);
		for(int i=1; i < 6; i++)
			premiado += ranking_ciudades (vector_admin[j], premios, tam_vec[0], i);
		printf("\nEn total ha vendido %d premios\n", premiado);
		printf ("\n       ---------------      \n");
	}

	break;

	case 3:

	//Detector de números premiados
	printf ("\n-----------------------------------------\n");
	printf("\nDETECTOR DE BOLETOS PREMIADOS\n");

	int numero_comprado;
	int tipo_premio;
	printf("\nIngrese un numero válido del sorteo: "); 			//Solicitando al usuario que ingrese un numero
	scanf("%d",&numero_comprado); 										//Leyendo el número solicitado

	tipo_premio=es_premiado(premios, tam_vec[0], numero_comprado);

	if(tipo_premio==0)
		printf("\nEl número %d no ha sido premiado :-(\n", numero_comprado);
	else
		printf("\nEl número %d ha sido premiado con un %dº premio.\n", numero_comprado, tipo_premio);

	break;

	default:

	//Imprime por pantalla los datos de las Administraciones leidas desde fichero
	printf ("\n-----------------------------------------\n");
	printf("\nDATOS ADMINISTRACIONES\n");

	imprime_administraciones(vector_admin);

	break;

	}

	free(boletos_vendidos);
	free(boletos_comprados);
	free(premios);
	return 0;
}

//FUNCIONES

//Muestra el DNI de los participantes premiados y su premio
int mostrar_premiados (struct Participante p, int *premios, int s, int premio){
	int inicio=0;
	int final=0;
	int no_premiado=1;
	bool cont=true;
	obtener_premios(premios, premio, s, &inicio, &final);

	for(int j=0; j < BOLETOS && cont; j++){
		for(int i=inicio; i < final && cont; i++){
			if(p.boletos[j]==0)
				cont=false;
			else if(premios[i]==p.boletos[j]){
				printf("\nHa sido premiado con %dº premio al boleto %d\n", premio, p.boletos[j]); 
				no_premiado = 0;
			}
		}
	}
	return no_premiado;
}

//Muestra un ranking de ciudades con mejores premios vendidos
int ranking_ciudades (struct Administracion a, int *premios, int s, int premio){
	int inicio=0;
	int final=0;
	bool cont=true;
	int premiado=0;
	obtener_premios(premios, premio, s, &inicio, &final);

	for(int j=0; j < BOLETOS && cont; j++){
		for(int i=inicio; i < final && cont; i++){
			if(a.boletos[j]==0)
				cont=false;
			else if(premios[i]==a.boletos[j]){
				printf("\nHa vendido el boleto %d con %dº premio\n", a.boletos[j], premio); 
				premiado = 1;
			}
		}
	}
	return premiado;	
}

//Devuelve el premio adjudicado al boleto pasado como argumento
int es_premiado (int *v, int s, int numero){
	int premio=0, inicio = 0, final = 0;
	bool sigue=true;
	for(int i=1; i < 6 && sigue; i++){
		obtener_premios(v, i, s, &inicio, &final);
		for(int j=inicio; j < final && sigue; j++){
			if(v[j] == numero){
				premio=i;
				sigue=false;
			}
		}
	}
	return premio;		
}

//Imprime los valores de las Administraciones
void imprime_administraciones(struct Administracion * v){
	for(int j=0; j < ADMINISTRACIONES; j++){
		bool cont=true;
		printf ("\nADMINISTRACION %d\n", j);
		printf ("\nId_admin: %d\n", v[j].id);
		printf ("\nNombre: %s\n", v[j].nombre);
		printf ("\nCiudad: %s\n", v[j].ciudad);
		printf ("\nDireccion: %s\n", v[j].direccion);
		printf ("\nTelefono Fijo: %d\n", v[j].tlf);
		printf ("\nUrl: %s\n", v[j].url);
		printf("\nBoletos vendidos: ");
		for(int i=0; i < BOLETOS && cont; i++){
			if(v[j].boletos[i]!=0)
				printf ("\n%d\n", v[j].boletos[i]);
			else
				cont = false;
		}
		printf ("\n-----------------------------------------\n");
	}
}

//Imprime los valores de los Participantes
void imprime_participantes(struct Participante * v){
	for(int j=0; j < PARTICIPANTES; j++){
		bool cont=true;
		printf ("\nPARTICIPANTES %d\n", j);
		printf ("\nDNI: %s\n", v[j].dni);
		printf("\nBoletos comprados: ");
		for(int i=0; i < BOLETOS && cont; i++){
			if(v[j].boletos[i]!=0)
				printf ("\n%d\n", v[j].boletos[i]);
			else
				cont = false;
		}
		printf ("\n-----------------------------------------\n");
	}
}

//Escribe los datos de un vector_premios por pantalla
void escribir_datos (int *v, int s) {
	for(int j=0; j < s; j++)
		printf ("\nFichero_datos: %d\n", v[j]);
}

//Escribe los datos de un vector_premios en intervalos por pantalla
void escribir_datos_int (int *v, int i, int f) {
	for(int j=i; j < f; j++)
		printf ("\nFichero_datos: %d\n", v[j]);
}

//Obtiene un el intervalo de los identificadores que se indiquen en 
void obtener_intervalos(int *v, int etiq, int s, int *i, int *f, int cifra){
	int pos = 0;
   int contador = 0;
	bool continua=true;
	for(int j=0; j < s && continua; j++){
		if(v[j]==etiq){
			pos = j+1;
			contador = j+1;
			while(v[contador]<cifra)
				contador++;
			continua=false;
		}
	}
	*i=pos;
	*f=contador;
}

//Obtiene los intervalos de los premios que se indiquen
void obtener_premios(int *v, int premio, int s, int *i, int *f){
	int pos = 0;
   int contador = 0;
	bool continua=true;
	for(int j=0; j < s && continua; j++){
		if(v[j]==-premio){
			pos = j+1;
			contador = j+1;
			while(v[contador]>0)
				contador++;
			continua=false;
		}
	}
	*i=pos;
	*f=contador;
}
