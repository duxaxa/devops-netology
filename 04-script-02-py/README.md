# Домашнее задание к занятию "4.2. Использование Python для решения типовых DevOps задач"

## Обязательная задача 1

Есть скрипт:
```python
#!/usr/bin/env python3
a = 1
b = '2'
c = a + b
```

### Вопросы:
| Вопрос  | Ответ                                                                                                                                                                                                                                                                   |
| ------------- |-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Какое значение будет присвоено переменной `c`?  | При попытке присвоениея переменной `c` результата сложения <br/>переменных `a` и `b` возникнет ошибка, т.к. складываются <br/>переменные разных типов: `a`-`int` (целое число) и `b`-`str` (строка)<br/>`>>> a=1; b='2'; c=a+b`<br/>`Traceback (most recent call last):`<br/>`  File "<stdin>", line 1, in <module>`<br/>`TypeError: unsupported operand type(s) for +: 'int' and 'str'`<br/> |
| Как получить для переменной `c` значение 12?  | Нужно использовать приведение типов: перемнную `a` привести к типу `str`<br/>при сложении с переменной `b`:<br/>`>>> c=str(a)+b; print(c)`<br/> `12`                                                                                                                                                            |
| Как получить для переменной `c` значение 3?  | Нужно использовать приведение типов: перемнную `b` привести к типу `int`<br/>при сложении с переменной `a`:<br/>`>>> a=1; b='2'; c=a+int(b); print(c)`<br/>`3`                                                                                                                                                                                                                                                                     |

## Обязательная задача 2
Мы устроились на работу в компанию, где раньше уже был DevOps Engineer. Он написал скрипт, позволяющий узнать, какие файлы модифицированы в репозитории, относительно локальных изменений. Этим скриптом недовольно начальство, потому что в его выводе есть не все изменённые файлы, а также непонятен полный путь к директории, где они находятся. Как можно доработать скрипт ниже, чтобы он исполнял требования вашего руководителя?

```python
#!/usr/bin/env python3

import os

bash_command = ["cd ~/netology/sysadm-homeworks", "git status"]
result_os = os.popen(' && '.join(bash_command)).read()
is_change = False
for result in result_os.split('\n'):
    if result.find('modified') != -1:
        prepare_result = result.replace('\tmodified:   ', '')
        print(prepare_result)
        break
```

### Ваш скрипт:
#### Вариант 1  
[task_2.1.py](task_2.1.py)
```python
#!/usr/bin/env python3

import os

bash_command = ["cd ~/netology/sysadm-homeworks", "git status"]
result_os = os.popen(' && '.join(bash_command)).read()

repo_path_command = [bash_command[0], "pwd"]
repo_path = os.popen(' &&'.join(repo_path_command)).read()

# Массив для хранения файлов, которые были изменены:
modified_files = []

# Переменная объявлена, но нигде не используется. Убираем:
#is_change = False

for result in result_os.split('\n'):
    if result.find('modified') != -1:
        prepare_result = result.replace('\tmodified:   ', '')
        # Получаем абсолютный путь файлов:
        modified_file = os.path.join(repo_path.rstrip('\n'), prepare_result)
        # или другой вариант конкатенации строк:
        #modified_file = repo_path.rstrip('\n') + '/' + prepare_result
        modified_files.append(modified_file)
        # Работа цикла всегда прерывается после первого прохода. Убираем:
        #break

print('\nВ репозитории модифицированы файлы:\n')
for file in modified_files:
    print(file)

print('\nАтрибуты модифицированных файлов:\n')
for file in modified_files:
    #list_command = 'ls -l' + ' ' + file
    print(os.popen('ls -l' + ' ' + file).read().rstrip('\n'))

```
```shell
vagrant@test-netology:~$
 cd netology/sysadm-homeworks/ && git status && cd -
On branch master
Your branch is up to date with 'origin/master'.

Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
	modified:   01-intro-01/README.md
	modified:   04-script-01-bash/README.md
	modified:   README.md

no changes added to commit (use "git add" and/or "git commit -a")
/home/vagrant

vagrant@test-netology:~$
 ./task_2.2.py 

В репозитории модифицированы файлы:

/home/vagrant/netology/sysadm-homeworks/01-intro-01/README.md
/home/vagrant/netology/sysadm-homeworks/04-script-01-bash/README.md
/home/vagrant/netology/sysadm-homeworks/README.md

Атрибуты модифицированных файлов:

-rw-rw-r-- 1 vagrant vagrant 6724 Dec 24 21:06 /home/vagrant/netology/sysadm-homeworks/01-intro-01/README.md
-rw-rw-r-- 1 vagrant vagrant 2891 Dec 24 22:32 /home/vagrant/netology/sysadm-homeworks/04-script-01-bash/README.md
-rw-rw-r-- 1 vagrant vagrant 3699 Dec 24 21:06 /home/vagrant/netology/sysadm-homeworks/README.md

```

