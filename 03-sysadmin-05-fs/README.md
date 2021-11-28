### 1. Sparse File  
Создание `sparse`-файла:  
```shell
vagrant@test-netology:~/aaa $
 dd if=/dev/zero of=sparse.file bs=1 count=0 seek=100M
# bs=BYTES, read and write up to BYTES bytes at a time (default: 512); overrides ibs and obs
# count=N,  copy only N input blocks
# seek=N,   skip N obs-sized blocks at start of output

0+0 records in
0+0 records out
0 bytes copied, 0.000267973 s, 0.0 kB/s

agrant@test-netology:~/aaa $
 ll sparse.file 
-rw-rw-r-- 1 vagrant vagrant 104857600 Nov 27 19:06 sparse.file

vagrant@test-netology:~/aaa $
 stat sparse.file 
  File: sparse.file
  Size: 104857600 	Blocks: 0          IO Block: 4096   regular file
Device: fd00h/64768d	Inode: 131095      Links: 1
Access: (0664/-rw-rw-r--)  Uid: ( 1000/ vagrant)   Gid: ( 1000/ vagrant)
Access: 2021-11-27 19:06:28.919629793 +0000
Modify: 2021-11-27 19:06:28.919629793 +0000
Change: 2021-11-27 19:06:28.919629793 +0000
 Birth: -

vagrant@test-netology:~/aaa $
 du --block-size=4096 sparse.file 
0	sparse.file
vagrant@test-netology:~/aaa $
```
В метаинформации об файле указано, что он имеет размер 100Мб (`Size: 104857600`, в байтах). При этом фактически
(физически) файл не занимает ни одного блока на файловой системе: `Blocks: 0`. `du` также показывает, что файл не 
занимает ни одного блока в файловой системе.  

### 2. Могут ли файлы, являющиеся жесткой ссылкой на один объект, иметь разные права доступа и владельца? Почему?  
Не могут, так все хардлинки указывают на одну и туже метаинформацию о файле - на `inode`. Если поменять владельца 
или права доступа файла на одном из множества хардлинков, то информация об этом изменится непосредственно в `inode`:  
```shell
root@test-netology:/tmp #
 mkdir -m=777 01 02

root@test-netology:/tmp #
 echo 123 > 01/file

root@test-netology:/tmp #
 stat 01/file 
  File: 01/file
  Size: 4         	Blocks: 8          IO Block: 4096   regular file
Device: fd00h/64768d	Inode: 3670034     Links: 1
Access: (0644/-rw-r--r--)  Uid: (    0/    root)   Gid: (    0/    root)
Access: 2021-11-27 19:30:36.747591759 +0000
Modify: 2021-11-27 19:30:36.747591759 +0000
Change: 2021-11-27 19:30:36.747591759 +0000
 Birth: -

root@test-netology:/tmp #
 ln 01/file 02/hardlink

root@test-netology:/tmp #
 stat 01/file 
  File: 01/file
  Size: 4         	Blocks: 8          IO Block: 4096   regular file
Device: fd00h/64768d	Inode: 3670034     Links: 2
Access: (0644/-rw-r--r--)  Uid: (    0/    root)   Gid: (    0/    root)
Access: 2021-11-27 19:30:36.747591759 +0000
Modify: 2021-11-27 19:30:36.747591759 +0000
Change: 2021-11-27 19:30:52.695591340 +0000
 Birth: -

root@test-netology:/tmp #
 ll 01/file 02/hardlink 
-rw-r--r-- 2 root root 4 Nov 27 19:30 01/file
-rw-r--r-- 2 root root 4 Nov 27 19:30 02/hardlink

root@test-netology:/tmp #
 chown vagrant:vagrant 01/file 

root@test-netology:/tmp #
 stat 01/file 
  File: 01/file
  Size: 4         	Blocks: 8          IO Block: 4096   regular file
Device: fd00h/64768d	Inode: 3670034     Links: 2
Access: (0644/-rw-r--r--)  Uid: ( 1000/ vagrant)   Gid: ( 1000/ vagrant)
Access: 2021-11-27 19:30:36.747591759 +0000
Modify: 2021-11-27 19:30:36.747591759 +0000
Change: 2021-11-27 19:31:20.015590622 +0000
 Birth: -

root@test-netology:/tmp #
 ll 01/file 02/hardlink 
-rw-r--r-- 2 vagrant vagrant 4 Nov 27 19:30 01/file
-rw-r--r-- 2 vagrant vagrant 4 Nov 27 19:30 02/hardlink
```

