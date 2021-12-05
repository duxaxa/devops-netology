### 1. Проверьте список доступных сетевых интерфейсов на вашем компьютере. Какие команды есть для этого в Linux и в Windows?  
Windows:  
```shell
PS C:\Users\duxaxa> netsh interface show interface

Состояние адм.  Состояние     Тип              Имя интерфейса
---------------------------------------------------------------------
Разрешен       Отключен       Выделенный       Ethernet 2
Разрешен       Подключен      Выделенный       Ethernet 3
Разрешен       Подключен      Выделенный       VMware Network Adapter VMnet1
Разрешен       Подключен      Выделенный       VMware Network Adapter VMnet8
Разрешен       Подключен      Выделенный       Беспроводная сеть 2
Разрешен       Отключен       Выделенный       Ethernet
```
Linux:  
```shell
vagrant@test-netology:~$
 ip link
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP mode DEFAULT group default qlen 1000
    link/ether 08:00:27:73:60:cf brd ff:ff:ff:ff:ff:ff

# тоже самое в краткой форме и более читабельном виде:
vagrant@test-netology:~$
 ip -br link
lo               UNKNOWN        00:00:00:00:00:00 <LOOPBACK,UP,LOWER_UP> 
eth0             UP             08:00:27:73:60:cf <BROADCAST,MULTICAST,UP,LOWER_UP

# вывод информации об IP, но фактически тоже содержит инфо об интерфейсах:
vagrant@test-netology:~$
 ip address
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:73:60:cf brd ff:ff:ff:ff:ff:ff
    inet 10.0.2.15/24 brd 10.0.2.255 scope global dynamic eth0
       valid_lft 85553sec preferred_lft 85553sec
    inet6 fe80::a00:27ff:fe73:60cf/64 scope link 
       valid_lft forever preferred_lft forever

# тоже самое в краткой форме и более читабельном виде:
vagrant@test-netology:~$
 ip -br address
lo               UNKNOWN        127.0.0.1/8 ::1/128 
eth0             UP             10.0.2.15/24 fe80::a00:27ff:fe73:60cf/64

# использование ifconfig: вывод информации об IP, но фактически тоже содержит инфо об интерфейсах:
vagrant@test-netology:~$
 ifconfig -a
eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 10.0.2.15  netmask 255.255.255.0  broadcast 10.0.2.255
        inet6 fe80::a00:27ff:fe73:60cf  prefixlen 64  scopeid 0x20<link>
        ether 08:00:27:73:60:cf  txqueuelen 1000  (Ethernet)
        RX packets 4074  bytes 1457183 (1.4 MB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 2917  bytes 373480 (373.4 KB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
        inet 127.0.0.1  netmask 255.0.0.0
        inet6 ::1  prefixlen 128  scopeid 0x10<host>
        loop  txqueuelen 1000  (Local Loopback)
        RX packets 104  bytes 8220 (8.2 KB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 104  bytes 8220 (8.2 KB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
```

