### 1. Какой системный вызов делает команда `cd`?  
Получаем вывод команды `strace` и записываем его в файл `cd_strace.out`:  
```shell
strace -o cd_strace.out -s 64 bash -c 'cd /var/log'
```  
Смотрим в полученный файл с выводом работы `strace`. Видим, что для изменения каталога команда `cd` делает 
системный вызов `chdir()`  :
```shell
chdir("/var/log")
```  
Тоже самое, но в одной строке:  
```shell
vagrant@test-netology:~/aaa
> strace -s 64 bash -c 'cd /var/log' 2>&1 | grep '/var/log'
execve("/usr/bin/bash", ["bash", "-c", "cd /var/log"], 0x7ffc4fd345c0 /* 25 vars */) = 0
stat("/var/log", {st_mode=S_IFDIR|0775, st_size=4096, ...}) = 0
chdir("/var/log") 
```  
системный вызов `stat()` получает информацию о каталоге, в который нужно перейти, а `chdir()` выполняет переход 
в каталог.  


### 2. Используя `strace` выясните, где находится база данных `file`  
Получаем вывод команды `strace`, фильтруем его по *"open"* (т.к. нужен список всех открываемых файлов):  
```shell
vagrant@test-netology:~/aaa
> strace file toplink 2>&1 | grep open
openat(AT_FDCWD, "/etc/ld.so.cache", O_RDONLY|O_CLOEXEC) = 3
openat(AT_FDCWD, "/lib/x86_64-linux-gnu/libmagic.so.1", O_RDONLY|O_CLOEXEC) = 3
openat(AT_FDCWD, "/lib/x86_64-linux-gnu/libc.so.6", O_RDONLY|O_CLOEXEC) = 3
openat(AT_FDCWD, "/lib/x86_64-linux-gnu/liblzma.so.5", O_RDONLY|O_CLOEXEC) = 3
openat(AT_FDCWD, "/lib/x86_64-linux-gnu/libbz2.so.1.0", O_RDONLY|O_CLOEXEC) = 3
openat(AT_FDCWD, "/lib/x86_64-linux-gnu/libz.so.1", O_RDONLY|O_CLOEXEC) = 3
openat(AT_FDCWD, "/lib/x86_64-linux-gnu/libpthread.so.0", O_RDONLY|O_CLOEXEC) = 3
openat(AT_FDCWD, "/usr/lib/locale/locale-archive", O_RDONLY|O_CLOEXEC) = 3
openat(AT_FDCWD, "/etc/magic.mgc", O_RDONLY) = -1 ENOENT (No such file or directory)
openat(AT_FDCWD, "/etc/magic", O_RDONLY) = 3
openat(AT_FDCWD, "/usr/share/misc/magic.mgc", O_RDONLY) = 3
openat(AT_FDCWD, "/usr/lib/x86_64-linux-gnu/gconv/gconv-modules.cache", O_RDONLY) = 3
```
Системный вызов `openat()` открывает файлы, требуемые `file` для получения информации о файле *toplink*. 
Файлы с именем по шаблону `/lib/x86_64-linux-gnu/lib*.so.*` не могут быть базой данных, т.к. это библиотеки с
кодом (а точнее - ссылки на библиотеки), вызываемый командой `file`. Убедиться в этом можно так же командой `ldd`,
которая покажет зависимости для `find`:      
```shell
vagrant@test-netology:~/aaa
> ldd /usr/bin/file 
	linux-vdso.so.1 (0x00007ffc90d9f000)
	libmagic.so.1 => /lib/x86_64-linux-gnu/libmagic.so.1 (0x00007f632c5ed000)
	libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007f632c3fb000)
	liblzma.so.5 => /lib/x86_64-linux-gnu/liblzma.so.5 (0x00007f632c3d2000)
	libbz2.so.1.0 => /lib/x86_64-linux-gnu/libbz2.so.1.0 (0x00007f632c3bf000)
	libz.so.1 => /lib/x86_64-linux-gnu/libz.so.1 (0x00007f632c3a3000)
	/lib64/ld-linux-x86-64.so.2 (0x00007f632c625000)
	libpthread.so.0 => /lib/x86_64-linux-gnu/libpthread.so.0 (0x00007f632c380000)
```  
Файл `/etc/magic` - обычный текстовый конфигурационный файл, не наш случай:  
```shell
stat("/etc/magic", {st_mode=S_IFREG|0644, st_size=111, ...}) = 0
openat(AT_FDCWD, "/etc/magic", O_RDONLY) = 3
fstat(3, {st_mode=S_IFREG|0644, st_size=111, ...}) = 0
read(3, "# Magic local data for file(1) c"..., 4096) = 111
read(3, "", 4096)                       = 0
close(3)
```
Остается `/usr/share/misc/magic.mgc`, - это ссылка на файл `/usr/lib/file/magic.mgc`:  
```shell
vagrant@test-netology:~/aaa
> file /usr/lib/file/magic.mgc
/usr/lib/file/magic.mgc: magic binary file for file(1) cmd (version 14) (little endian)
```  
Это и есть база данных, из которой `file` читает информацию о типах файлов.  


