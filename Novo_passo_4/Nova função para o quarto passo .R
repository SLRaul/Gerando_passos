
rm(list = ls()) # Limpa a mem�ria

com <-Sys.time()# iniciando contagem de tempo

## mundando o diret�rio # quando est� no trt
#setwd("X:/SGE/GABINETE/CONSELHO NACIONAL DE JUSTICA/JUSTICA EM NUMEROS/JUSTI?A EM N?MEROS_DADOS ANUAIS/JN ANO 2020/Arquivos Provimento 49 de 18_08_2015/Quarto Passo/Gerar quarto passo")


#pacotes utilizados 
library(dplyr) #manipula??o de dados
library(readxl) #leitura de arquivo xls
library(lubridate) # manipula??o de datas
library(stringi)  # manipula??o de strings
library(readODS) #ler arquivos .ods

# ---------------------------- #
# Valores a ser alterados
# ---------------------------- #

#valores inicias
dia_inicio_atual <- dmy("1/03/2021")
dia_fim_atual <-  dmy("31/03/2021")
mes_atual <- month(dia_inicio_atual)
ano_atual <- year(dia_inicio_atual)
nome_mes_atual <- "Mar�o"

# mudando o diret�rio
setwd("D:/romi_ofice")

# Planilha dos c?digos de serventia
# codigos_serventia=read_excel("Codigo_serventia.xls")

# � definido o caminho at� o arquivo + o nome do arquivo
BD_serventias=read_excel("D:/romi_ofice/data_base/BD serventias.xls") # Arquivo unico
# retirando os caracteres especias
BD_serventias$nome_serventia_sicond <- stri_trans_general(BD_serventias$nome_serventia_sicond, "Latin-ASCII")
BD_serventias$nome_serventia_egestao <- stri_trans_general(BD_serventias$nome_serventia_egestao, "Latin-ASCII")
BD_serventias$nome_serventia_desig  <- stri_trans_general(BD_serventias$nome_serventia_desig, "Latin-ASCII")


# Planilha dos c?digos de magistrados
BD_magistrados=read_excel("D:/romi_ofice/data_base/BD magistrados.xls") # Arquivo unico
#Retirando os caracteres especiais 
BD_magistrados$nome_magis<-stri_trans_general(BD_magistrados$nome_magis, "Latin-ASCII")  ##

# Banco de dados afastamentos
BD_afastamentos=read_excel("D:/romi_ofice/Passo 4/2021/mar�o/BD afastamentos.xls") # Arquivo mensal
colnames(BD_afastamentos)=c("nome_magis","inicio_afast","fim_afast","MOTIVO")
#Retirando os caracteres especiais
BD_afastamentos$nome_magis<-stri_trans_general(BD_afastamentos$nome_magis, "Latin-ASCII")  ##

# Banco de dados designa??es
BD_desig=read_excel("D:/romi_ofice/Passo 4/2021/mar�o/BD desig.xls") # Arquivo mensal
colnames(BD_desig)=c("nome_magis","inicio_desig","fim_desig","nome_serventia_desig","Tipo_magis")
#retirando os caracteres especiais
BD_desig$nome_magis<-stri_trans_general(BD_desig$nome_magis, "Latin-ASCII")  ##
BD_desig$nome_serventia_desig <- stri_trans_general(BD_desig$nome_serventia_desig, "Latin-ASCII")

# Buscar metas (Produtividade)
# quarto_1grau=read_excel("D:/romi_ofice/Passo 4/2021/fevereiro/Quarto passo 1 grau.xls") # Arquivo mensal
quarto_1grau=read_ods("D:/romi_ofice/Passo 4/2021/mar�o/Quarto passo 1 grau.ods") # Arquivo mensal


## verificar aqui se os dados est?o ok ##

# mudando o nome das duas primeiras colunas
colnames(quarto_1grau)[1:2]=c("nome_magis","nome_serventia_sicond")

#retirando os caracteres especiais
quarto_1grau$nome_magis<-stri_trans_general(quarto_1grau$nome_magis, "Latin-ASCII")  ##
quarto_1grau$nome_serventia_sicond<-stri_trans_general(quarto_1grau$nome_serventia_sicond, "Latin-ASCII") 
# Adicionando coluna CPF_magis em quarto_1grau
quarto_1grau=left_join(quarto_1grau,BD_magistrados %>% select(nome_magis,CPF_magis))
# Adicionando coluna codigo_VT em quarto_1grau
quarto_1grau=left_join(quarto_1grau,BD_serventias %>% select(codigo_VT,nome_serventia_sicond))

