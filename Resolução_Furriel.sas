/*=================================================================================================*/
/*====DESAFIO FURRIEL==============================================================================*/
/*=================================================================================================*/

proc delete data=_all_;
run;

/*IMPORTAR OS ARQUIVOS*/

proc import datafile="D:\OBSERVATÓRIO\Dados Universo PR\Dados SPSS\Pessoa11_PR_Homens_idade2.sav" 
	out=homens dbms = sav replace;
run;

proc import datafile="D:\OBSERVATÓRIO\Dados Universo PR\Dados SPSS\Pessoa12_PR_Mulheres_idade2.sav" 
	out=mulheres 
	dbms = sav replace;
run;

/*SOMA DAS IDADES*/

data homem_id (keep=Cod_setor ID_16_24H ID_25_34H ID_35_59H ID_60_maisH);
set homens;
	Cod_setor = int(Cod_setor);
	ID_16_24H = sum(of V050-V058);
	ID_25_34H = sum(of V059-V068);
	ID_35_59H = sum(of V069-V093);
	ID_60_maisH = sum(of V094-V134);
run;

data mulher_id (keep=Cod_setor ID_16_24M ID_25_34M ID_35_59M ID_60_maisM);
	set mulheres;
	Cod_setor = int(Cod_setor);
	ID_16_24M = sum(of V050-V058);
	ID_25_34M = sum(of V059-V068);
	ID_35_59M = sum(of V069-V093);
	ID_60_maisM = sum( of V094-V134);
run;

proc sort data=homem_id;
	by Cod_setor;
run;
proc sort data=mulher_id;
	by Cod_setor;
run;

/*IMPORTANTE O NOVO BANCO*/
/*REALIZANDO A MANIPULAÇÃO NECESSÁRIA*/

filename dados "D:\Estatística\ESTATÍSTICA COMPUTACIONAL II\Desafio_SAS\maringa.txt";
data regiao;
	infile dados dlm="," firstobs=2 missover dsd;
	format cod_setor2 16.;
	input Regiao Bairro$ Zona$ cod_setor2;
	aux=41;
run;

data regiao_t;
set regiao;
	format cod_setor2 cod_setor 15.;
	cod=cats(aux,cod_setor2);
	cod_setor=cod*1;/*gambiarra para transformar char em numérico*/
run;

proc sort data=regiao_t;
by cod_setor;
run;

/*REALIZANDO O MERGE*/

data merge_sexo_idade1; 
	merge homem_id mulher_id regiao_t;
	by Cod_setor;
	if regiao = . then delete;
run;

data Merge_sexo_idade;
	set Merge_sexo_idade1;
	cod_9 = substrn(cod_setor,length(cod_setor)+2);
run;

data Merge_sex_id (drop=ID regiao bairro zona c tipo c2 objectid cod_9 cod_setor2);
	set Merge_sexo_idade;
	if (cod_9=09 and id_16_24h^=.);
run; 

proc report data=merge_sex_id out=sum_tot nowd;
rbreak after/summarize;
run;

ODS html file='D:\Estatística\ESTATÍSTICA COMPUTACIONAL II\Desafio_SAS\teste.html'; 
proc print data=merge_sex_id sumlabel noobs
	style(data)=[background=gray foreground=white]
	style(header)=[font_weight=bold background=black foreground=white]
	style(total)=[background=black foreground=white]
	style(bylabel)=[background=black foreground=white];
		by aux;
		var cod_setor -- id_60_maisM;
		sum id_16_24H -- id_60_maisM ;
		label aux = 'TOTAL';
run;
ODS html close;

/*EXPORTANDO O BANCO */

proc export
data=sum_tot outfile="D:\Estatística\ESTATÍSTICA COMPUTACIONAL II\Desafio_SAS\sum_tot.xlsx"
dbms=xlsx replace;
run;

/*EXEMPLO DE FIND*/

data find;
set Merge_sex_id;
	pos_1 = find(cod,"1520005200009");
run;
proc print data=find;
	var pos_1;
run;