### 3. Новая ВМ создана с учетом поправки на путь до каталога размещения временных дисков для экспериментов:  
```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-20.04"
  config.vm.hostname = "test-netology"
  
  config.vm.provider :virtualbox do |vb|
    vb.name= "test-netology"
    vb.memory = "512"
    vb.cpus = "1"
    lvm_experiments_disk0_path = "D:/vm/virtual_box/test-netology/tmp/lvm_experiments_disk0.vmdk"
    lvm_experiments_disk1_path = "D:/vm/virtual_box/test-netology/tmp/lvm_experiments_disk1.vmdk"
    vb.customize ['createmedium', '--filename', lvm_experiments_disk0_path, '--size', 2560]
    vb.customize ['createmedium', '--filename', lvm_experiments_disk1_path, '--size', 2560]
    vb.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', lvm_experiments_disk0_path]
    vb.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 2, '--device', 0, '--type', 'hdd', '--medium', lvm_experiments_disk1_path]
  end
end
```

### 4. Используя `fdisk`, разбейте первый диск на 2 раздела: 2 Гб, оставшееся пространство.  
```shell

root@test-netology:~#
 lsblk 
NAME                 MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda                    8:0    0   64G  0 disk 
├─sda1                 8:1    0  512M  0 part /boot/efi
├─sda2                 8:2    0    1K  0 part 
└─sda5                 8:5    0 63.5G  0 part 
  ├─vgvagrant-root   253:0    0 62.6G  0 lvm  /
  └─vgvagrant-swap_1 253:1    0  980M  0 lvm  [SWAP]
sdb                    8:16   0  2.5G  0 disk 
sdc                    8:32   0  2.5G  0 disk 

root@test-netology:~#
 fdisk /dev/sdb

Welcome to fdisk (util-linux 2.34).
Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.

Device does not contain a recognized partition table.
Created a new DOS disklabel with disk identifier 0x5912f3fc.

Command (m for help): n
Partition type
   p   primary (0 primary, 0 extended, 4 free)
   e   extended (container for logical partitions)
Select (default p): p
Partition number (1-4, default 1): 1
First sector (2048-5242879, default 2048): 2048
Last sector, +/-sectors or +/-size{K,M,G,T,P} (2048-5242879, default 5242879): +2G

Created a new partition 1 of type 'Linux' and of size 2 GiB.

Command (m for help): n
Partition type
   p   primary (1 primary, 0 extended, 3 free)
   e   extended (container for logical partitions)
Select (default p): p
Partition number (2-4, default 2): 
First sector (4196352-5242879, default 4196352): 
Last sector, +/-sectors or +/-size{K,M,G,T,P} (4196352-5242879, default 5242879): 

Created a new partition 2 of type 'Linux' and of size 511 MiB.

Command (m for help): w
The partition table has been altered.
Calling ioctl() to re-read partition table.
Syncing disks.


root@test-netology:~#
 fdisk -l /dev/sdb
Disk /dev/sdb: 2.51 GiB, 2684354560 bytes, 5242880 sectors
Disk model: VBOX HARDDISK   
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x5912f3fc

Device     Boot   Start     End Sectors  Size Id Type
/dev/sdb1          2048 4196351 4194304    2G 83 Linux
/dev/sdb2       4196352 5242879 1046528  511M 83 Linux
```


### 5. Используя `sfdisk`, перенесите данную таблицу разделов на второй диск.  
```shell
root@test-netology:~#
 lsblk 
NAME                 MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda                    8:0    0   64G  0 disk 
├─sda1                 8:1    0  512M  0 part /boot/efi
├─sda2                 8:2    0    1K  0 part 
└─sda5                 8:5    0 63.5G  0 part 
  ├─vgvagrant-root   253:0    0 62.6G  0 lvm  /
  └─vgvagrant-swap_1 253:1    0  980M  0 lvm  [SWAP]
sdb                    8:16   0  2.5G  0 disk 
├─sdb1                 8:17   0    2G  0 part 
└─sdb2                 8:18   0  511M  0 part 
sdc                    8:32   0  2.5G  0 disk 

root@test-netology:~#
 sfdisk --dump /dev/sdb > /tmp/dev-sdb.dump

root@test-netology:~#
 sfdisk /dev/sdc < /tmp/dev-sdb.dump 
Checking that no-one is using this disk right now ... OK

Disk /dev/sdc: 2.51 GiB, 2684354560 bytes, 5242880 sectors
Disk model: VBOX HARDDISK   
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes

>>> Script header accepted.
>>> Script header accepted.
>>> Script header accepted.
>>> Script header accepted.
>>> Created a new DOS disklabel with disk identifier 0x5912f3fc.
/dev/sdc1: Created a new partition 1 of type 'Linux' and of size 2 GiB.
/dev/sdc2: Created a new partition 2 of type 'Linux' and of size 511 MiB.
/dev/sdc3: Done.

New situation:
Disklabel type: dos
Disk identifier: 0x5912f3fc

Device     Boot   Start     End Sectors  Size Id Type
/dev/sdc1          2048 4196351 4194304    2G 83 Linux
/dev/sdc2       4196352 5242879 1046528  511M 83 Linux

The partition table has been altered.
Calling ioctl() to re-read partition table.
Syncing disks.

root@test-netology:~#
 fdisk -l /dev/sdc
Disk /dev/sdc: 2.51 GiB, 2684354560 bytes, 5242880 sectors
Disk model: VBOX HARDDISK   
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x5912f3fc

Device     Boot   Start     End Sectors  Size Id Type
/dev/sdc1          2048 4196351 4194304    2G 83 Linux
/dev/sdc2       4196352 5242879 1046528  511M 83 Linux
```