# Buscar metas (Produtividade)
# quarto_2grau=read_excel("D:/romi_ofice/Passo 4/2021/fevereiro/Quarto passo 2 grau.xls") # Arquivo mensal
quarto_2grau=read_ods("D:/romi_ofice/Passo 4/2021/mar�o/Quarto passo 2 grau.ods") # Arquivo mensal

## verificar aqui se os dados est?o ok ##

# mudando o nome das duas primeiras colunas
colnames(quarto_2grau)[1:2]=c("nome_magis","nome_serventia_sicond")
#retirando os caracteres especiais
quarto_2grau$nome_magis<-stri_trans_general(quarto_2grau$nome_magis, "Latin-ASCII")  ##
quarto_2grau$nome_serventia_sicond<-stri_trans_general(quarto_2grau$nome_serventia_sicond, "Latin-ASCII")  ##
# Adicionando coluna CPF_magis em quarto_1grau
quarto_2grau=left_join(quarto_2grau,BD_magistrados %>% select(CPF_magis,nome_magis))
# Adicionando coluna codigo_VT em quarto_1grau
quarto_2grau=left_join(quarto_2grau,BD_serventias %>% select(codigo_VT,nome_serventia_sicond))

## verificar aqui se os dados est?o ok ##

#--------------------------------------------------------------------------------#
# A função time_function_desig entra aqui
#---------------------------------------------------------------- ----------------#
# Chamando a fun��o que calcula os dias trabalhados de cada designa��o "time_function_desig.R"
source("C:/Users/silva/Documents/Repositorio/Gerando_passos/Novo_passo_4/time_function_desig.R")
# Dados de entrada - renomeados para as fun��es
data_inicial <- dia_inicio_atual
data_final <- dia_fim_atual
dias_mes <- interval(data_inicial,data_final)/ddays(1) +1

# A saida � uma lista com os dados de designa��o e de afastamento
lista <- periodo_trabalhado(data_inicial, data_final, dias_mes, BD_desig)

# Renomeando e ajustando os novo dados de deigna��o
BD_desig_ <- (lista$desig)
BD_desig_ <- left_join(BD_desig_, BD_magistrados %>% select(-codigo_magis))
BD_desig_ <- BD_desig_ %>% mutate(Jun��o=paste(codigo_VT,"-",CPF_magis))

# somando os dias trabalhados da mesma vt
BD_trabalhado=as_tibble(aggregate(BD_desig_$tempo_trabalhado,by=list(BD_desig_$Jun��o),FUN=sum));colnames(BD_trabalhado)<-c("Jun��o", "tempo")
# retirando os repetidos
BD_desig_ <- (BD_desig_ %>% distinct(Jun��o, .keep_all = T))
# juntando os dias trabalhados em cada vt com com as desg 
for (i in 1:nrow(BD_desig_)) {
  for (j in 1:nrow(BD_trabalhado)) {
    if(BD_desig_$Jun��o[i] == BD_trabalhado$Jun��o[j]){
      BD_desig_$tempo_trabalhado[i] <- BD_trabalhado$tempo[j]
    }
  }
}


#codigo do tipo de juiz
Tipo_magis=c("Magistrado Titular","Juiz no Exerc�cio da Titularidade",
             "Juiz Vinculado","Juiz Substituto","Substituto TRT")
codigo_TJ=c(0,1,3,3,8)
BD_Tipo_de_Juiz=data.frame(codigo_TJ,Tipo_magis)

BD_desig_ <- left_join(BD_desig_, BD_Tipo_de_Juiz)



# --------------------------------------------------------- #
# ----- TRABALHANDO COM AS VARI�VEIS DO PRIMEIRO GRAU ----- #
# --------------------- Primeiro Grau --------------------- #

# Fun��es utilizadas para verificar se uma determinada
# vari�vel est� presente o banco de dados ou n�o.
library(lazyeval)
verificar_coluna <- function(data, coluna){
  coluna_texto <- lazyeval::expr_text(coluna)
  coluna_texto %in% names(data)
}

verificar=function(data,coluna,retorno){
  if(verificar_coluna(data,coluna)==T){
    return(retorno)
  }else{
    return(NA)
  }
}

