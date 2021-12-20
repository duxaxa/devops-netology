# Домашнее задание к занятию "4.1. Командная оболочка Bash: Практические навыки"

## Обязательная задача 1

Есть скрипт:
```bash
a=1
b=2
c=a+b
d=$a+$b
e=$(($a+$b))
```

Какие значения переменным c,d,e будут присвоены? Почему?

| Переменная | Значение | Обоснование                                                                                                                                                                                                                                                                                                                                                              |
|------------|----------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `c`        | `a+b`    | При выполнении операции `c=a+b` переменной `c` присваивается<br/>новое значение в виде строки `a+b`. `a` и `b` в данном случае не <br/>являются переменными, объявленными ранее                                                                                                                                                                                          |
| `d`        | `1+2`    | При выполнении операции `d=$a+$b` переменной `d` <br/> присваивается значение переменных `a` и `b`, объявленных ранее, <br/>и строки `+`. По умолчанию, переменные `a` и `b` это строки, поэтому<br/> происходит сложение (конкатенация) трех строк:<br/> 1) подстановка значения переменной `a`<br/> 2) строка `+`<br/>3) подстановка значения переменной `b` |
| `e`        | `3`      | При выполнении операции `e=$(($a+$b))` переменной `e` присваивается<br/>значение переменных `a` и `b`, объявленных ранее. Т.к. используется<br/>подстановка результата сложения `$a+$b` с двойными скобками, то <br/>выполняется арифметическое сложение вместо конкатенации строковых значений.                                                                         |

```commandline
vagrant@test-netology:~/aaa$
 a=1

vagrant@test-netology:~/aaa$
 b=2

vagrant@test-netology:~/aaa$
 c=a+b; echo $c
a+b

vagrant@test-netology:~/aaa$
 d=$a+$b; echo $d
1+2

vagrant@test-netology:~/aaa$
 e=$(($a+$b))

vagrant@test-netology:~/aaa$
 e=$(($a+$b)); echo $e
3

```

## Обязательная задача 2
На нашем локальном сервере упал сервис и мы написали скрипт, который постоянно проверяет его доступность, записывая дату проверок до тех пор, пока сервис не станет доступным (после чего скрипт должен завершиться). В скрипте допущена ошибка, из-за которой выполнение не может завершиться, при этом место на Жёстком Диске постоянно уменьшается. Что необходимо сделать, чтобы его исправить:
```bash
while ((1==1)
do
	curl https://localhost:4757
	if (($? != 0))
	then
		date >> curl.log
	fi
done
```
Доработанный вариант скрипта:
```bash
while ((1==1)
do
	curl https://localhost:4757
	if (($? != 0))
	then
		date >> curl.log
	fi
	## добавляем условие, при выполнении которого произойдет выход из цикла:
	if ((&? = 0))
	then
	    break
	fi
done
```

Необходимо написать скрипт, который проверяет доступность трёх IP: `192.168.0.1`, `173.194.222.113`, `87.250.250.242` по `80` порту и записывает результат в файл `log`. Проверять доступность необходимо пять раз для каждого узла.

### Ваш скрипт:
[check_services.sh](check_services.sh)
```bash
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
  sleep 1
  #iter=$((${count}+1))
  done
done
```

