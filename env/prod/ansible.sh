#!/bin/bash
cd /home/ubuntu
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
sudo python3 get-pip.py
sudo python3 -m pip install ansible
tee -a playbook.yml > /dev/null <<EOT
- hosts: localhost
  tasks:
    - name: Instalando o python3, virtualenv
      apt:
        pkg:
          - python3
          - virtualenv
        update_cache: 'yes'
      become: 'yes'
    - name: Git Clone
      ansible.builtin.git:
        repo: 'https://github.com/guilhermeonrails/clientes-leo-api.git'
        dest: /home/ubuntu/tcc
        version: master
        force: yes
    - name: Instalando dependencias com pip(django e django Rest)
      pip:
        virtualenv: /home/ubuntu/tcc/venv
        requirements: /home/ubuntu/tcc/requirements.txt
    - name: Verificando se o projeto ja existe
      stat:
        path: /home/ubuntu/tcc/setup/settings.py
      register: projeto
    - name: Iniciando o projeto
      shell: >-
        . /home/ubuntu/tcc/venv/bin/activate; django-admin startproject setup
        /home/ubuntu/tcc/
      when: not projeto.stat.exists
    - name: Alterando o hosts do settings
      lineinfile:
        path: /home/ubuntu/tcc/setup/settings.py
        regexp: ALLOWED_HOSTS
        line: 'ALLOWED_HOSTS = ["*"]'
        backrefs: 'yes'
    - name: Instalar setuptools
      pip:
        name: setuptools
        virtualenv: /home/ubuntu/tcc/venv    
    - name: Configurando o banco de dados
      shell: '. /home/ubuntu/tcc/venv/bin/activate; python /home/ubuntu/tcc/manage.py migrate'
    - name: Carregando os dados iniciais
      shell: '. /home/ubuntu/tcc/venv/bin/activate; python /home/ubuntu/tcc/manage.py loaddata clientes.json'
    - name: Iniciando o servidor
      shell: '. /home/ubuntu/tcc/venv/bin/activate; nohup python /home/ubuntu/tcc/manage.py runserver 0.0.0.0:8000 &'  
EOT
ansible-playbook playbook.yml