# Vari�veis do Quarto passo 1� grau
AudConc1�=verificar(quarto_1grau,`AUDCONC1� - Audi�ncias de concilia��o realizadas em 1� grau`,
                    quarto_1grau$`AUDCONC1� - Audi�ncias de concilia��o realizadas em 1� grau`)
AudNConc1�=verificar(quarto_1grau,`AUDNCONC1� - Audi�ncias realizadas em 1� grau - exceto de concilia��es`,
                     quarto_1grau$`AUDNCONC1� - Audi�ncias realizadas em 1� grau - exceto de concilia��es`)
DecInt1�=verificar(quarto_1grau,`DECINT1� - Decis�es interlocut�rias no 1� grau`,
                   quarto_1grau$`DECINT1� - Decis�es interlocut�rias no 1� grau`)
RIntCJ1�=verificar(quarto_1grau,`RINTCJ1� - Recursos internos julgados no 1� grau na fase de conhecimento (embargos de declara��o)`,
                   quarto_1grau$`RINTCJ1� - Recursos internos julgados no 1� grau na fase de conhecimento (embargos de declara��o)`)
SentCCM1�=verificar(quarto_1grau,`SENTCCM1� - Senten�as de conhecimento com julgamento do m�rito no 1� grau`,
                    quarto_1grau$`SENTCCM1� - Senten�as de conhecimento com julgamento do m�rito no 1� grau`)
SentCSM1�=verificar(quarto_1grau,`SENTCSM1� - Senten�as de conhecimento sem julgamento do m�rito no 1� grau`,
                    quarto_1grau$`SENTCSM1� - Senten�as de conhecimento sem julgamento do m�rito no 1� grau`)
SentDC1�=verificar(quarto_1grau,`SENTDC1� - Senten�as proferidas nas demais classes processuais no 1� grau`,
                   quarto_1grau$`SENTDC1� - Senten�as proferidas nas demais classes processuais no 1� grau`)
SentExH1�=verificar(quarto_1grau,`SENTEXH1� - Senten�as em execu��o homologat�rias de acordos no 1� grau`,
                    quarto_1grau$`SENTEXH1� - Senten�as em execu��o homologat�rias de acordos no 1� grau`)
SentExtFisc1�=verificar(quarto_1grau,`SENTEXTFISC1� - Senten�as em execu��o fiscal no 1� grau`,
                        quarto_1grau$`SENTEXTFISC1� - Senten�as em execu��o fiscal no 1� grau`)
SentJud1�=verificar(quarto_1grau,`SENTJUD1� - Senten�as em execu��o judicial no 1� grau`,
                    quarto_1grau$`SENTJUD1� - Senten�as em execu��o judicial no 1� grau`)
SentExtNFisc1�=verificar(quarto_1grau,`SENTEXTNFISC1� - Senten�as em execu��o de t�tulo extrajudicial no 1� grau, exceto senten�as em execu��o fiscal`,
                         quarto_1grau$`SENTEXTNFISC1� - Senten�as em execu��o de t�tulo extrajudicial no 1� grau, exceto senten�as em execu��o fiscal`)
SentHDC1�=verificar(quarto_1grau,`SENTHDC1� - Senten�as homologat�rias de acordo proferidas nas demais classes no 1� grau`,
                    quarto_1grau$`SENTHDC1� - Senten�as homologat�rias de acordo proferidas nas demais classes no 1� grau`)
SentCH1�=verificar(quarto_1grau,`SENTCH1� - Senten�as em conhecimento homologat�rias de acordos 1� grau`,
                   quarto_1grau$`SENTCH1� - Senten�as em conhecimento homologat�rias de acordos 1� grau`)

# Juntando as vari�veis
dados1=data.frame(nome_serventia_sicond=quarto_1grau$nome_serventia_sicond,
                  nome_magis=quarto_1grau$nome_magis,
                  codigo_VT=quarto_1grau$codigo_VT,
                  CPF_magis=quarto_1grau$CPF_magis,
                  AudConc1�,
                  AudNConc1�,
                  DecInt1�,
                  RIntCJ1�,
                  SentCCM1�,
                  SentCSM1�,
                  SentDC1�,
                  SentExH1�,
                  SentExtFisc1�,
                  SentJud1�,
                  SentExtNFisc1�,
                  SentHDC1�,
                  SentCH1�)

# Adicionando uma coluna com a jun��o dos codigos de serventia e CPF em dados1
dados1=dados1 %>% mutate(Jun��o=paste(codigo_VT,"-",CPF_magis))