#### Вариант 2
[task_2.2.py](task_2.2.py)
```python
#!/usr/bin/env python3

import os

bash_command = ["cd ~/netology/sysadm-homeworks", 'for line in $(git status | grep modified | sed "s/\\tmodified:   //"); do ls -l $(pwd)/${line}; done']

result_os = os.popen(' && '.join(bash_command)).read()
print("\nМодифицированные файлы:\n\n" + result_os)
```
### Вывод скрипта при запуске при тестировании:
```shell
vagrant@test-netology:~$
 cd netology/sysadm-homeworks/ && git status && cd -
On branch master
Your branch is up to date with 'origin/master'.

Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
	modified:   01-intro-01/README.md
	modified:   04-script-01-bash/README.md
	modified:   README.md

no changes added to commit (use "git add" and/or "git commit -a")
/home/vagrant

vagrant@test-netology:~$
 ./task_2.1.py 

Модифицированные файлы:

-rw-rw-r-- 1 vagrant vagrant 6724 Dec 24 21:06 /home/vagrant/netology/sysadm-homeworks/01-intro-01/README.md
-rw-rw-r-- 1 vagrant vagrant 2891 Dec 24 22:32 /home/vagrant/netology/sysadm-homeworks/04-script-01-bash/README.md
-rw-rw-r-- 1 vagrant vagrant 3699 Dec 24 21:06 /home/vagrant/netology/sysadm-homeworks/README.md

```


## Обязательная задача 3
1. Доработать скрипт выше так, чтобы он мог проверять не только локальный репозиторий в текущей директории, а также умел воспринимать путь к репозиторию, который мы передаём как входной параметр. Мы точно знаем, что начальство коварное и будет проверять работу этого скрипта в директориях, которые не являются локальными репозиториями.  
[task_3.py](task_3.py)
### Ваш скрипт:
```python
#!/usr/bin/env python3

import os
import argparse

parser = argparse.ArgumentParser(description='Выводит список модифицированных файлов в локальном Git-репозитории')
parser.add_argument('-p', '--path', required=True, help='путь до Git-репозитория')
args = parser.parse_args()
repo_path = args.path

if os.path.exists(repo_path):

    if os.path.isfile(repo_path):
        print('\n[ОШИБКА]: ' + repo_path + ' является файлом, а не каталогом')
        print(parser.print_help())

    elif os.path.isdir(repo_path) and os.path.exists(repo_path + '/.git/config') and os.path.isfile(repo_path + '/.git/config'):
        bash_command = ["cd " + repo_path, "git status"]
        result_os = os.popen(' && '.join(bash_command)).read()

        # Массив для хранения файлов, которые были изменены:
        modified_files = []

        for result in result_os.split('\n'):
            if result.find('modified') != -1:
                # Если в '--path PATH' передан относительный путь, то делаем его абсолютным,
                # чтобы потом выводить абсолютный путь до модифицированных файлов:
                if not os.path.isabs(repo_path):
                    repo_path = os.path.abspath(repo_path)
                prepare_result = result.replace('\tmodified:   ', '')
                modified_file = os.path.join(repo_path.rstrip('\n'), prepare_result)
                # или другой вариант конкатенации строк:
                # modified_file = repo_path.rstrip('\n') + '/' + prepare_result
                modified_files.append(modified_file)

        print('\nВ репозитории модифицированы файлы:\n')
        for file in modified_files:
            print(file)

        print('\nАтрибуты модифицированных файлов:\n')
        for file in modified_files:
            # list_command = 'ls -l' + ' ' + file
            print(os.popen('ls -l' + ' ' + file).read().rstrip('\n'))

    else:
        print('\n[ОШИБКА]: В данном каталоге ' + repo_path + ' нет Git-репозитория')
        print(parser.print_help())
else:
    print('\n[ОШИБКА]: Каталог ' + repo_path + ' не существует. Укажите корректный путь до Git-репозитория')

```

