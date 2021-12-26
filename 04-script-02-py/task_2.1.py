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
