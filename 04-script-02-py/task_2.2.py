#!/usr/bin/env python3

import os

bash_command = ["cd ~/netology/sysadm-homeworks", 'for line in $(git status | grep modified | sed "s/\\tmodified:   //"); do ls -l $(pwd)/${line}; done']

result_os = os.popen(' && '.join(bash_command)).read()
print("\nМодифицированные файлы:\n\n" + result_os)