### 6. Соберите `mdadm` RAID1 на паре разделов 2 Гб.  
Создаем RAID1:  
```shell
root@test-netology:~#
 mdadm --create /dev/md127 --level 1 --raid-devices 2 --name test-raid1 /dev/sdb1 /dev/sdc1
mdadm: Note: this array has metadata at the start and
    may not be suitable as a boot device.  If you plan to
    store '/boot' on this device please ensure that
    your boot-loader understands md/v1.x metadata, or use
    --metadata=0.90
Continue creating array? y
mdadm: Defaulting to version 1.2 metadata
mdadm: array /dev/md127 started.

root@test-netology:~#
 mdadm --detail /dev/md127
/dev/md127:
           Version : 1.2
     Creation Time : Sun Nov 28 17:32:27 2021
        Raid Level : raid1
        Array Size : 2094080 (2045.00 MiB 2144.34 MB)
     Used Dev Size : 2094080 (2045.00 MiB 2144.34 MB)
      Raid Devices : 2
     Total Devices : 2
       Persistence : Superblock is persistent

       Update Time : Sun Nov 28 17:32:37 2021
             State : clean 
    Active Devices : 2
   Working Devices : 2
    Failed Devices : 0
     Spare Devices : 0

Consistency Policy : resync

              Name : test-netology:test-raid1  (local to host test-netology)
              UUID : ac64102d:49848d2c:a9354f27:2f241b97
            Events : 17

    Number   Major   Minor   RaidDevice State
       0       8       17        0      active sync   /dev/sdb1
       1       8       33        1      active sync   /dev/sdc1
```


### 7. Соберите `mdadm` RAID0 на второй паре маленьких разделов.
```shell
root@test-netology:~#
  mdadm --create /dev/md126 --level 0 --raid-devices 2 --name test-raid0 /dev/sdb2 /dev/sdc2
mdadm: Defaulting to version 1.2 metadata
mdadm: array /dev/md126 started.

root@test-netology:~#
 mdadm --detail /dev/md126
/dev/md126:
           Version : 1.2
     Creation Time : Sun Nov 28 18:54:08 2021
        Raid Level : raid0
        Array Size : 1042432 (1018.00 MiB 1067.45 MB)
      Raid Devices : 2
     Total Devices : 2
       Persistence : Superblock is persistent

       Update Time : Sun Nov 28 18:54:08 2021
             State : clean 
    Active Devices : 2
   Working Devices : 2
    Failed Devices : 0
     Spare Devices : 0

            Layout : -unknown-
        Chunk Size : 512K

Consistency Policy : none

              Name : test-netology:test-raid0  (local to host test-netology)
              UUID : 82fea62c:7b5aa192:659c3500:000f77c9
            Events : 0

    Number   Major   Minor   RaidDevice State
       0       8       18        0      active sync   /dev/sdb2
       1       8       34        1      active sync   /dev/sdc2
```