### Вывод скрипта при запуске при тестировании:
```shell
vagrant@test-netology:~$
 ll netology/
total 4
drwxrwxr-x 20 vagrant vagrant 4096 Dec 24 20:57 sysadm-homeworks
-rw-rw-r--  1 vagrant vagrant    0 Dec 26 19:46 sysadm-homeworks_file
lrwxrwxrwx  1 vagrant vagrant   26 Dec 26 19:46 sysadm-homeworks_link -> netology/sysadm-homeworks/

vagrant@test-netology:~$
 ./task_3.py 
usage: task_3.py [-h] -p PATH
task_3.py: error: the following arguments are required: -p/--path

vagrant@test-netology:~$
 ./task_3.py -h
usage: task_3.py [-h] -p PATH

Выводит список модифицированных файлов в локальном Git-репозитории

optional arguments:
  -h, --help            show this help message and exit
  -p PATH, --path PATH  путь до Git-репозитория

vagrant@test-netology:~$
 ./task_3.py /home/vagrant/netology/sysadm-homeworks
usage: task_3.py [-h] -p PATH
task_3.py: error: the following arguments are required: -p/--path

vagrant@test-netology:~$
 ./task_3.py -p /home/vagrant/netology/sysadm-homeworks

В репозитории модифицированы файлы:

/home/vagrant/netology/sysadm-homeworks/01-intro-01/README.md
/home/vagrant/netology/sysadm-homeworks/04-script-01-bash/README.md
/home/vagrant/netology/sysadm-homeworks/README.md

Атрибуты модифицированных файлов:

-rw-rw-r-- 1 vagrant vagrant 6724 Dec 24 21:06 /home/vagrant/netology/sysadm-homeworks/01-intro-01/README.md
-rw-rw-r-- 1 vagrant vagrant 2891 Dec 24 22:32 /home/vagrant/netology/sysadm-homeworks/04-script-01-bash/README.md
-rw-rw-r-- 1 vagrant vagrant 3699 Dec 24 21:06 /home/vagrant/netology/sysadm-homeworks/README.md

vagrant@test-netology:~$
 ./task_3.py -p netology/sysadm-homeworks

В репозитории модифицированы файлы:

/home/vagrant/netology/sysadm-homeworks/01-intro-01/README.md
/home/vagrant/netology/sysadm-homeworks/04-script-01-bash/README.md
/home/vagrant/netology/sysadm-homeworks/README.md

Атрибуты модифицированных файлов:

-rw-rw-r-- 1 vagrant vagrant 6724 Dec 24 21:06 /home/vagrant/netology/sysadm-homeworks/01-intro-01/README.md
-rw-rw-r-- 1 vagrant vagrant 2891 Dec 24 22:32 /home/vagrant/netology/sysadm-homeworks/04-script-01-bash/README.md
-rw-rw-r-- 1 vagrant vagrant 3699 Dec 24 21:06 /home/vagrant/netology/sysadm-homeworks/README.md

vagrant@test-netology:~$
 ./task_3.py -p netology/sysadm-homeworks_file

[ОШИБКА]: netology/sysadm-homeworks_file является файлом, а не каталогом
usage: task_3.py [-h] -p PATH

Выводит список модифицированных файлов в локальном Git-репозитории

optional arguments:
  -h, --help            show this help message and exit
  -p PATH, --path PATH  путь до Git-репозитория
None

vagrant@test-netology:~$
 ./task_3.py -p netology/sysadm-homeworks_link

[ОШИБКА]: Каталог netology/sysadm-homeworks_link не существует. Укажите корректный путь до Git-репозитория

vagrant@test-netology:~$
 ./task_3.py -p netology

[ОШИБКА]: В данном каталоге netology нет Git-репозитория
usage: task_3.py [-h] -p PATH

Выводит список модифицированных файлов в локальном Git-репозитории

optional arguments:
  -h, --help            show this help message and exit
  -p PATH, --path PATH  путь до Git-репозитория
None

```

