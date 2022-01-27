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
