#!/usr/bin/env bash

# переменная-массив с перечислением сервисов, доступность которых требуется проверять:
LIST_SERVICES=("192.168.0.1:80" "173.194.222.113:80" "87.250.250.242:80")
# переменная, определяющая кол-во проверок:
COUNT=5
# переменная лог-файл:
LOGFILE=services.log

# если логфайл существует, то удалить его, чтобы записывать в новый:
if [ -f ${LOGFILE} ]
then
  rm -f ${LOGFILE}
fi

for service in ${LIST_SERVICES[@]}
do
  iter=1
  while [ ${iter} -le ${COUNT} ]
  do
    if echo "" > /dev/tcp/$(echo ${service} | sed "s/:/\//g")
    then
      echo "$(date +"%D %X") [SUCCESS] Сервис ${service} доступен." >> ${LOGFILE}
    else
      echo "$(date +"%D %X") [ERROR] Сервис ${service} не доступен !!!" >> ${LOGFILE}
    fi
  let iter++
  #iter=$((${count}+1))
  sleep 1
  done
done
