#!/usr/bin/env bash

# в позиционном параметре $1 фактически передается файл .git/COMMIT_EDITMSG:
COMMIT_FILE=$1
COMMIT_MESSAGE=$(cat $COMMIT_FILE)
COMMIT_TEMPLATE="^(\[EXP|\[ARP|\[TSE)-[0-9]*\]$"
COMMIT_MESSAGE_MAX_LENGTH=30
RULES=" \
\nТребования к сообщению коммита: \
\nСообщение коммита не должно превышать ${COMMIT_MESSAGE_MAX_LENGTH} символов. \
\nСообщение коммита должно соответствовать шаблону: ${COMMIT_TEMPLATE}"

if [ ${#COMMIT_MESSAGE} -gt ${COMMIT_MESSAGE_MAX_LENGTH} ]
then
  echo -e "\nОШИБКА длины сообщения:\t ${#COMMIT_MESSAGE} символов !"
  echo -e ${RULES}
  exit 1
fi

if grep -qE ${COMMIT_TEMPLATE} ${COMMIT_FILE}
then
	echo -e "\nСообщение коммита прошло валидацию.\n"
	exit 0
else
  echo -e "\nОШИБКА шаблона сообщения !"
  echo -e ${RULES}
  exit 1
fi