## Обязательная задача 4
1. Наша команда разрабатывает несколько веб-сервисов, доступных по http. Мы точно знаем, что на их стенде нет никакой балансировки, кластеризации, за DNS прячется конкретный IP сервера, где установлен сервис. Проблема в том, что отдел, занимающийся нашей инфраструктурой очень часто меняет нам сервера, поэтому IP меняются примерно раз в неделю, при этом сервисы сохраняют за собой DNS имена. Это бы совсем никого не беспокоило, если бы несколько раз сервера не уезжали в такой сегмент сети нашей компании, который недоступен для разработчиков. Мы хотим написать скрипт, который опрашивает веб-сервисы, получает их IP, выводит информацию в стандартный вывод в виде: <URL сервиса> - <его IP>. Также, должна быть реализована возможность проверки текущего IP сервиса c его IP из предыдущей проверки. Если проверка будет провалена - оповестить об этом в стандартный вывод сообщением: [ERROR] <URL сервиса> IP mismatch: <старый IP> <Новый IP>. Будем считать, что наша разработка реализовала сервисы: `drive.google.com`, `mail.google.com`, `google.com`.  
[task_4.py](task_4.py)  
### Ваш скрипт:
```python
#!/usr/bin/env python3

import socket
import requests

sevices_list = {"drive.google.com": "N/A", "mail.google.com": "N/A", "google.com": "N/A"}

while True:
    for key, value in sevices_list.items():
        previous_value = value
        new_value = socket.gethostbyname(key)
        if previous_value != new_value:
            print('[ERROR]: ' + key + ' IP mismatch: ' + previous_value + ' ' + new_value)

        try:
            response = requests.get('http://' + new_value, timeout=1)
            if response.status_code == 200:
                print('Service http:// ' + key + ' available. HTTP_RESPONSE ' + str(response.status_code))
        except requests.ConnectTimeout:
            print('[ERROR]: ' + key + ' ' + str(requests.ConnectTimeout))
        except requests.ConnectionError:
            print('[ERROR]: ' + key + ' ' + str(requests.ConnectionError))
        sevices_list[key] = new_value

```