### 8. Создайте 2 независимых PV на получившихся md-устройствах.  
```shell
root@test-netology:~#
 pvcreate /dev/md126
  Physical volume "/dev/md126" successfully created.

root@test-netology:~#
 pvcreate /dev/md127
  Physical volume "/dev/md127" successfully created.

root@test-netology:~#
 pvdisplay /dev/md*
  "/dev/md126" is a new physical volume of "1018.00 MiB"
  --- NEW Physical volume ---
  PV Name               /dev/md126
  VG Name               
  PV Size               1018.00 MiB
  Allocatable           NO
  PE Size               0   
  Total PE              0
  Free PE               0
  Allocated PE          0
  PV UUID               rKjZb2-QYox-feMu-lzQ0-6rTd-cYjA-kHudto
   
  "/dev/md127" is a new physical volume of "<2.00 GiB"
  --- NEW Physical volume ---
  PV Name               /dev/md127
  VG Name               
  PV Size               <2.00 GiB
  Allocatable           NO
  PE Size               0   
  Total PE              0
  Free PE               0
  Allocated PE          0
  PV UUID               CKKEMJ-VZ0q-B10D-mq1g-nlCB-1rSh-mCqsCS  
```


### 9. Создайте общую volume-group на этих двух PV.  
```shell
root@test-netology:~#
 vgcreate vg_common /dev/md126 /dev/md127
  Volume group "vg_common" successfully created

root@test-netology:~#
 vgdisplay vg_common
  --- Volume group ---
  VG Name               vg_common
  System ID             
  Format                lvm2
  Metadata Areas        2
  Metadata Sequence No  1
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                0
  Open LV               0
  Max PV                0
  Cur PV                2
  Act PV                2
  VG Size               <2.99 GiB
  PE Size               4.00 MiB
  Total PE              765
  Alloc PE / Size       0 / 0   
  Free  PE / Size       765 / <2.99 GiB
  VG UUID               0euEPB-QLa3-GlHM-6JkO-03Hx-Nbuo-mT2ghC

root@test-netology:~#
 pvs
  PV         VG        Fmt  Attr PSize    PFree   
  /dev/md126   vg_common lvm2 a--  1016.00m 1016.00m
  /dev/md127   vg_common lvm2 a--    <2.00g   <2.00g
  /dev/sda5  vgvagrant lvm2 a--   <63.50g       0

root@test-netology:~#
 vgs
  VG        #PV #LV #SN Attr   VSize   VFree 
  vg_common   2   0   0 wz--n-  <2.99g <2.99g
  vgvagrant   1   2   0 wz--n- <63.50g     0
```


### 10. Создайте LV размером 100 Мб, указав его расположение на PV с RAID0.  
```shell
root@test-netology:~#
 lvcreate -L 100M -n lv_on_raid0 vg_common /dev/md126
  Logical volume "lv_on_raid0" created.

root@test-netology:~#
 lvs
  LV          VG        Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  lv_on_raid0 vg_common -wi-a----- 100.00m                                                    
  root        vgvagrant -wi-ao---- <62.54g                                                    
  swap_1      vgvagrant -wi-ao---- 980.00m 

root@test-netology:~#
 lvdisplay vg_common
  --- Logical volume ---
  LV Path                /dev/vg_common/lv_on_raid0
  LV Name                lv_on_raid0
  VG Name                vg_common
  LV UUID                3xlEVm-m4rQ-gHLH-gxSd-c9eB-Gb1A-DsauUs
  LV Write Access        read/write
  LV Creation host, time test-netology, 2021-11-28 20:39:12 +0000
  LV Status              available
  # open                 0
  LV Size                100.00 MiB
  Current LE             25
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     4096
  Block device           253:2
```


### 11. Создайте `mkfs.ext4` ФС на получившемся LV.  
```shell
root@test-netology:~#
 mkfs.ext4 /dev/vg_common/lv_on_raid0 
mke2fs 1.45.5 (07-Jan-2020)
Creating filesystem with 25600 4k blocks and 25600 inodes

Allocating group tables: done                            
Writing inode tables: done                            
Creating journal (1024 blocks): done
Writing superblocks and filesystem accounting information: done
```


### 12. Смонтируйте этот раздел в любую директорию.  
```shell
root@test-netology:~#
 mkdir /raid0folder

root@test-netology:~#
 mount /dev/vg_common/lv_on_raid0 /raid0folder/

root@test-netology:~#
 df -h
Filesystem                         Size  Used Avail Use% Mounted on
udev                               195M     0  195M   0% /dev
tmpfs                               48M  708K   48M   2% /run
/dev/mapper/vgvagrant-root          62G  1.6G   57G   3% /
tmpfs                              240M     0  240M   0% /dev/shm
tmpfs                              5.0M     0  5.0M   0% /run/lock
tmpfs                              240M     0  240M   0% /sys/fs/cgroup
/dev/sda1                          511M  4.0K  511M   1% /boot/efi
tmpfs                               48M     0   48M   0% /run/user/1000
vagrant                            1.9T  849G 1015G  46% /vagrant
/dev/mapper/vg_common-lv_on_raid0   93M   72K   86M   1% /raid0folder
```