### 2. Какой протокол используется для распознавания соседа по сетевому интерфейсу? Какой пакет и команды есть в Linux для этого?  
**LLDP (Link Layer Discovery Protocol)** — протокол канального уровня, позволяющий сетевому оборудованию оповещать 
оборудование, работающее в локальной сети, о своём существовании и передавать ему свои характеристики, а также 
получать от него аналогичные сведения.  
```shell
root@test-netology:~#
 apt search lldp
Sorting... Done
Full Text Search... Done
ladvd/focal 1.1.2-1build1 amd64
  LLDP/CDP sender

liblldpctl-dev/focal 1.0.4-1build2 amd64
  implementation of IEEE 802.1ab (LLDP) - development files

lldpad/focal 1.0.1+git20200210.2022b0c-1 amd64
  Link Layer Discovery Protocol Implementation (Runtime)

lldpad-dev/focal 1.0.1+git20200210.2022b0c-1 amd64
  Link Layer Discovery Protocol Implementation (Development headers)

lldpd/focal 1.0.4-1build2 amd64
  implementation of IEEE 802.1ab (LLDP)
```
Установим этот: `lldpd` - implementation of IEEE 802.1ab (LLDP). Lk
```shell
root@test-netology:~#
 systemctl start lldpd

root@test-netology:~#
 systemctl status lldpd
● lldpd.service - LLDP daemon
     Loaded: loaded (/lib/systemd/system/lldpd.service; enabled; vendor preset: enabled)
     Active: active (running) since Sat 2021-12-04 17:34:18 UTC; 5min ago
       Docs: man:lldpd(8)
   Main PID: 2747 (lldpd)
      Tasks: 2 (limit: 467)
     Memory: 3.3M
     CGroup: /system.slice/lldpd.service
             ├─2747 lldpd: monitor.
             └─2756 lldpd: no neighbor.

Dec 04 17:34:18 test-netology systemd[1]: Started LLDP daemon.
Dec 04 17:34:18 test-netology lldpd[2756]: /etc/localtime copied to chroot
Dec 04 17:34:18 test-netology lldpd[2756]: protocol LLDP enabled
Dec 04 17:34:18 test-netology lldpd[2756]: protocol CDPv1 disabled
Dec 04 17:34:18 test-netology lldpd[2756]: protocol CDPv2 disabled
Dec 04 17:34:18 test-netology lldpd[2756]: protocol SONMP disabled
Dec 04 17:34:18 test-netology lldpd[2756]: protocol EDP disabled
Dec 04 17:34:18 test-netology lldpd[2756]: protocol FDP disabled
Dec 04 17:34:18 test-netology lldpd[2756]: libevent 2.1.11-stable initialized with epoll method
Dec 04 17:34:18 test-netology lldpcli[2755]: lldpd should resume operations

root@test-netology:~#
 lldpctl 
[lldpcli] # show interfaces
-------------------------------------------------------------------------------
LLDP interfaces:
-------------------------------------------------------------------------------
Interface:    eth0, via: unknown, Time: 0 day, 01:02:11
  Chassis:     
    ChassisID:    mac 08:00:27:73:60:cf
    SysName:      test-netology
    SysDescr:     Ubuntu 20.04.2 LTS Linux 5.4.0-80-generic #90-Ubuntu SMP Fri Jul 9 22:49:44 UTC 2021 x86_64
    MgmtIP:       10.0.2.15
    MgmtIP:       fe80::a00:27ff:fe73:60cf
    Capability:   Bridge, off
    Capability:   Router, off
    Capability:   Wlan, off
    Capability:   Station, on
  Port:        
    PortID:       mac 08:00:27:73:60:cf
    PortDescr:    eth0
  TTL:          120
-------------------------------------------------------------------------------
[lldpcli] # show chassis
-------------------------------------------------------------------------------
Local chassis:
-------------------------------------------------------------------------------
Chassis:     
  ChassisID:    mac 08:00:27:73:60:cf
  SysName:      test-netology
  SysDescr:     Ubuntu 20.04.2 LTS Linux 5.4.0-80-generic #90-Ubuntu SMP Fri Jul 9 22:49:44 UTC 2021 x86_64
  MgmtIP:       10.0.2.15
  MgmtIP:       fe80::a00:27ff:fe73:60cf
  Capability:   Bridge, off
  Capability:   Router, off
  Capability:   Wlan, off
  Capability:   Station, on
-------------------------------------------------------------------------------
[lldpcli] # show neighbors
-------------------------------------------------------------------------------
LLDP neighbors:
-------------------------------------------------------------------------------
[lldpcli] #
```
Соседей не показывает. Вероятно из-за того, что на хостовой ОС Win10 не установлен NetLldpAgent 
[https://docs.microsoft.com/en-us/powershell/module/netlldpagent/?view=windowsserver2019-ps]

### 3. Какая технология используется для разделения L2 коммутатора на несколько виртуальных сетей? Какой пакет и команды есть в Linux для этого? Приведите пример конфига.  
**VLAN (Virtual Local Area Network)** - группа устройств, имеющих возможность взаимодействовать между собой напрямую 
на канальном уровне, хотя физически при этом они могут быть подключены к разным сетевым коммутаторам. И наоборот, 
устройства, находящиеся в разных VLAN'ах, невидимы друг для друга на канальном уровне, даже если они подключены к 
одному коммутатору, и связь между этими устройствами возможна только на сетевом и более высоких уровнях.  
Для работы с VLAN в Linux установим пакет `apt install vlan`.  

####Настройка VLAN в Linux:  
Добавление VLAN средствами `vconfig`:  
```shell
root@test-netology:~#
 ip -br link
lo               UNKNOWN        00:00:00:00:00:00 <LOOPBACK,UP,LOWER_UP> 
eth0             UP             08:00:27:73:60:cf <BROADCAST,MULTICAST,UP,LOWER_UP> 

root@test-netology:~#
 vconfig add eth0 777

Warning: vconfig is deprecated and might be removed in the future, please migrate to ip(route2) as soon as possible!


root@test-netology:~#
 ip address add 10.0.2.16/24 dev eth0.777

root@test-netology:~#
 ip link set eth0.777 up

root@test-netology:~#
 ip -br -c a
lo               UNKNOWN        127.0.0.1/8 ::1/128 
eth0             UP             10.0.2.15/24 fe80::a00:27ff:fe73:60cf/64 
eth0.777@eth0    UP             10.0.2.16/24 fe80::a00:27ff:fe73:60cf/64

root@test-netology:~#
 vconfig rem eth0.777
```  

Добавление VLAN средствами `ip`:  
```shell
root@test-netology:~#
 ip -br address
lo               UNKNOWN        127.0.0.1/8 ::1/128 
eth0             UP             10.0.2.15/24 fe80::a00:27ff:fe73:60cf/64 

root@test-netology:~#
 ip link add link eth0 name eth0.999 type vlan id 999

root@test-netology:~#
 ip address add 10.0.2.17/24 dev eth0.999

root@test-netology:~#
 ip link set eth0.999 up

root@test-netology:~#
 ip -br address
lo               UNKNOWN        127.0.0.1/8 ::1/128 
eth0             UP             10.0.2.15/24 fe80::a00:27ff:fe73:60cf/64 
eth0.999@eth0    UP             10.0.2.17/24 fe80::a00:27ff:fe73:60cf/64

root@test-netology:~#
 ip link delete eth0.999
```
#### Пример конфига для статичной конфигурации VLAN:
Описание структуры конфига в `man 5 interfaces` (debian-подобные дистрибутивы). Пример конфига:  
```shell
root@test-netology:~#
 ip -br -c a
lo               UNKNOWN        127.0.0.1/8 ::1/128 
eth0             UP             10.0.2.15/24 fe80::a00:27ff:fe73:60cf/64

root@test-netology:~#
 vi /etc/network/interfaces
# добавляем в конфиг:
auto eth0.555
iface eth0.555 inet static
      address 10.0.2.20/24
      vlan_raw_device eth0
      hwaddress random
      
root@test-netology:~#
 systemctl restart networking
      
root@test-netology:~#
 ip -br -c a
lo               UNKNOWN        127.0.0.1/8 ::1/128 
eth0             UP             10.0.2.15/24 fe80::a00:27ff:fe73:60cf/64 
eth0.555@eth0    UP             10.0.2.20/24 fe80::b8f5:86ff:fee5:2886/64
```

### 4. Какие типы агрегации интерфейсов есть в Linux? Какие опции есть для балансировки нагрузки? Приведите пример конфига.
**Агрегирование каналов** - технология, которая позволяет объединить несколько физических каналов в один логический. 
Такое объединение позволяет увеличивать пропускную способность и надежность канала. Агрегирование каналов может быть 
настроено между двумя коммутаторами, коммутатором и маршрутизатором, между коммутатором и хостом.    
### Опции для балансировки нагрузки:  
**Mode-0(balance-rr)**: данный режим используется по умолчанию. Balance-rr обеспечивается балансировку нагрузки и отказоустойчивость. В данном режиме сетевые пакеты отправляются “по кругу”, от первого интерфейса к последнему. Если выходят из строя интерфейсы, пакеты отправляются на остальные оставшиеся. Дополнительной настройки коммутатора не требуется при нахождении портов в одном коммутаторе. При разностных коммутаторах требуется дополнительная настройка.  
**Mode-1(active-backup)**: один из интерфейсов работает в активном режиме, остальные в ожидающем. При обнаружении проблемы на активном интерфейсе производится переключение на ожидающий интерфейс. Не требуется поддержки от коммутатора.  
**Mode-2(balance-xor)**: передача пакетов распределяется по типу входящего и исходящего трафика по формуле ((MAC src) XOR (MAC dest)) % число интерфейсов. Режим дает балансировку нагрузки и отказоустойчивость. Не требуется дополнительной настройки коммутатора/коммутаторов.  
**Mode-3(broadcast)**: происходит передача во все объединенные интерфейсы, тем самым обеспечивая отказоустойчивость. Рекомендуется только для использования MULTICAST трафика.  
**Mode-4(802.3ad)**: динамическое объединение одинаковых портов. В данном режиме можно значительно увеличить пропускную способность входящего так и исходящего трафика. Для данного режима необходима поддержка и настройка коммутатора/коммутаторов.  
**Mode-5(balance-tlb)**: адаптивная балансировки нагрузки трафика. Входящий трафик получается только активным интерфейсом, исходящий распределяется в зависимости от текущей загрузки канала каждого интерфейса. Не требуется специальной поддержки и настройки коммутатора/коммутаторов.  
**Mode-6(balance-alb)**: адаптивная балансировка нагрузки. Отличается более совершенным алгоритмом балансировки нагрузки чем Mode-5). Обеспечивается балансировку нагрузки как исходящего так и входящего трафика. Не требуется специальной поддержки и настройки коммутатора/коммутаторов.  