# Adicionando coluna iniciais
dados1$`Tipo Juiz`=NA
dados1$Mes=mes_atual
dados1$Ano=ano_atual
dados1$`Quantidade dias corridos`=NA
dados1$Observa��o=NA

# Vari�veis do 2� grau
dados1$AudConc2�=NA
dados1$AudNConc2�=NA
dados1$Dec2�=NA
dados1$DecDC2�=NA
dados1$DecH2�=NA
dados1$DecHDC2�=NA
dados1$DecInt2�=NA
dados1$RintJ2�=NA
dados1$VotoR2�=NA

# Organizando o banco de dados 1� grau
dados1 = dados1 %>% select(Jun��o,nome_magis,nome_serventia_sicond,
                           CPF_magis,codigo_VT,`Tipo Juiz`,Mes,
                           Ano,`Quantidade dias corridos`,Observa��o,AudConc2�,AudNConc2�,Dec2�,DecDC2�,
                           DecH2�,DecHDC2�,DecInt2�,RintJ2�,VotoR2�,AudConc1�,AudNConc1�,DecInt1�,RIntCJ1�,
                           SentCCM1�,SentCH1�,SentCSM1�,SentDC1�,SentExH1�,SentExtFisc1�,SentExtNFisc1�,
                           SentHDC1�,SentJud1�)

# ----------------------------------------------------------- #
# ------------------- Segundo Grau -------------------------- #
# ------- Trabalhando com vari�veis do segundo grau --------- #

# Vari�veis do Quarto passo 2� grau
AudConc2�=verificar(quarto_2grau,`AUDCONC2� - Audi�ncias de concilia��o realizadas em 2� grau`,
                    quarto_2grau$`AUDCONC2� - Audi�ncias de concilia��o realizadas em 2� grau`)
Dec2�=verificar(quarto_2grau,`DEC2� - Decis�es terminativas de processo no 2� grau`,
                quarto_2grau$`DEC2� - Decis�es terminativas de processo no 2� grau`)
DecH2�=verificar(quarto_2grau,`DECH2� - Decis�es homologat�rias de acordos no 2� grau`,
                 quarto_2grau$`DECH2� - Decis�es homologat�rias de acordos no 2� grau`)
DecInt2�=verificar(quarto_2grau,`DECINT2� - Decis�es interlocut�rias no 2� grau`,
                   quarto_2grau$`DECINT2� - Decis�es interlocut�rias no 2� grau`)
RintJ2�=verificar(quarto_2grau,`RINTJ2� - Recursos internos julgados no 2� grau`,
                  quarto_2grau$`RINTJ2� - Recursos internos julgados no 2� grau`)
VotoR2�=verificar(quarto_2grau,`VOTORNCRIM2� - Votos proferidos pelo relator em processos n�o criminais de 2� grau`,
                  quarto_2grau$`VOTORNCRIM2� - Votos proferidos pelo relator em processos n�o criminais de 2� grau`)
AudNConc2�=verificar(quarto_2grau,`AUDNCON2� - Audi�ncias realizadas em 2� grau - exceto de cpmcilia��o`,
                     quarto_2grau$`AUDNCON2� - Audi�ncias realizadas em 2� grau - exceto de cpmcilia��o`)
DecDC2�=verificar(quarto_2grau,`DECDC2� - Decis�es terminativas proferidas nas demais classes processuais no 2� grau`,
                  quarto_2grau$`DECDC2� - Decis�es terminativas proferidas nas demais classes processuais no 2� grau`)
DecHDC2�=verificar(quarto_2grau,`DECDC2� - Decis�es terminativas proferidas nas demais classes processuais no 2� grau`,
                   quarto_2grau$`DECDC2� - Decis�es terminativas proferidas nas demais classes processuais no 2� grau`)

# Juntando as vari�veis
dados2 = data.frame(nome_serventia_sicond=quarto_2grau$nome_serventia_sicond,
                    nome_magis=quarto_2grau$nome_magis,
                    codigo_VT=quarto_2grau$codigo_VT,
                    CPF_magis=quarto_2grau$CPF_magis,
                    AudConc2�,
                    Dec2�,
                    DecH2�,
                    DecInt2�,
                    RintJ2�,
                    VotoR2�,
                    AudNConc2�,
                    DecDC2�,
                    DecHDC2�)

