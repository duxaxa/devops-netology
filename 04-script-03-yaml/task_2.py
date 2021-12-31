#!/usr/bin/env python3

import socket
import requests
import json
import yaml

sevices_list = {"drive.google.com": "N/A", "mail.google.com": "N/A", "google.com": "N/A"}
json_logfile = 'log.json'
yaml_logfile = 'log.yaml'

while True:
    for key, value in sevices_list.items():
        previous_value = value
        new_value = socket.gethostbyname(key)
        if previous_value != new_value:
            message = '[ERROR]: ' + key + ' IP mismatch: ' + previous_value + ' ' + new_value
            print(message)
            message_json = ("service" : sevices_list[key], "address" : previous_value)
            with open(json_logfile, 'a') as json_log:
                json_log.write(yaml.dump(message))


        try:
            response = requests.get('http://' + new_value, timeout=1)
            if response.status_code == 200:
                print('Service http:// ' + key + ' available. HTTP_RESPONSE ' + str(response.status_code))
        except requests.ConnectTimeout:
            print('[ERROR]: ' + key + ' ' + str(requests.ConnectTimeout))
        except requests.ConnectionError:
            print('[ERROR]: ' + key + ' ' + str(requests.ConnectionError))
        sevices_list[key] = new_value