Пример конфига `/etc/network/interfaces`, для агрегации двух интерфейсов `eth1` и `eth2` в интерфейс `bond0`:  
```shell
auto bond0
  iface bond0 inet static
  address 192.168.56.20/24
  network 192.168.56.0
  slaves eth1 eth2
  bond-mode balance-rr
  bond-miimon 100
  bond-downdelay 200
  bond-updelay 200
```

### 5.1 Сколько IP адресов в сети с маской /29 ?
**В сети с маской /29 8 адресов. Из них только 6 адресов можно использовать для хостов, т.к. остальные 2 адреса 
используются для: 1 адрес - для номера сети (Network) и 1 широковещательный адрес (Broadcast), используемый для 
отправки широковещательных пакетов, предназначенных всем адресам в данной сети:** 
```shell
root@test-netology:~#
 ipcalc 10.0.0.0/29
Address:   10.0.0.0             00001010.00000000.00000000.00000 000
Netmask:   255.255.255.248 = 29 11111111.11111111.11111111.11111 000
Wildcard:  0.0.0.7              00000000.00000000.00000000.00000 111
=>
Network:   10.0.0.0/29          00001010.00000000.00000000.00000 000
HostMin:   10.0.0.1             00001010.00000000.00000000.00000 001
HostMax:   10.0.0.6             00001010.00000000.00000000.00000 110
Broadcast: 10.0.0.7             00001010.00000000.00000000.00000 111
Hosts/Net: 6                     Class A, Private Internet
```
### 5.2 Сколько /29 подсетей можно получить из сети с маской /24 ?
**Из сети с маской /24 можно получить 31 сеть с маской /29:**  
Сеть с маской /24 содержит 256 адресов, из них 1 адрес - номер сети и 1 адрес широковещательный. Остается 254 свободных
адресов.  
Cеть с маской /29 содержит 8 адресов.  
В результате целочисленного деления 254 на 8 получаем 31 - столько подсетей с маской /29 можно получить из сети с маской /29.