# Vari�veis do 1 Grau
dados2$AudConc1�=NA
dados2$AudNConc1�=NA
dados2$DecInt1�=NA
dados2$RIntCJ1�=NA
dados2$SentCCM1�=NA
dados2$SentCH1�=NA
dados2$SentCSM1�=NA
dados2$SentDC1�=NA
dados2$SentExH1�=NA
dados2$SentExtFisc1�=NA
dados2$SentExtNFisc1�=NA
dados2$SentHDC1�=NA
dados2$SentJud1�=NA

# Adicionando coluna iniciais  
dados2$`Tipo Juiz`=NA
dados2$Mes=mes_atual
dados2$Ano=ano_atual
dados2$`Quantidade dias corridos`=NA
dados2$Observa��o=NA

# Adicionando uma coluna com a jun��o dos codigos de serventia e CPF em dados2
dados2 = dados2 %>% mutate(Jun��o=paste(codigo_VT,"-",CPF_magis))

# Organizando o banco de dados 2� grau
dados2 = dados2 %>% select(Jun��o,nome_magis,nome_serventia_sicond,
                           CPF_magis,codigo_VT,`Tipo Juiz`,Mes,
                           Ano,`Quantidade dias corridos`,Observa��o,AudConc2�,AudNConc2�,Dec2�,DecDC2�,
                           DecH2�,DecHDC2�,DecInt2�,RintJ2�,VotoR2�,AudConc1�,AudNConc1�,DecInt1�,RIntCJ1�,
                           SentCCM1�,SentCH1�,SentCSM1�,SentDC1�,SentExH1�,SentExtFisc1�,SentExtNFisc1�,
                           SentHDC1�,SentJud1�)

# # # Juntando ambos os bancos de dados # # # 
# # # se precisar reorganizar o 'Quarto passo' come�ar aqui # # # 
Quarto_passo=rbind(dados1,dados2)

#colocando o codigo tj
Quarto_passo <- (left_join(Quarto_passo, BD_desig_ %>% select(Jun��o, codigo_TJ)))

# Colocando c�digo 4 para todos os espa�os com NA,
Quarto_passo$codigo_TJ=ifelse(is.na(Quarto_passo$codigo_TJ),4,Quarto_passo$codigo_TJ)

# # # #  # colocando  os que est�o somente no do quarto passo  # # # # # # # # # ## # # # 

# preparando os dias trabalhados e c�digo_tj
# aglutinando os dias trabalhados na mesma vt
info <- BD_desig_ %>% select("Jun��o","nome_magis","codigo_TJ","nome_serventia_sicond","CPF_magis","codigo_VT","dias_desig" = tempo_trabalhado)

#colocando os dias desig

Quarto_passo <- left_join(Quarto_passo, info %>% select("Jun��o","codigo_TJ","dias_desig"))

# # # # # # colocando os que est�o em designa��o e nao no quarto passo # # # # # # # # # # # # # # 

# Adicionando coluna iniciais
info$`Tipo Juiz`=NA
info$Mes=mes_atual
info$Ano=ano_atual
info$`Quantidade dias corridos` = NA
info$Observa��o=NA

# Vari�veis do 2� grau
info$AudConc2�=NA
info$AudNConc2�=NA
info$Dec2�=NA
info$DecDC2�=NA
info$DecH2�=NA
info$DecHDC2�=NA
info$DecInt2�=NA
info$RintJ2�=NA
info$VotoR2�=NA

# Vari�veis do 1 Grau
info$AudConc1�=NA
info$AudNConc1�=NA
info$DecInt1�=NA
info$RIntCJ1�=NA
info$SentCCM1�=NA
info$SentCH1�=NA
info$SentCSM1�=NA
info$SentDC1�=NA
info$SentExH1�=NA
info$SentExtFisc1�=NA
info$SentExtNFisc1�=NA
info$SentHDC1�=NA
info$SentJud1�=NA

# ordenando
info <-  info  %>% select(Jun��o,nome_magis,nome_serventia_sicond,
                              CPF_magis,codigo_VT,`Tipo Juiz`,Mes,
                              Ano,`Quantidade dias corridos`,Observa��o,AudConc2�,AudNConc2�,Dec2�,DecDC2�,
                              DecH2�,DecHDC2�,DecInt2�,RintJ2�,VotoR2�,AudConc1�,AudNConc1�,DecInt1�,RIntCJ1�,
                              SentCCM1�,SentCH1�,SentCSM1�,SentDC1�,SentExH1�,SentExtFisc1�,SentExtNFisc1�,
                              SentHDC1�,SentJud1�,codigo_TJ,dias_desig)

