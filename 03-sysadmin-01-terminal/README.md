#### Виртуальной машине, созданной **Vagrant**'ом, по умолчанию выделены ресурсы:    
Оперативная память: `1024 МБ`  
Процессоры: `2`  
Видеопамять: `4 МБ`  
Диск (HDD): `64 ГБ`  

#### Чтобы добавить виртуальной машине оперативной памяти или ресурсов процессора,
нужно в конфигурационном файле `Vagrantfile` данной ВМ добавить|отредактировать
параметры `vb.memory = "2048"` и `vb.cpus = "3"`:
``` dsfsdf
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-20.04"
  config.vm.hostname = "test-netology"

  config.vm.provider "virtualbox" do |vb|
    vb.gui = false
    vb.name= "test-netology"
    
    # Увеличиваем объем RAM для VM с 1024 до 2048 МБ:
    vb.memory = "2048"
    
    # Увеличиваем количество CPU для VM с 2 до 3:
    vb.cpus = "3"
  end
end
```
#### Длина журнала `history` задается значением переменной `HISTSIZE`  
Описание переменной `HISTSIZE` приведено на строке 839:

       HISTSIZE  

              The  number of commands to remember in the command history (see HISTORY below).  If the value is 0, commands
              are not saved in the history list.  Numeric values less than zero result in every command being saved on the
              history list (there is no limit).  The shell sets the default value to 500 after reading any startup files.
#### Директива `ignoreboth` для переменной `HISTCONTROL` объединяет в себе две других директивы:   
`ignorespace` - не сохранять в `history` команды, если они начинаются с пробела;  
`ignoredups` - не сохранять в `history` команду, если она полность эквивалентна предыдущей 
введенной команде;  
#### Скобки `{  }` могут использоваться в следующих сценариях:  
- В описании функции командной оболочки. В этом случае в скобках `{ }` пишется код тела функции. 
Строка 390 в `man bash`. Например:  
    ```shell
      function hello_my_darling() {
          echo "Hello, Amigo !"
      }
    ```
- В механизме подстановок (Brace Expantion). Строка 1062 в `man bash`. Например, одной командой
можно создать несколько каталогов по заданному шаблону.    

    Перечислением:
    ```shell
    vagrant@test-netology:~
    # mkdir -p folder_{1,2,3}
    vagrant@test-netology:~
    # ls -l
    total 12
    drwxrwxr-x 2 vagrant vagrant 4096 Nov 13 17:31 folder_1
    drwxrwxr-x 2 vagrant vagrant 4096 Nov 13 17:31 folder_2
    drwxrwxr-x 2 vagrant vagrant 4096 Nov 13 17:31 folder_3
    ```
    Диапазоном:
    ```shell
    vagrant@test-netology:~
    # touch my_file_{01..5}
    vagrant@test-netology:~
    # ls -l
    total 0
    -rw-rw-r-- 1 vagrant vagrant 0 Nov 13 17:38 my_file_01
    -rw-rw-r-- 1 vagrant vagrant 0 Nov 13 17:38 my_file_02
    -rw-rw-r-- 1 vagrant vagrant 0 Nov 13 17:38 my_file_03
    -rw-rw-r-- 1 vagrant vagrant 0 Nov 13 17:38 my_file_04
    -rw-rw-r-- 1 vagrant vagrant 0 Nov 13 17:38 my_file_05
    ```
- В механизме подстановок для переменных (Parameter Expantion). Строка 1130 в `man bash`. Например:  
    ```shell
    vagrant@test-netology:~
    # VAR="Hello"
    vagrant@test-netology:~
    # echo "Crazy World, ${VAR}"
    Crazy World, Hello
    ```
  Так же с помощью механизма подстановок в переменных можно задать для переменной значение
по умолчанию, алтернативное значение, если переменной не было присвоено никакое значение, или если переменная была
 обнулена.
#### Чтобы создать однократным вызовом 100000 файлов, сделаем так:  
   ```shell
   agrant@test-netology:~/aaa
   # rm -rf *
   vagrant@test-netology:~/aaa
   # touch file_{1..100000}
   vagrant@test-netology:~/aaa
   # ls file_* | wc -l
   100000
   ```
Создать таким же способом 300000 файлов не получится из-за ошибки:  
```shell
vagrant@test-netology:~/aaa
# touch file_{1..300000}
-bash: /usr/bin/touch: Argument list too long
```
Но можно решить проблему с помощью цикла и подставновки диапазона от 1 до 300000:  
```shell
vagrant@test-netology:~/aaa
# rm -rf *
vagrant@test-netology:~/aaa
# for i in {1..300000}; do touch file_$i; done; ls | wc -l
300000
```  
#### Конструкция `[[ -d /tmp ]]` - это логическое выражение:  
Если файл `/tmp` существует и это файл является каталогом, то выражение вернет `true`
(статус `0`), если файл `/tmp` не существует, то выражение вернет `false` (статус `1`)  
#### PATH:
```shell
vagrant@test-netology:~
# type -a bash
bash is /usr/bin/bash
bash is /bin/bash
vagrant@test-netology:~
# mkdir -p /tmp/new_path_directory
vagrant@test-netology:~
# cp /usr/bin/bash /tmp/new_path_directory
vagrant@test-netology:~
# PATH=/tmp/new_path_directory:$PATH
vagrant@test-netology:~
# type -a bash
bash is /tmp/new_path_directory/bash
bash is /usr/bin/bash
bash is /bin/bash
vagrant@test-netology:~
# /tmp/new_path_directory/bash --version
/tmp/new_path_directory/bash --version
GNU bash, version 5.0.17(1)-release (x86_64-pc-linux-gnu)
Copyright (C) 2019 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>

This is free software; you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.
```
#### Отличия между `batch` и `at`:  
`batch` -  выполнит команду (скрипт) единоразово только тогда, когда это позволит уровень нагрузки `(load average)` на 
систему; уровень загрузки системы, при котором нужно выполнить команду (скрипт) дополнительно
задается с помощью утилиты `atd`  
`aq` - выполнит команду (скрипт) единоразово в установленное время