Для симуляции изменения IP сервисов во время работы скрипта редактировался файл `/etc/hosts`:
```shell
1.2.3.4 drive.google.com
9.8.7.6 mail.google.com  
```
### Вывод скрипта при запуске при тестировании:  
```shell
vagrant@test-netology:~$
 ./task_4.py 
[ERROR]: drive.google.com IP mismatch: N/A 142.250.150.194
Service http:// drive.google.com available. HTTP_RESPONSE 200
[ERROR]: mail.google.com IP mismatch: N/A 173.194.73.19
Service http:// mail.google.com available. HTTP_RESPONSE 200
[ERROR]: google.com IP mismatch: N/A 108.177.14.100
Service http:// google.com available. HTTP_RESPONSE 200
Service http:// drive.google.com available. HTTP_RESPONSE 200
Service http:// mail.google.com available. HTTP_RESPONSE 200
Service http:// google.com available. HTTP_RESPONSE 200
Service http:// drive.google.com available. HTTP_RESPONSE 200
Service http:// mail.google.com available. HTTP_RESPONSE 200
Service http:// google.com available. HTTP_RESPONSE 200
Service http:// drive.google.com available. HTTP_RESPONSE 200
Service http:// mail.google.com available. HTTP_RESPONSE 200
Service http:// google.com available. HTTP_RESPONSE 200
Service http:// drive.google.com available. HTTP_RESPONSE 200
Service http:// mail.google.com available. HTTP_RESPONSE 200
Service http:// google.com available. HTTP_RESPONSE 200
Service http:// drive.google.com available. HTTP_RESPONSE 200
Service http:// mail.google.com available. HTTP_RESPONSE 200
Service http:// google.com available. HTTP_RESPONSE 200
Service http:// drive.google.com available. HTTP_RESPONSE 200
Service http:// mail.google.com available. HTTP_RESPONSE 200
Service http:// google.com available. HTTP_RESPONSE 200
Service http:// drive.google.com available. HTTP_RESPONSE 200
Service http:// mail.google.com available. HTTP_RESPONSE 200
Service http:// google.com available. HTTP_RESPONSE 200
Service http:// drive.google.com available. HTTP_RESPONSE 200
Service http:// mail.google.com available. HTTP_RESPONSE 200
Service http:// google.com available. HTTP_RESPONSE 200
Service http:// drive.google.com available. HTTP_RESPONSE 200
[ERROR]: mail.google.com IP mismatch: 173.194.73.19 9.8.7.6
[ERROR]: mail.google.com <class 'requests.exceptions.ConnectTimeout'>
Service http:// google.com available. HTTP_RESPONSE 200
Service http:// drive.google.com available. HTTP_RESPONSE 200
[ERROR]: mail.google.com <class 'requests.exceptions.ConnectTimeout'>
Service http:// google.com available. HTTP_RESPONSE 200
Service http:// drive.google.com available. HTTP_RESPONSE 200
[ERROR]: mail.google.com <class 'requests.exceptions.ConnectTimeout'>
Service http:// google.com available. HTTP_RESPONSE 200
Service http:// drive.google.com available. HTTP_RESPONSE 200
[ERROR]: mail.google.com <class 'requests.exceptions.ConnectTimeout'>
Service http:// google.com available. HTTP_RESPONSE 200
Service http:// drive.google.com available. HTTP_RESPONSE 200
[ERROR]: mail.google.com <class 'requests.exceptions.ConnectTimeout'>
Service http:// google.com available. HTTP_RESPONSE 200
Service http:// drive.google.com available. HTTP_RESPONSE 200
[ERROR]: mail.google.com <class 'requests.exceptions.ConnectTimeout'>
Service http:// google.com available. HTTP_RESPONSE 200
Service http:// drive.google.com available. HTTP_RESPONSE 200
[ERROR]: mail.google.com <class 'requests.exceptions.ConnectTimeout'>
Service http:// google.com available. HTTP_RESPONSE 200
Service http:// drive.google.com available. HTTP_RESPONSE 200
[ERROR]: mail.google.com <class 'requests.exceptions.ConnectTimeout'>
Service http:// google.com available. HTTP_RESPONSE 200
Service http:// drive.google.com available. HTTP_RESPONSE 200
[ERROR]: mail.google.com <class 'requests.exceptions.ConnectTimeout'>
Service http:// google.com available. HTTP_RESPONSE 200
[ERROR]: drive.google.com IP mismatch: 142.250.150.194 1.2.3.4
[ERROR]: drive.google.com <class 'requests.exceptions.ConnectTimeout'>
[ERROR]: mail.google.com <class 'requests.exceptions.ConnectTimeout'>
Service http:// google.com available. HTTP_RESPONSE 200
[ERROR]: drive.google.com <class 'requests.exceptions.ConnectTimeout'>
[ERROR]: mail.google.com <class 'requests.exceptions.ConnectTimeout'>
Service http:// google.com available. HTTP_RESPONSE 200
[ERROR]: drive.google.com <class 'requests.exceptions.ConnectTimeout'>
[ERROR]: mail.google.com <class 'requests.exceptions.ConnectTimeout'>
Service http:// google.com available. HTTP_RESPONSE 200
[ERROR]: drive.google.com <class 'requests.exceptions.ConnectTimeout'>
[ERROR]: mail.google.com <class 'requests.exceptions.ConnectTimeout'>
Service http:// google.com available. HTTP_RESPONSE 200
[ERROR]: drive.google.com <class 'requests.exceptions.ConnectTimeout'>
[ERROR]: mail.google.com IP mismatch: 9.8.7.6 173.194.73.19
Service http:// mail.google.com available. HTTP_RESPONSE 200
Service http:// google.com available. HTTP_RESPONSE 200
[ERROR]: drive.google.com <class 'requests.exceptions.ConnectTimeout'>
Service http:// mail.google.com available. HTTP_RESPONSE 200
Service http:// google.com available. HTTP_RESPONSE 200
[ERROR]: drive.google.com <class 'requests.exceptions.ConnectTimeout'>
Service http:// mail.google.com available. HTTP_RESPONSE 200
Service http:// google.com available. HTTP_RESPONSE 200
[ERROR]: drive.google.com <class 'requests.exceptions.ConnectTimeout'>
Service http:// mail.google.com available. HTTP_RESPONSE 200
Service http:// google.com available. HTTP_RESPONSE 200
[ERROR]: drive.google.com <class 'requests.exceptions.ConnectTimeout'>
Service http:// mail.google.com available. HTTP_RESPONSE 200
Service http:// google.com available. HTTP_RESPONSE 200
[ERROR]: drive.google.com <class 'requests.exceptions.ConnectTimeout'>
Service http:// mail.google.com available. HTTP_RESPONSE 200
Service http:// google.com available. HTTP_RESPONSE 200
[ERROR]: drive.google.com IP mismatch: 1.2.3.4 142.250.150.194
Service http:// drive.google.com available. HTTP_RESPONSE 200
Service http:// mail.google.com available. HTTP_RESPONSE 200
Service http:// google.com available. HTTP_RESPONSE 200
Service http:// drive.google.com available. HTTP_RESPONSE 200
Service http:// mail.google.com available. HTTP_RESPONSE 200

```