### 3. Если файл, в который производится запись, был удален во время работы процесса, выполняющего запись в этот файл,  
то освободить место на файловой системе можно отправив `null` в файловый дескриптор, соответсвующий удаленному файлу:  
- скриптом [start.sh](start.sh) инициируем бесконечную запись в файл `random.log`:  
    ```shell
    vagrant@test-netology:~/aaa
    > ./start.sh &
    [1] 4751
    vagrant@test-netology:~/aaa
    > Script ./start.sh running with PID: 4751
    ```
- проверяем, что файл увеличивается в размере:  
    ```shell
    vagrant@test-netology:~/aaa
    > du -h random.log; sleep 10; du -h random.log
    270M	random.log
    294M	random.log
    ```  
- удалям файл `random.log`, проверяем, что место на файловой системе `/` продолжает уменьшаться:  
    ```shell
    vagrant@test-netology:~/aaa
    > rm random.log 
    vagrant@test-netology:~/aaa
    > df -m / | awk '{ print $4 }'; sleep 10; df -m / | awk '{ print $4 }'
    Available
    55260
    Available
    55236
    ```  
- проверяем, что `lsof` показывает файл как удаленный:  
    ```shell
    vagrant@test-netology:~/aaa
    > lsof -p $(cat pid.file) | grep random.log
    bash    4751 vagrant    1w   REG  253,0 3236336061 131086 /home/vagrant/aaa/random.log (deleted)
    bash    4751 vagrant   10w   REG  253,0 3236336061 131086 /home/vagrant/aaa/random.log (deleted)
    ```  
- обнуляем дескриптор `10`, соответсвующий удаленному файлу. До и после удаления проверяем место на файловой системе `/`:  
    ```shell
    vagrant@test-netology:~/aaa
    > df -m / | awk '{ print $4 }'; cat /dev/null > /proc/$(cat pid.file)/fd/10; df -m / | awk '{ print $4 }'
    Available
    53992
    Available
    57980
    ```
    и видим, что после обнуления дескриптора `cat /dev/null > /proc/$(cat pid.file)/fd/10` место на файловой системе 
высвободилось. Но пока продолжает работу процесс, выполняющий запись в удаленный файл `random.log`, место на файловой 
системе продолжит уменьшаться, т.к. новые данные продолжают записываться в дескриптор `10`.  
- скриптом [stop.sh](stop.sh) остановим процесс и проверим доступное на файловой системе место. Увидим, что после 
остановки процесса, место на файловой системе вернулось к значению **57980**:  
    ```shell
    vagrant@test-netology:~/aaa
    > ./stop.sh 
    Stoping proccess with PID: 4751
    [OK] Proccess with PID 4751 was successfully terminated!
    vagrant@test-netology:~/aaa
    > df -m / | awk '{ print $4 }'
    Available
    57980
    [1]+  Terminated              ./start.sh
    ```  

