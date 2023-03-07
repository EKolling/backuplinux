#!/bin/bash

#adicionar o agendamento ao crontab, todo dia, as 7,13 e 19 horas. executar script de backup, com logs no output_aws.txt
(crontab -l; echo "0 7,13,19 * * * $HOME/projects/cco-backups-s3/script.sh >> $HOME/projects/cco-backups-s3/output_aws.txt") | crontab -

#reiniciar crontab
sudo service cron restart


rm cron.sh
 
