#!/bin/bash

#encurtamentos
contract=$(grep -Ri "path" $HOME/projects/cco/cco-backend/.env |awk -F '"' '{print $2}' | sed 's/^.*$/\L&/' | sed 's, ,-,g')
#realiza leitura do path imports, para definir o nome do contrato,                         lowcase,       com Underline se tiver

hora_atual=$(date +%d-%m-%Y-%H-%M)
dia_atual=$(date +%d-%m-%Y)
mes_atual=$(date +%m-%Y)

expirar_aws=$(date -d "-5 months" +%d-%m-%Y-%H-%M) #definir o tempo para se guardar os arquivos na aws
expirar_local=$(date -d "-7 days" +%d-%m-%Y) #definir o tempo para se guardar os arquivos na rede local

diretorio_de_backup=$"$HOME/projects/backups/$mes_atual"
arquivo_novo=$diretorio_de_backup/dump_${hora_atual}.pgsql

#editar conforme o contrato o repositorio do AWS
aws_s3_bucket=$'s3://bucket-dump-psql/cco/'${contract}

echo "---------------- backup iniciado ${hora_atual} ----------"

#criar pasta no sistema local com a data atual, se ja existir a pasta, nao criar
if [ ! -d $diretorio_de_backup ]; then mkdir $diretorio_de_backup
fi

echo "criação de pastas concluido"

#criar o backup do dump-
docker exec -t pg pg_dump -U root cco-db > $diretorio_de_backup/dump_${hora_atual}.pgsql

echo "geração de dump concluido"


#verificar se o backup contem conteudo para backup.

grep -q 'PostgreSQL database dump complete' $arquivo_novo && echo $arquivo_novo VIAVEL PARA RESTAURAÇÃO || echo $arquivo_novo NAO VIAVEL PARA RESTAURAÇÃO


#verificar se um arquivo é maior que o minimo de 144kb, ou do padrao do contrato

tamanho_arquivo=$(du $arquivo_novo | awk '{print $1}') # leitura do arquivo, quantos kb tem.

if [[ $tamanho_arquivo -gt 140 ]]
then
     echo o arquivo de backup tem $tamanho_arquivo é maior que o basico para backup
else
     echo o tamanho de backup tem $tamanho_arquivo, verificar o que aconteceu.. arquivo menor que o basico para backup
fi

#enviar o backup para a aws     
aws s3 sync $diretorio_de_backup $aws_s3_bucket/$mes_atual
echo "realizado backup para o AWS S3"

# #apagar os arquivos antigos do aws 
# aws s3 rm $aws_s3_bucket/$mes_atual/$expirar_aws --recursive
# echo "removido backup do aws"

# #apagar os arquivos antigos, com mais de 7 dias, do computador local ------ nao mexer aqui-------
# if [ -d $diretorio_de_backup/$expirar_local ]; then rm -r $diretorio_de_backup/$expirar_local
# fi
# echo "removido dados do computador local"

echo "backup realizado com sucesso"
