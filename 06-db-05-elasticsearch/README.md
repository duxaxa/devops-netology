# Домашнее задание к занятию "6.5. Elasticsearch"

## Задача 1

В этом задании вы потренируетесь в:
- установке elasticsearch
- первоначальном конфигурировании elastcisearch
- запуске elasticsearch в docker

Используя докер образ [elasticsearch:7](https://hub.docker.com/_/elasticsearch) как базовый:

- составьте Dockerfile-манифест для elasticsearch
- соберите docker-образ и сделайте `push` в ваш docker.io репозиторий
- запустите контейнер из получившегося образа и выполните запрос пути `/` c хост-машины


Требования к `elasticsearch.yml`: [elasticsearch.yml](src/elasticsearch/elasticsearch.yml) 
- данные `path` должны сохраняться в `/var/lib`
- имя ноды должно быть `netology_test`

В ответе приведите:
- текст Dockerfile манифеста: [Dockerfile](src/elasticsearch/Dockerfile)
- ссылку на образ в репозитории dockerhub: [duxaxa/elasticsearch:7.17.9](https://hub.docker.com/layers/duxaxa/elasticsearch/7.17.9/images/sha256-d379fe0e0e4e134e7a37ed73c4e4a4783907affb753b487cf8249e32d3ebb46a?context=repo)
- ответ `elasticsearch` на запрос пути `/`  (http://localhost:9200/): в json виде:
    ```json
    $ curl -X GET "localhost:9200/?pretty"
    {
    "name" : "netology_test",
    "cluster_name" : "netology_test-cluster",
    "cluster_uuid" : "s3vqfq3JQs23EoH5UrL61g",
    "version" : {
        "number" : "7.17.9",
        "build_flavor" : "default",
        "build_type" : "docker",
        "build_hash" : "ef48222227ee6b9e70e502f0f0daa52435ee634d",
        "build_date" : "2023-01-31T05:34:43.305517834Z",
        "build_snapshot" : false,
        "lucene_version" : "8.11.1",
        "minimum_wire_compatibility_version" : "6.8.0",
        "minimum_index_compatibility_version" : "6.0.0-beta1"
    },
    "tagline" : "You Know, for Search"
    }
    ```

Подсказки:
- при сетевых проблемах внимательно изучите кластерные и сетевые настройки в elasticsearch.yml
- при некоторых проблемах вам поможет docker директива ulimit
- elasticsearch в логах обычно описывает проблему и пути ее решения
- обратите внимание на настройки безопасности такие как `xpack.security.enabled` 
- если докер образ не запускается и падает с ошибкой 137 в этом случае может помочь настройка `-e ES_HEAP_SIZE`
- при настройке `path` возможно потребуется настройка прав доступа на директорию

Далее мы будем работать с данным экземпляром elasticsearch.

## Задача 2

В этом задании вы научитесь:
- создавать и удалять индексы
- изучать состояние кластера
- обосновывать причину деградации доступности данных

Ознакомтесь с [документацией](https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-create-index.html) 
и добавьте в `elasticsearch` 3 индекса, в соответствии со таблицей:

| Имя | Количество реплик | Количество шард |
|-----|-------------------|-----------------|
| ind-1| 0 | 1 |
| ind-2 | 1 | 2 |
| ind-3 | 2 | 4 |

```json
$ curl -X PUT "localhost:9200/ind-1?pretty" -H 'Content-Type: application/json' -d'
{
  "settings": {
    "index": {
      "number_of_replicas": 0,
      "number_of_shards": 1
    }
  }
}
'
{
  "acknowledged" : true,
  "shards_acknowledged" : true,
  "index" : "ind-1"
}

$ curl -X PUT "localhost:9200/ind-2?pretty" -H 'Content-Type: application/json' -d'
{
  "settings": {
    "index": {
      "number_of_replicas": 1,
      "number_of_shards": 2
    }
  }
}
'
{
  "acknowledged" : true,
  "shards_acknowledged" : true,
  "index" : "ind-2"
}

$ curl -X PUT "localhost:9200/ind-3?pretty" -H 'Content-Type: application/json' -d'
{
  "settings": {
    "index": {
      "number_of_replicas": 2,
      "number_of_shards": 4
    }
  }
}
'
{
  "acknowledged" : true,
  "shards_acknowledged" : true,
  "index" : "ind-3"
}
```

Получите список индексов и их статусов, используя API и **приведите в ответе** на задание:  

```json
$ curl -X GET "localhost:9200/_cat/indices"
green  open .geoip_databases qq-BiH21TcekECHpMPLblA 1 0 41 0 39.6mb 39.6mb
green  open ind-1            dxONerw_QeSWodYkp1eAbw 1 0  0 0   226b   226b
yellow open ind-3            dsAlWojZTEqhMQgpBU9dBw 4 2  0 0   904b   904b
yellow open ind-2            7iFvVusGQvSH_ihN_5TO2A 2 1  0 0   452b   452b
```

Получите состояние кластера `elasticsearch`, используя API:

```json
$ curl -X GET "localhost:9200/_cluster/health?pretty"
{
  "cluster_name" : "netology_test-cluster",
  "status" : "yellow",
  "timed_out" : false,
  "number_of_nodes" : 1,
  "number_of_data_nodes" : 1,
  "active_primary_shards" : 10,
  "active_shards" : 10,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 10,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 50.0
}
```

Как вы думаете, почему часть индексов и кластер находится в состоянии yellow?

Ответ:

Индексы `ind-2` и `ind-3` находятся в состоянии `yellow`, потому что для них определено количество реплик больше `0`, при этом кластер состоит только из одного узла. Соответственно реплики и мастер шарды находятся на одном и том же узле, что не обеспечивает отказоустойчивости.

Удалите все индексы:

```json
$ curl -X DELETE "localhost:9200/ind-1?pretty"
{
  "acknowledged" : true
}

$ curl -X DELETE "localhost:9200/ind-2?pretty"
{
  "acknowledged" : true
}

$ curl -X DELETE "localhost:9200/ind-3?pretty"
{
  "acknowledged" : true
}
```

**Важно**

При проектировании кластера elasticsearch нужно корректно рассчитывать количество реплик и шард,
иначе возможна потеря данных индексов, вплоть до полной, при деградации системы.

## Задача 3

В данном задании вы научитесь:
- создавать бэкапы данных
- восстанавливать индексы из бэкапов

Создайте директорию `{путь до корневой директории с elasticsearch в образе}/snapshots`:

```shell
$ docker exec elasticsearch bash -c "mkdir -p /usr/share/elasticsearch/snapshots && chown -R elasticsearch:root /usr/share/elasticsearch/snapshots"
```

Используя API [зарегистрируйте](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-register-repository.html#snapshots-register-repository) 
данную директорию как `snapshot repository` c именем `netology_backup`:

**Приведите в ответе** запрос API и результат вызова API для создания репозитория.

```json
$ curl -X PUT "localhost:9200/_snapshot/netology_backup?pretty" -H 'Content-Type: application/json' -d'
{
  "type": "fs",
  "settings": {
    "location": "/usr/share/elasticsearch/snapshots"
  }
}
'
{
  "acknowledged" : true
}


$ curl -X GET "localhost:9200/_snapshot/?pretty"
{
  "netology_backup" : {
    "type" : "fs",
    "settings" : {
      "location" : "/usr/share/elasticsearch/snapshots"
    }
  }
}
```

Создайте индекс `test` с 0 реплик и 1 шардом и **приведите в ответе** список индексов:

```json
$ curl -X PUT "localhost:9200/test?pretty" -H 'Content-Type: application/json' -d'
{
  "settings": {
    "index": {
      "number_of_replicas": 0,
      "number_of_shards": 1
    }
  }
}
'
{
  "acknowledged" : true,
  "shards_acknowledged" : true,
  "index" : "test"
}

$ curl -X GET "localhost:9200/_cat/indices"
green open .geoip_databases qq-BiH21TcekECHpMPLblA 1 0 41 0 39.6mb 39.6mb
green open test             snKVvwfsRE64Ru9h6M7M3w 1 0  0 0   226b   226b
```

[Создайте `snapshot`](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-take-snapshot.html) 
состояния кластера `elasticsearch`:

```json
$ curl -X PUT "localhost:9200/_snapshot/netology_backup/shapshot-111?pretty"
{
  "accepted" : true
}
```

**Приведите в ответе** список файлов в директории со `snapshot`ами:

```shell
$ docker exec elasticsearch ls -l /usr/share/elasticsearch/snapshots
total 48
-rw-rw-r-- 1 elasticsearch root  1424 Feb 12 17:52 index-0
-rw-rw-r-- 1 elasticsearch root     8 Feb 12 17:52 index.latest
drwxrwxr-x 6 elasticsearch root  4096 Feb 12 17:52 indices
-rw-rw-r-- 1 elasticsearch root 29293 Feb 12 17:52 meta-qDAZk_uRQ12fIpW7z5QmFw.dat
-rw-rw-r-- 1 elasticsearch root   711 Feb 12 17:52 snap-qDAZk_uRQ12fIpW7z5QmFw.dat
```

Удалите индекс `test` и создайте индекс `test-2`. **Приведите в ответе** список индексов:

```json
$ curl -X DELETE "localhost:9200/test?pretty"
{
  "acknowledged" : true
}

$ curl -X PUT "localhost:9200/test-2?pretty" -H 'Content-Type: application/json' -d'
{
  "settings": {
    "index": {
      "number_of_replicas": 0,
      "number_of_shards": 1
    }
  }
}
'
{
  "acknowledged" : true,
  "shards_acknowledged" : true,
  "index" : "test-2"
}

$ curl -GET "localhost:9200/_cat/indices"
green open test-2           NRfTJFNlSWmJwDyLEDpUwA 1 0  0 0   226b   226b
green open .geoip_databases qq-BiH21TcekECHpMPLblA 1 0 41 0 39.6mb 39.6mb
```


[Восстановите](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-restore-snapshot.html) состояние
кластера `elasticsearch` из `snapshot`, созданного ранее. 

Доступные снапшоты:

```json
$ curl -s -X GET "localhost:9200/_snapshot/netology_backup/*?verbose=false" | jq
{
  "snapshots": [
    {
      "snapshot": "shapshot-111",
      "uuid": "qDAZk_uRQ12fIpW7z5QmFw",
      "repository": "netology_backup",
      "indices": [
        ".ds-.logs-deprecation.elasticsearch-default-2023.02.12-000001",
        ".ds-ilm-history-5-2023.02.12-000001",
        ".geoip_databases",
        "test"
      ],
      "data_streams": [],
      "state": "SUCCESS"
    }
  ],
  "total": 1,
  "remaining": 0
}
```

**Приведите в ответе** запрос к API восстановления и итоговый список индексов:

```json
$ curl -X POST "localhost:9200/_snapshot/netology_backup/shapshot-111/_restore?pretty" -H 'Content-Type: application/json' -d'
{
  "indices": "test"
}
'
{
  "accepted" : true
}

$ curl -GET "localhost:9200/_cat/indices"
green open test-2           NRfTJFNlSWmJwDyLEDpUwA 1 0  0 0   226b   226b
green open .geoip_databases qq-BiH21TcekECHpMPLblA 1 0 41 0 39.6mb 39.6mb
green open test             TYhhz0GKTluGesuhTzsWmQ 1 0  0 0   226b   226b
```



Подсказки:
- возможно вам понадобится доработать `elasticsearch.yml` в части директивы `path.repo` и перезапустить `elasticsearch`

---

### Как cдавать задание

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
