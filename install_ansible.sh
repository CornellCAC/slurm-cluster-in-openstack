#!/bin/bash

python3 -m venv ansible
source ./ansible/bin/activate

pip install --upgrade pip wheel
pip install --upgrade ansible python-openstackclient openstacksdk

ansible-galaxy install -r requirements.yml
