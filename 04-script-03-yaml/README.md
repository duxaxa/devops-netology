# Домашнее задание к занятию "4.3. Языки разметки JSON и YAML"

## Обязательная задача 1
Мы выгрузили JSON, который получили через API запрос к нашему сервису:
```
    { "info" : "Sample JSON output from our service\\t",
        "elements" :[
            { "name" : "first",
            "type" : "server",
            "ip" : 7175 
            }
            { "name" : "second",
            "type" : "proxy",
            "ip : 71.78.22.43
            }
        ]
    }
```
Нужно найти и исправить все ошибки, которые допускает наш сервис.
Исправленный JSON [task_1.json](task_1.json):
```json
    { "info" : "Sample JSON output from our service\\t",
        "elements" :[
            { "name" : "first",
              "type" : "server",
                "ip" : "7175"
            },
            { "name" : "second",
              "type" : "proxy",
                "ip" : "71.78.22.43"
            }
        ]
    }
```

## Обязательная задача 2
В прошлый рабочий день мы создавали скрипт, позволяющий опрашивать веб-сервисы и получать их IP. К уже реализованному функционалу нам нужно добавить возможность записи JSON и YAML файлов, описывающих наши сервисы. Формат записи JSON по одному сервису: `{ "имя сервиса" : "его IP"}`. Формат записи YAML по одному сервису: `- имя сервиса: его IP`. Если в момент исполнения скрипта меняется IP у сервиса - он должен так же поменяться в yml и json файле.

### Ваш скрипт:
[task_2.py](task_2.py)
```python
#!/usr/bin/env python3

import socket
import requests
import json
import yaml
import os

sevices_list = {"drive.google.com": "N/A", "mail.google.com": "N/A", "google.com": "N/A"}

while True:
    for key, value in sevices_list.items():
        previous_value = value
        new_value = socket.gethostbyname(key)

        write_to_file = {}
        write_to_file[key] = value

        file_json = str(key) + ".json"
        file_yaml = str(key) + ".yaml"

        if previous_value != new_value:
            message = '[ERROR]: ' + key + ' IP mismatch: ' + previous_value + ' ' + new_value
            print(message)
            write_to_file[key] = new_value
        
        # JSON:
        if not os.path.isfile(file_json):
            with open(file_json, 'w') as file:
                json.dump(write_to_file, file, indent=4)
                #file.write(json.dumps(write_to_file, indent=4))

        elif os.path.isfile(file_json):
            with open(file_json, 'r+') as file:
                file.truncate(0)
                json.dump(write_to_file, file, indent=4)
                #file.write(json.dumps(write_to_file, indent=4))

        # YAML:
        if not os.path.isfile(file_yaml):
            with open(file_yaml, 'w') as file:
                file.write(yaml.safe_dump(write_to_file, indent=2))

        elif os.path.isfile(file_yaml):
            with open(file_yaml, 'r+') as file:
                file.write(yaml.safe_dump(write_to_file, indent=2))

        try:
            response = requests.get('http://' + new_value, timeout=1)
            if response.status_code == 200:
                print('Service http:// ' + key + ' available. HTTP_RESPONSE ' + str(response.status_code))
        except requests.ConnectTimeout:
            print('[ERROR]: ' + key + ' ' + str(requests.ConnectTimeout))
        except requests.ConnectionError:
            print('[ERROR]: ' + key + ' ' + str(requests.ConnectionError))
        except requests.ReadTimeout:
            print('[ERROR]: ' + key + ' ' + str(requests.ReadTimeout))
        sevices_list[key] = new_value

```

### Вывод скрипта при запуске при тестировании:
```shell
vagrant@test-netology:~$
 ./task_2.py 
[ERROR]: drive.google.com IP mismatch: N/A 173.194.73.194
Service http:// drive.google.com available. HTTP_RESPONSE 200
[ERROR]: mail.google.com IP mismatch: N/A 173.194.73.83
Service http:// mail.google.com available. HTTP_RESPONSE 200
[ERROR]: google.com IP mismatch: N/A 64.233.165.100
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

vagrant@test-netology:~$
 for f in $(ls *.yaml *.json); do echo "file \"${f}\" contain data:" ;cat $f; echo -e "\n"; done
file "drive.google.com.json" contain data:
{
    "drive.google.com": "173.194.73.194"
}

file "drive.google.com.yaml" contain data:
drive.google.com: 173.194.73.194


file "google.com.json" contain data:
{
    "google.com": "64.233.165.100"
}

file "google.com.yaml" contain data:
google.com: 64.233.165.100


file "mail.google.com.json" contain data:
{
    "mail.google.com": "173.194.73.83"
}

file "mail.google.com.yaml" contain data:
mail.google.com: 173.194.73.83
```

### json-файл(ы), который(е) записал ваш скрипт:
[drive.google.com.json](drive.google.com.json)  
[google.com.json](google.com.json)  
[mail.google.com.json](mail.google.com.json)  

### yml-файл(ы), который(е) записал ваш скрипт:
[drive.google.com.yaml](drive.google.com.yaml)  
[google.com.yaml](drive.google.com.yaml)  
[mail.google.com.yaml](drive.google.com.yaml)  