Quarto_passo <- rbind(Quarto_passo, info)

Quarto_passo <- Quarto_passo[order(Quarto_passo$nome_magis),]

Quarto_passo <- (Quarto_passo %>% distinct(Jun��o, codigo_TJ, .keep_all= T))


# colocando os dias de afastamentos e as observa��es
Quarto_passo <- (left_join(Quarto_passo, lista$afastamento))

# ordenando as colunas
Quarto_passo <- Quarto_passo %>% select(`CPF Magistrado`=CPF_magis,`C�digo Serventia`=codigo_VT,nome_magis,nome_serventia_sicond,
                                        `Tipo Juiz`=codigo_TJ,Mes,
                                        Ano,`Quantidade dias corridos`=dias_desig,
                                        `Dias de Afastamento`=tempo_afastado,Observa��o=Descri��o,
                                        AudConc2�,AudNConc2�,Dec2�,DecDC2�,
                                        DecH2�,DecHDC2�,DecInt2�,RintJ2�,VotoR2�,AudConc1�,AudNConc1�,DecInt1�,RIntCJ1�,
                                        SentCCM1�,SentCH1�,SentCSM1�,SentDC1�,SentExH1�,SentExtFisc1�,SentExtNFisc1�,
                                        SentHDC1�,SentJud1�)

# ajustando os dias trabalhados com os dias afastados ...
for( i in 1:nrow(Quarto_passo)){
  if(is.na(Quarto_passo$Observa��o[i]) == F &&
     is.na(Quarto_passo$`Quantidade dias corridos`[i]) == F &&
     Quarto_passo$`Quantidade dias corridos`[i] == dias_mes)
   Quarto_passo$`Quantidade dias corridos`[i] = (Quarto_passo$`Quantidade dias corridos`[i] - Quarto_passo$`Dias de Afastamento`[i])
}


# Criando fun��o que converte um vetor de encoding qualquer para encoding latin1
# sendo este necess�rio para vizualiza��o correta no excel
Converter_em_latin1=function(vetor){
  vetor=as.character(vetor)
  n=length(vetor)
  a=vector(length = n)
  for(i in 1:n){
    if(Encoding(vetor[i])!="unknown"){
      a[i]=iconv(vetor[i], from=Encoding(vetor[i]), to="latin1", sub="byte")
    }else{
      a[i]=vetor[i]
    }
  }
  return(a)
}

# colocando o c�digo para os desembargadores
for (i in 1:nrow(Quarto_passo)) {
  if(str_detect(Quarto_passo$nome_serventia_sicond[i],Quarto_passo$nome_magis[i] ) == TRUE)
    Quarto_passo$`Tipo Juiz`[i] <- 6
}

# Transformando colunas formadas por strings
Quarto_passo$nome_serventia_sicond=Converter_em_latin1(Quarto_passo$nome_serventia_sicond)
Quarto_passo$nome_magis=Converter_em_latin1(Quarto_passo$nome_magis)
Quarto_passo$Observa��o=Converter_em_latin1(Quarto_passo$Observa��o)
Quarto_passo$`CPF Magistrado` <- as.numeric(paste0(Quarto_passo$`CPF Magistrado`) )

Quarto_passo <- Quarto_passo %>% select(`CPF Magistrado`,`C�digo Serventia`, nome_magis,
                                        nome_serventia_sicond,`Tipo Juiz` ,Mes,
                                        Ano,`Quantidade dias corridos`,`Dias de Afastamento`,
                                        Observa��o,
                                        AudConc2�,AudNConc2�,Dec2�,DecDC2�,
                                        DecH2�,DecHDC2�,DecInt2�,RintJ2�,VotoR2�,AudConc1�,AudNConc1�,DecInt1�,RIntCJ1�,
                                        SentCCM1�,SentCH1�,SentCSM1�,SentDC1�,SentExH1�,SentExtFisc1�,SentExtNFisc1�,
                                        SentHDC1�,SentJud1�)

## ATUALIZA A PASTA DO MES E O NOME DO ARQUIVO ANTES DE RODAR ESSA PARTE ##
library(openxlsx)
write.xlsx(Quarto_passo, "D:/romi_ofice/Passo 4/2021/mar�o/Quarto_passo_saida_mar�o.xlsx")

fim <- Sys.time()
fim-com