### Тестирование:
```bash
#на dummy интерфейсе создаем 3 IP:

cat /etc/network/interfaces

source-directory /etc/network/interfaces.d

auto dummy0
iface dummy0 inet static
  address 192.168.0.1/30
  address 173.194.222.113/30
  address 87.250.250.242/30
  pre-up ip link add dummy0 type dummy
  post-down ip link del dummy0


# открываем порт :80 на IP 192.168.0.1 и 87.250.250.242 и :81 на  173.194.222.113: 
root@test-netology:~#
 nc -lk -p 80 -s 192.168.0.1 &
[1] 2492

root@test-netology:~#
 nc -lk -p 81 -s 173.194.222.113 &
[2] 2493

root@test-netology:~#
 nc -lk -p 80 -s 87.250.250.242 &
[3] 2494


# запускаем скрипт:
vagrant@test-netology:~/aaa$
 ./check_services.sh 
./check_services.sh: connect: Connection refused
./check_services.sh: line 21: /dev/tcp/$(echo ${service} | sed "s/:/\//g"): Connection refused
./check_services.sh: connect: Connection refused
./check_services.sh: line 21: /dev/tcp/$(echo ${service} | sed "s/:/\//g"): Connection refused
./check_services.sh: connect: Connection refused
./check_services.sh: line 21: /dev/tcp/$(echo ${service} | sed "s/:/\//g"): Connection refused
./check_services.sh: connect: Connection refused
./check_services.sh: line 21: /dev/tcp/$(echo ${service} | sed "s/:/\//g"): Connection refused
./check_services.sh: connect: Connection refused
./check_services.sh: line 21: /dev/tcp/$(echo ${service} | sed "s/:/\//g"): Connection refused

# смотрим лог:
vagrant@test-netology:~/aaa$
 cat services.log 
12/19/21 08:57:38 PM [SUCCESS] Сервис 192.168.0.1:80 доступен.
12/19/21 08:57:39 PM [SUCCESS] Сервис 192.168.0.1:80 доступен.
12/19/21 08:57:40 PM [SUCCESS] Сервис 192.168.0.1:80 доступен.
12/19/21 08:57:41 PM [SUCCESS] Сервис 192.168.0.1:80 доступен.
12/19/21 08:57:42 PM [SUCCESS] Сервис 192.168.0.1:80 доступен.
12/19/21 08:57:43 PM [ERROR] Сервис 173.194.222.113:80 не доступен !!!
12/19/21 08:57:44 PM [ERROR] Сервис 173.194.222.113:80 не доступен !!!
12/19/21 08:57:45 PM [ERROR] Сервис 173.194.222.113:80 не доступен !!!
12/19/21 08:57:46 PM [ERROR] Сервис 173.194.222.113:80 не доступен !!!
12/19/21 08:57:47 PM [ERROR] Сервис 173.194.222.113:80 не доступен !!!
12/19/21 08:57:48 PM [SUCCESS] Сервис 87.250.250.242:80 доступен.
12/19/21 08:57:49 PM [SUCCESS] Сервис 87.250.250.242:80 доступен.
12/19/21 08:57:50 PM [SUCCESS] Сервис 87.250.250.242:80 доступен.
12/19/21 08:57:51 PM [SUCCESS] Сервис 87.250.250.242:80 доступен.
12/19/21 08:57:52 PM [SUCCESS] Сервис 87.250.250.242:80 доступен


```

## Обязательная задача 3
Необходимо дописать скрипт из предыдущего задания так, чтобы он выполнялся до тех пор, пока один из узлов не окажется недоступным. Если любой из узлов недоступен - IP этого узла пишется в файл error, скрипт прерывается.

### Ваш скрипт:
[check_services_2.sh](check_services_2.sh)
```bash
#!/usr/bin/env bash

# переменная-массив с перечислением сервисов, доступность которых требуется проверять:
LIST_SERVICES=("192.168.0.1:80" "173.194.222.113:80" "87.250.250.242:80")
# переменная, определяющая кол-во проверок:
COUNT=5
# переменная лог-файл:
LOGFILE=services.log
ERRORFILE=error.log

# если логфайл существует, то удалить его, чтобы записывать в новый:
if [ -f ${LOGFILE} ]
then
  rm -f ${LOGFILE}
fi

if [ -f ${ERRORFILE} ]
then
  rm -f ${ERRORFILE}
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
      echo "$(date +"%D %X") [ERROR] Сервис ${service} не доступен !!!" >> ${ERRORFILE}
      exit 1
    fi
  let iter++
  #iter=$((${count}+1))
  sleep 1
  done
done
```

