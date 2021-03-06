### 1. Опишите кратко, как вы поняли: в чем основное отличие полной (аппаратной) виртуализации, паравиртуализации и виртуализации на основе ОС.  

**Полная (аппаратная) виртуализация** - не требует инсталяции операционной системы на физический сервер, 
аппаратные ресурсы которого будут логически делится между разными виртуальными машинами. Вместо операционной системы 
на физический сервер сразу инсталируется гипервизор. Гипервизор полностью обеспечивает функциональность по созданию, 
управлению и мониторингу виртуальных машинам, размещенных на данном физическом сервере. Гипервизор напрямую имеет доступ 
к аппаратным ресурсами физического сервера. Полная виртуализация позволяет создавать виртуальные машины с разными 
типами операционных систем в рамках одного гипервизора. В такой архитектуре можно выделить 3 слоя:
1. Физический сервер
2. Гипервизор
3. Виртуальные машины

**Паравиртуализация** - требует инсталяции операционной системы на физический сервер. Гипервизор устанавливается поверх 
операционной системы, установленной на физический сервер. Для управления и доступа к аппаратными ресурсами физического 
сервера гипервизор взаимодействует с ядром операционной системы физического сервера. Паравиртуализация позволяет 
создавать виртуальные машины с разными типами операционных систем в рамках одного гипервизора. В такой архитектуре 
можно выделить 4 слоя:
1. Физический сервер
2. Операционная система
3. Гипервизор
4. Виртуальная машина

**Виртуализация на основе ОС** - гипервизор не используется. Контейнер, как изолированный процесс, выполняется в отдельном 
пространстве имен операционной системы, установленной на физический сервер. Множество работающих контейнеров используют 
один экземпляр ядра хостовой операционной системы. Фактически, контейнеризация (виртуализация), обеспечивается средствами 
самой операционной системы. Отсюда вытекает ограничение: виртуализация на основе ОС не позволяет запускать на хостовой 
операционной системе контейнеры, использующие другие типы ядра. В такой архитектуре можно выделить 3 слоя:
1. Физический сервер или виртуальный сервер, созданный средствами полной или паравиртуализации
2. Операционная система
3. Контейнер (виртуальная машина)  


### 2. Выберите один из вариантов использования организации физических серверов, в зависимости от условий использования.  

#### Условия использования:

- **Высоконагруженная база данных, чувствительная к отказу**: организация серверов - физические сервера (кластер из 
физических серверов). Это позволит полностью использовать аппаратные ресурсы сервера. Использование паравиртуализации 
повлечет за собой использование части вычислительных мощностей сервера самими гипервизором. Также для БД крайне важна 
скорость работы дискового ввода-вывода, а гипервизоры, как правило, несколько замедляют работу с дисками.
Другим фактором, влияющим на выбор организации сервера, будут рекомендации вендора конкретной СУБД.  
- **Различные web-приложения**: в зависимости от типа web-приложения. Если это некий веб-сервис, то выбор будет за
виртуализацию уровня ОС: в множестве контейнеров будет работать несколько экземпляров веб-приложения. Такая организация 
позволит быстро масштабировать контейнеры, за счет множества экземпляров будет обеспечена высокая отказоустойчивость. 
Если web-приложение это, например, крупный сайт или личный кабинет пользователя, фронт-офисная система с множеством 
функций и web-приложение управляется средствами Weblogic или Websphere и т.п., то выбор будет за паравиртуализацией. В этом 
случае управлять конфигурацией приложения и его платформы (Weblogic или Websphere и т.п.) в контейнере будет не очень удобно.
- **Windows системы для использования бухгалтерским отделом**: паравиртуализация. Это позволит быстро создавать
виртуальные машины с удаленными рабочими местами и эффективно использовать ресурсы физического сервера в 
многопользовательском режиме.  
- **Системы, выполняющие высокопроизводительные расчеты на GPU**: физический сервер. Как и в случае с базой данных, это
позволит полностью использовать аппаратные ресурсы сервера. Кроме того, использование GPU несколькими виртуальными 
машинами вряд ли ускорит скорость расчетов по сравнению с использованием GPU в монопольном режиме одним экземпляром 
процесса, в котором выполняются расчеты.  