### 5.3 Приведите несколько примеров /29 подсетей внутри сети 10.10.10.0/24  
Пример таких сетей:  
10.10.10.0/29  
10.10.10.8/29  
10.10.10.16/29  
10.10.10.24/29  
10.10.10.32/29  
10.10.10.40/29  
... и т.д. с шагом +8 в четвертом октете
```shell
root@test-netology:~#
 ipcalc 10.10.10.5/29
Address:   10.10.10.5           00001010.00001010.00001010.00000 101
Netmask:   255.255.255.248 = 29 11111111.11111111.11111111.11111 000
Wildcard:  0.0.0.7              00000000.00000000.00000000.00000 111
=>
Network:   10.10.10.0/29        00001010.00001010.00001010.00000 000
HostMin:   10.10.10.1           00001010.00001010.00001010.00000 001
HostMax:   10.10.10.6           00001010.00001010.00001010.00000 110
Broadcast: 10.10.10.7           00001010.00001010.00001010.00000 111
Hosts/Net: 6 
```

### 6. Задача: вас попросили организовать стык между 2-мя организациями. Диапазоны 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16 уже заняты. Из какой подсети допустимо взять частные IP адреса? Маску выберите из расчета максимум 40-50 хостов внутри подсети.  
Для решения задачи возьмем подсеть 100.64.0.0 с маской сети /26, содержащей в себе 62 адреса для хостов:  
```shell
root@test-netology:~#
 ipcalc 100.64.0.0/26
Address:   100.64.0.0           01100100.01000000.00000000.00 000000
Netmask:   255.255.255.192 = 26 11111111.11111111.11111111.11 000000
Wildcard:  0.0.0.63             00000000.00000000.00000000.00 111111
=>
Network:   100.64.0.0/26        01100100.01000000.00000000.00 000000
HostMin:   100.64.0.1           01100100.01000000.00000000.00 000001
HostMax:   100.64.0.62          01100100.01000000.00000000.00 111110
Broadcast: 100.64.0.63          01100100.01000000.00000000.00 111111
Hosts/Net: 62
```