### Тестирование:
```bash
vagrant@test-netology:~/aaa$
 ./check_services_2.sh 
./check_services_2.sh: connect: Connection refused
./check_services_2.sh: line 27: /dev/tcp/$(echo ${service} | sed "s/:/\//g"): Connection refused

vagrant@test-netology:~/aaa$
 cat services.log 
12/19/21 09:33:55 PM [SUCCESS] Сервис 192.168.0.1:80 доступен.
12/19/21 09:33:56 PM [SUCCESS] Сервис 192.168.0.1:80 доступен.
12/19/21 09:33:57 PM [SUCCESS] Сервис 192.168.0.1:80 доступен.
12/19/21 09:33:58 PM [SUCCESS] Сервис 192.168.0.1:80 доступен.
12/19/21 09:33:59 PM [SUCCESS] Сервис 192.168.0.1:80 доступен.

vagrant@test-netology:~/aaa$
 cat error.log 
12/19/21 09:34:00 PM [ERROR] Сервис 173.194.222.113:80 не доступен !!!
```

## Дополнительное задание (со звездочкой*) - необязательно к выполнению

Мы хотим, чтобы у нас были красивые сообщения для коммитов в репозиторий. Для этого нужно написать локальный хук для git, который будет проверять, что сообщение в коммите содержит код текущего задания в квадратных скобках и количество символов в сообщении не превышает 30. Пример сообщения: \[04-script-01-bash\] сломал хук.

### Ваш скрипт:

[commit-msg.sh](commit-msg.sh)
```bash
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
```
### Тестирование:
```bash
vagrant@test-netology:~/aaa/repo$
 vi file 

vagrant@test-netology:~/aaa/repo$
 git add file 

vagrant@test-netology:~/aaa/repo$
 git commit -m "[EX-1]"

ОШИБКА шаблона сообщения !

Требования к сообщению коммита: 
Сообщение коммита не должно превышать 30 символов. 
Сообщение коммита должно соответствовать шаблону: ^(\[EXP|\[ARP|\[TSE)-[0-9]*\]$

vagrant@test-netology:~/aaa/repo$
 git commit -m "[EXP-1"

ОШИБКА шаблона сообщения !

Требования к сообщению коммита: 
Сообщение коммита не должно превышать 30 символов. 
Сообщение коммита должно соответствовать шаблону: ^(\[EXP|\[ARP|\[TSE)-[0-9]*\]$

vagrant@test-netology:~/aaa/repo$
 git commit -m "[EXP-1]"

Сообщение коммита прошло валидацию.

[master f636633] [EXP-1]
 Committer: vagrant <vagrant@test-netology>
Your name and email address were configured automatically based
on your username and hostname. Please check that they are accurate.
You can suppress this message by setting them explicitly. Run the
following command and follow the instructions in your editor to edit
your configuration file:

    git config --global --edit

After doing this, you may fix the identity used for this commit with:

    git commit --amend --reset-author

 1 file changed, 1 insertion(+)

vagrant@test-netology:~/aaa/repo$
 echo "2" >> file 

vagrant@test-netology:~/aaa/repo$
 git add file 

vagrant@test-netology:~/aaa/repo$
 git commit -m "[TSE-123456789012345678901234567890]"

ОШИБКА длины сообщения:	 36 символов !

Требования к сообщению коммита: 
Сообщение коммита не должно превышать 30 символов. 
Сообщение коммита должно соответствовать шаблону: ^(\[EXP|\[ARP|\[TSE)-[0-9]*\]$

vagrant@test-netology:~/aaa/repo$
 git commit -m "[TSE-12345]"

Сообщение коммита прошло валидацию.

[master 6028a12] [TSE-12345]
 Committer: vagrant <vagrant@test-netology>
Your name and email address were configured automatically based
on your username and hostname. Please check that they are accurate.
You can suppress this message by setting them explicitly. Run the
following command and follow the instructions in your editor to edit
your configuration file:

    git config --global --edit

After doing this, you may fix the identity used for this commit with:

    git commit --amend --reset-author

 1 file changed, 1 insertion(+)

vagrant@test-netology:~/aaa/repo$
 git log
commit 6028a12a0cd8de18fa89a4247794ee0f199da703 (HEAD -> master)
Author: vagrant <vagrant@test-netology>
Date:   Mon Dec 20 20:00:55 2021 +0000

    [TSE-12345]

commit f6366337f4cc8245d715e84fbf3b59ce0593f604
Author: vagrant <vagrant@test-netology>
Date:   Mon Dec 20 19:59:57 2021 +0000

    [EXP-1]

```