### 3. Выберите подходящую систему управления виртуализацией для предложенного сценария. Детально опишите ваш выбор.  

#### 1. 100 виртуальных машин на базе Linux и Windows, общие задачи, нет особых требований. Преимущественно Windows based инфраструктура, требуется реализация программных балансировщиков нагрузки, репликации данных и автоматизированного механизма создания резервных копий.  
Выбор за **Hyper-V**:  
1. 100 ВМ - такое кол-во ВМ поддерживается в Hyper-V.  
2. Hyper-V поддерживает основные дистрибутивы Linux (Centos, RHEL, Ubuntu) на гостевых ВМ  
3. Для преимущественно Windows based инфраструктура лучше использовать нативное средство виртуализации от вендора Microsoft.  
4. Т.к. поддерживаются Linux-дистрибутивы на гостевых ВМ, то можно использовать программные балансировщики nginx, haproxy. Либо Internet Information Services от Microsoft.  
5. Репликации данных и автоматизированный механизм создания резервных копий поддерживается в Hyper-V.


#### 2. Требуется наиболее производительное бесплатное open source решение для виртуализации небольшой (20-30 серверов) инфраструктуры на базе Linux и Windows виртуальных машин.
Выбор за **KVM**:  
1. Абсолютно бесплатен
2. Встроен в ядро Linux с версии 2.6.20
3. Поддерживает аппаратные технологии виртуализации Intel VT и AMD-V встроенными модулями kvm-intel.ko и kvm-amd.ko
4. Высокая производительность виртуальных машин по сравнению с другими свободными системами виртуализации, например Xen
5. Одинаково хорошо поддерживает и Linux и Windows в качестве гостевых ОС виртуальных машин
6. Продолжает активно развиваться  

### 3. Необходимо бесплатное, максимально совместимое и производительное решение для виртуализации Windows инфраструктуры  
Выбор за **KVM**, по тем же причинам, описанным в предыдущем пункте.

### 4. Необходимо рабочее окружение для тестирования программного продукта на нескольких дистрибутивах Linux
Выбора за **VirtualBox**, управляемым с помощью **Vagrant**:  
1. VirtualBox бесплатен, поддерживает Linux, Windows и MacOS в качестве хостовой и гостевой ОС
2. VirtualBox активно развивается и обновляется
3. Vagrant интегрирован с паравиртуализацией средствами VirtualBox из коробки, не требуются дополнительные настройки
4. Vagrant имеет обширную базу образов Vagrant Boxes с разными дистрибутивами Linux и с предустановленным ПО, 
которые развертываются в полноценную ВМ за минуты
5. Настроенную под конкретные задачу ВМ средствами Vagrant можно запаковать в образ и делиться им с другими
6. Средствами VirtualBox так же можно из развернутой ВМ сделать образ, и делится им с другими для быстрого развертывания   


### 4. Опишите возможные проблемы и недостатки гетерогенной среды виртуализации (использования нескольких систем управления виртуализацией одновременно) и что необходимо сделать для минимизации этих рисков и проблем. Если бы у вас был выбор, то создавали бы вы гетерогенную среду или нет? Мотивируйте ваш ответ примерами.
Недостатки:
1. Сложность в управлении инфраструктурой: у разных систем виртуализации могут быть разные команды поддержки. Как следствие
проблемы в коммуникациях, оперативности решения проблем. Споры, чья система виртуализации лучше и т.д.
2. Разные подходы и стратегии к резервного копированию и восстановления, в случае сбоя
3. Не эффективное использование физических серверов: в одной системе виртуализации может наблюдаться нехватка ресурсов, в
другой переизбыток. Миграция физического сервера из одной системы виртуализации требует согласования, времени и денег.
4. Большая стоимость поддержки, т.к. требуются инженеры с разными компетенциями
5. Сложность миграции данных приложений между разными системами виртуализации
6. При возникновении потребности в масштабировании не очевиден ответ, какой из систем виртуализации отдавать предпочтение  
Т.о., проще и дешевле определиться, какая система виртуализации подойдет для решения конкретного спектра задач, и 
использовать единый инструмент для виртуализации.
