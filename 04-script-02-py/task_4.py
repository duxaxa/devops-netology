#!/usr/bin/env python3

import socket
import requests

sevices_list = {"drive.google.com": "N/A", "mail.google.com": "N/A", "google.com": "N/A"}

while True:
    for key, value in sevices_list.items():
        previous_value = value
        new_value = socket.gethostbyname(key)
        if previous_value != new_value:
            print('[ERROR]: ' + key + ' IP mismatch: ' + previous_value + ' ' + new_value)

        try:
            response = requests.get('http://' + new_value, timeout=1)
            if response.status_code == 200:
                print('Service http:// ' + key + ' available. HTTP_RESPONSE ' + str(response.status_code))
        except requests.ConnectTimeout:
            print('[ERROR]: ' + key + ' ' + str(requests.ConnectTimeout))
        except requests.ConnectionError:
            print('[ERROR]: ' + key + ' ' + str(requests.ConnectionError))
        sevices_list[key] = new_value