### 4. Занимают ли зомби-процессы какие-то ресурсы в ОС (CPU, RAM, IO)?    
Как минимум, зомби процессы занимаю ресурсы:
- RAM, т.к. код завершения зомби-процесса не был обработан родительским процессом, а значит код завершения хранится 
в памяти
- Таблица процессов, тоже хранящаяся в RAM. Т.к. размер таблицы ограничен 64 килобайтами, то большое количество 
зомби процессов может стать проблемой для производительности системы в целом

CPU и IO не должны расходоваться зомби процессами, т.к. по сути они не выполняют никаких действий.  


### 5. Утилита `opensnoop`  
За первую секунду работу утилиты были открыты файлы:  
- `/usr/lib/python3.8/_sitebuiltins.py`
- `/usr/lib/python3/dist-packages/bcc/table.py`
```shell
root@test-netology:~# opensnoop-bpfcc -d 1 | sort | uniq
5950   opensnoop-bpfcc    11   0 PID    COMM               FD ERR PATH
5950   opensnoop-bpfcc    11   0 /usr/lib/python3.8/_sitebuiltins.py
5950   opensnoop-bpfcc    11   0 /usr/lib/python3/dist-packages/bcc/table.py
```  


### 6. Какой системный вызов использует `uname -a`? Приведите цитату из `man` по этому системному вызову, где описывается альтернативное местоположение в `/proc`, где можно узнать версию ядра и релиз ОС.  
`uname -a` использует системный вызов `uname()`:  
```shell
uname({sysname="Linux", nodename="test-netology", ...}) = 0
```  
Цитата из `man 2 uname`:  

    NAME
        uname - get name and information about current kernel
    
    NOTES
    
        Part of the utsname information is also accessible via /proc/sys/kernel/{ostype, hostname,
        osrelease, version, domainname}.
Т.о., альтернативный способ узнать версию ОС, это прочитать следующие файлы:  
```shell
vagrant@test-netology:~
> cat /proc/sys/kernel/{ostype,osrelease,version}
Linux
5.4.0-80-generic
#90-Ubuntu SMP Fri Jul 9 22:49:44 UTC 2021
```  


### 7. Чем отличается последовательность команд через `;` и через `&&` в bash?  
Если команды разделены друг от друга символом `;`, то каждая из последующих команда в цепочке будет поочередно 
выполнены независимо от того, успешно ли завершилась предыдущая команда. Т.е. все перечисленный команды будут 
выполнены в любом случае.  
Если команды разделены друг от друга символами `&&` (логическая операция `AND`), то следующая команда выполнится 
только в том случае, если предыдущая команда завершилась успешно без ошибок и предупреждений (с кодом завершения `0`).  
`set -e` устанавливает для командной оболочки режим, при котором происходит немедленный выход из командной оболочки в
случае, если команда завершилась ошибкой (код завершения команды не равен `0`):  
```shell
vagrant@test-netology:~/aaa
> set +e
vagrant@test-netology:~/aaa
> ll aa
ls: cannot access 'aa': No such file or directory
vagrant@test-netology:~/aaa
> set -e
vagrant@test-netology:~/aaa
> ll aa
ls: cannot access 'aa': No such file or directory
Connection closing...Socket close.
Connection closed by foreign host.
Disconnected from remote host(localhost:2222) at 22:31:50.
```  
Смысл использовать в bash `&&` при установленном режиме оболочки `set -e` есть, т.к. в случае использования `&&` для
выполнения конвейера команд действие режима `set -e` не распространяется и выхода из оболочки не произойдет в случае 
возникновения ошибки в первой из двух команд в конвейере. Если в конвейере больше двух команд, то выхода из оболочки 
не произойдет при возникновении ошибки в любой команде, кроме самой последней (правой):  
```shell
vagrant@test-netology:~/aaa
> set +e
vagrant@test-netology:~/aaa
> ll a && ll b
ls: cannot access 'a': No such file or directory
vagrant@test-netology:~/aaa
> set -e
vagrant@test-netology:~/aaa
> ll a && ll b
ls: cannot access 'a': No such file or directory
vagrant@test-netology:~/aaa
> ll a
ls: cannot access 'a': No such file or directory
Connection closing...Socket close.
Connection closed by foreign host.
Disconnected from remote host(localhost:2222) at 22:41:52.
```
НО: произойдет выход из оболочки, если ошибка возникнет в самой последней (правой) команде конвейера:  
```shell
vagrant@test-netology:~/aaa
> set -e
vagrant@test-netology:~/aaa
> ll 1 && ll 2
ls: cannot access '1': No such file or directory
vagrant@test-netology:~/aaa
> ll start.sh && ll 2
-rwxrwxr-x 1 vagrant vagrant 243 Nov 18 15:27 start.sh*
ls: cannot access '2': No such file or directory
Connection closing...Socket close.
Connection closed by foreign host.
Disconnected from remote host(localhost:2222) at 22:43:37.
```