### 13. Поместите туда тестовый файл  
```shell
root@test-netology:~#
 wget -q https://github.com/prometheus/node_exporter/releases/download/v1.3.0/node_exporter-1.3.0.linux-amd64.tar.gz -P /raid0folder

root@test-netology:~#
 ll /raid0folder/
total 8836
drwx------ 2 root root   16384 Nov 28 20:52 lost+found
-rw-r--r-- 1 root root 9030402 Nov 18 16:41 node_exporter-1.3.0.linux-amd64.tar.gz
```


### 14. Прикрепите вывод `lsblk`.  
```shell
root@test-netology:~#
 lsblk 
NAME                        MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT
sda                           8:0    0   64G  0 disk  
├─sda1                        8:1    0  512M  0 part  /boot/efi
├─sda2                        8:2    0    1K  0 part  
└─sda5                        8:5    0 63.5G  0 part  
  ├─vgvagrant-root          253:0    0 62.6G  0 lvm   /
  └─vgvagrant-swap_1        253:1    0  980M  0 lvm   [SWAP]
sdb                           8:16   0  2.5G  0 disk  
├─sdb1                        8:17   0    2G  0 part  
│ └─md127                     9:127  0    2G  0 raid1 
└─sdb2                        8:18   0  511M  0 part  
  └─md126                     9:126  0 1018M  0 raid0 
    └─vg_common-lv_on_raid0 253:2    0  100M  0 lvm   /raid0folder
sdc                           8:32   0  2.5G  0 disk  
├─sdc1                        8:33   0    2G  0 part  
│ └─md127                     9:127  0    2G  0 raid1 
└─sdc2                        8:34   0  511M  0 part  
  └─md126                     9:126  0 1018M  0 raid0 
    └─vg_common-lv_on_raid0 253:2    0  100M  0 lvm   /raid0folder
```


### 15. Протестируйте целостность файла.
```shell
root@test-netology:/raid0folder#
 gzip -t node_exporter-1.3.0.linux-amd64.tar.gz && echo $?
0
```


### 16. Используя pvmove, переместите содержимое PV с RAID0 на RAID1.
```shell
root@test-netology:/raid0folder#
 pvmove /dev/md126 /dev/md127
  /dev/md126: Moved: 12.00%
  /dev/md126: Moved: 100.00%

root@test-netology:/raid0folder#
 pvmove /dev/md126 /dev/md127
  No data to move for vg_common.
```


### 17. Сделайте `--fail` на устройство в вашем RAID1 md.  
```shell
root@test-netology:/raid0folder#
 cat /proc/mdstat 
Personalities : [raid1] [raid0] [linear] [multipath] [raid6] [raid5] [raid4] [raid10] 
md126 : active raid0 sdc2[1] sdb2[0]
      1042432 blocks super 1.2 512k chunks
      
md127 : active raid1 sdc1[1] sdb1[0]
      2094080 blocks super 1.2 [2/2] [UU]
      
unused devices: <none>


root@test-netology:/raid0folder#
 mdadm --fail /dev/md127 /dev/sdb1
mdadm: set /dev/sdb1 faulty in /dev/md127


root@test-netology:/raid0folder#
 cat /proc/mdstat
Personalities : [raid1] [raid0] [linear] [multipath] [raid6] [raid5] [raid4] [raid10] 
md126 : active raid0 sdc2[1] sdb2[0]
      1042432 blocks super 1.2 512k chunks
      
md127 : active raid1 sdc1[1] sdb1[0](F)
      2094080 blocks super 1.2 [2/1] [_U]
      
unused devices: <none>
```


### 18. Подтвердите выводом `dmesg`, что RAID1 работает в деградированном состоянии.
```shell
root@test-netology:/raid0folder#
 dmesg -H | tail -n 5
[  +0.000902] 20:26:07.842661 main     vbglR3GuestCtrlDetectPeekGetCancelSupport: Supported (#1)
[Nov28 20:54] EXT4-fs (dm-2): mounted filesystem with ordered data mode. Opts: (null)
[  +0.000006] ext4 filesystem being mounted at /raid0folder supports timestamps until 2038 (0x7fffffff)
[Nov28 21:27] md/raid1:md127: Disk failure on sdb1, disabling device.
              md/raid1:md127: Operation continuing on 1 devices.
```


### 19. Протестируйте целостность файла, несмотря на "сбойный" диск он должен продолжать быть доступен:  
```shell
root@test-netology:/raid0folder#
 gzip -t node_exporter-1.3.0.linux-amd64.tar.gz && echo $?
0
```