### 7. Как проверить ARP таблицу в Linux, Windows? Как очистить ARP кеш полностью? Как из ARP таблицы удалить только один нужный IP?
#### Windows:  
для просмотра ARP-таблицы используем `arp -a`:  
```shell
PS C:\Users\duxaxa> arp -a

Интерфейс: 192.168.152.1 --- 0x4
  адрес в Интернете      Физический адрес      Тип
  192.168.152.128       00-0c-29-e4-c9-10     динамический
  192.168.152.255       ff-ff-ff-ff-ff-ff     статический
  224.0.0.22            01-00-5e-00-00-16     статический
  224.0.0.251           01-00-5e-00-00-fb     статический
  224.0.0.252           01-00-5e-00-00-fc     статический
  239.255.255.250       01-00-5e-7f-ff-fa     статический

Интерфейс: 192.168.179.1 --- 0x15
  адрес в Интернете      Физический адрес      Тип
  192.168.179.255       ff-ff-ff-ff-ff-ff     статический
  224.0.0.22            01-00-5e-00-00-16     статический
  224.0.0.251           01-00-5e-00-00-fb     статический
  224.0.0.252           01-00-5e-00-00-fc     статический
  239.255.255.250       01-00-5e-7f-ff-fa     статический

Интерфейс: 192.168.56.1 --- 0x1c
  адрес в Интернете      Физический адрес      Тип
  192.168.56.255        ff-ff-ff-ff-ff-ff     статический
  224.0.0.22            01-00-5e-00-00-16     статический
  224.0.0.251           01-00-5e-00-00-fb     статический
  224.0.0.252           01-00-5e-00-00-fc     статический
  239.255.255.250       01-00-5e-7f-ff-fa     статический
  255.255.255.255       ff-ff-ff-ff-ff-ff     статический

Интерфейс: 192.168.10.5 --- 0x1f
  адрес в Интернете      Физический адрес      Тип
  192.168.10.1          c8-3a-35-9a-80-70     динамический
  192.168.10.255        ff-ff-ff-ff-ff-ff     статический
  224.0.0.22            01-00-5e-00-00-16     статический
  224.0.0.251           01-00-5e-00-00-fb     статический
  224.0.0.252           01-00-5e-00-00-fc     статический
  239.255.255.250       01-00-5e-7f-ff-fa     статический
  255.255.255.255       ff-ff-ff-ff-ff-ff     статический
```
для очистки кеша ARP-таблицы используем `arp -d *`.  
для удаления из ARP-таблицы одного IP используем `arp -d 192.168.152.255`, указав конкретный ip-адрес.  
#### Linux:
для просмотра ARP-таблицы используем `arp -a` (BSD style output format (with no fixed columns) или `arp -e` (Linux style output format (with fixed columns)):  
```shell
root@test-netology:~#
 arp -a
? (10.0.2.3) at 52:54:00:12:35:03 [ether] on eth0
_gateway (10.0.2.2) at 52:54:00:12:35:02 [ether] on eth0

root@test-netology:~#
 arp -e
Address                  HWtype  HWaddress           Flags Mask            Iface
10.0.2.3                 ether   52:54:00:12:35:03   C                     eth0
_gateway                 ether   52:54:00:12:35:02   C                     eth0
```
для очистки кеша ARP-таблицы используем `ip neigh flush all`:  
```shell
root@test-netology:~#
 ip neigh flush all && arp -e

root@test-netology:~#
```
для удаления из ARP-таблицы одного IP используем `arp -d 10.0.2.3`, указав конкретный ip-адрес:  
```shell
root@test-netology:~#
 arp -d 10.0.2.3; arp -e
Address                  HWtype  HWaddress           Flags Mask            Iface
_gateway                 ether   52:54:00:12:35:02   C                     eth0
_gateway                 ether   52:54:00:12:35:02   C                     eth0
```