### 8. Из каких опций состоит режим bash `set -euxo pipefail` и почему его хорошо было бы использовать в сценариях?  

Состоит из следующих опций:  

- `-e`, немедленно выйти из оболочки, если конвейер, который может состоять из одной простой команды, списка или
составных команд, завершается с ненулевым статусом. НО: оболочка не завершит работу, если неудачная команда является 
частью списка команд сразу после ключевых слов `while` или `until`, частью теста, следующей за зарезервированными 
словами `if` или `elif`, частью любой команды, выполняемой в `&&` или `||`, кроме команды, следующей за последним 
`&&` или `||`, любой команды в конвейере, кроме последней, или если возвращаемое значение команды инвертируется 
с помощью `!`. *Опция может быть полезна для отладки сценариев оболочки: позволяет выявлять точки отказа в сценариях*.
- `-o pipefail`, если опция установлена, возвращаемое значение конвейера - это значение последней (самой правой) 
команды для выхода с ненулевым статусом или ноль, если все команды в конвейере завершаются успешно. 
*Опция может быть полезна в сценариях, если требуется знать и обрабатывать код завершения результата работы конвейера команд 
в скрипте*.  
- `-u`, обрабатывать неустановленные переменные и параметры, отличные от специальных параметров `«@»` и `«*»`, как 
ошибку при выполнении раскрытия параметров. Если выполняется попытка раскрытия неустановленной переменной или 
параметра, то оболочка печатает сообщение об ошибке. Если оболочка работает не в интерактивном режиме, то завершить 
работу с ненулевым статусом выхода. *Опция может быть полезна в сценариях для контроля использования переменных без 
значения либо переменных, которые не были определены*.  
- `-x`, после раскрытия каждой простой команды, команды `for`, команды `case`, команды `select` или арифметической `for`
команды, отобразить развернутое значение переменной `PS4`, за которым следует команда и раскрытые аргументы или 
связанный список слов. *Опция может быть полезна для отладки: для контроля выполнения и результата работы каждой 
команды, т.к. выводит факт выполнения команды в строку с `+` и результат подстановок команд в строку `++`*.  

Если подвести обобщенный итог, то использование режима bash, устанавливаемого опциями `set -euxo pipefail`, полезно 
для комплексной отладки сценариев перед их использованием на реальных повседневных задачах.  


### 9. Используя `-o stat` для `ps`, определите, какой наиболее часто встречающийся статус у процессов в системе.  
```shell
vagrant@test-netology:~
> ps -o stat
STAT
Ss
R+
```
Наиболее встречающиеся статусы процессов:  
`Ss` - спящий (sleeping) лидирующий процесс, ожидающий завершения какого либо события  
`R+` - работающий или работоспособный (running or runnable) процесс, выполняющийся в данный момент времени в
фоновом режиме.