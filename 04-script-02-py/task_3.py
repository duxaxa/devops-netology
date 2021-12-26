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
