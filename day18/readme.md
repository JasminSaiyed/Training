# Project 01
## Problem Statement
You are tasked with deploying a three-tier web application (frontend, backend, and database) using Ansible roles. The frontend is an Nginx web server, the backend is a Node.js application, and the database is a MySQL server. Your solution should use Ansible Galaxy roles where applicable and define appropriate role dependencies. The deployment should be automated to ensure that all components are configured correctly and can communicate with each other.
# Steps and Deliverables
## Define Project Structure
Create a new Ansible project with a suitable directory structure to organize roles, playbooks, and inventory files.
- mkdir of project 
- cd project
- mkdir playbooks roles
![alt text](<Screenshot from 2024-08-06 01-21-41.png>) 
# Role Selection and Creation
Select appropriate roles from Ansible Galaxy for each tier of the application:
+ Nginx for the frontend.
+ Node.js for the backend.
+ MySQL for the database.
+ Create any custom roles needed for specific configurations that are not covered by the Galaxy roles.
![alt text](<Screenshot from 2024-08-06 01-21-31.png>)
+ Dependencies Management
Define dependencies for each role in the meta/main.yml file.
Ensure that the roles have appropriate dependencies, such as ensuring the database is set up before deploying the backend.
- roles codes for frontend
# roles/nginx_frontend/meta/main.yml
---
galaxy_info:
  author: YourName
  description: Role to install and configure Nginx as a frontend web server.
  company: YourCompany
  license: MIT
  min_ansible_version: 2.9

  platforms:
    - name: Debian
      versions:
        - buster
        - bullseye
    - name: Ubuntu
      versions:
        - bionic
        - focal
        - jammy

  categories:
    - web
---
# handlers file for nginx_frontend
- name: restart nginx
  service:
    name: nginx
    state: restarted
  become: true

---
# tasks file for nginx_frontend
- name: Ensure Nginx is installed
  apt:
    name: nginx
    state: present
  become: true

- name: Copy Nginx configuration file
  template:
    src: nginx.conf.j2
    dest: /etc/nginx/nginx.conf
  notify: restart nginx
  become: true

- name: Ensure Nginx is started and enabled
  service:
    name: nginx
    state: started
    enabled: true
  become: true

# roles/nginx_frontend/templates/nginx.conf.j2
user {{ nginx_user }};
worker_processes {{ nginx_worker_processes }};
pid /run/nginx.pid;

events {
    worker_connections 768;
}

http {
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;

    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log {{ nginx_access_log }} main;
    error_log {{ nginx_error_log }};

    gzip on;

    include /etc/nginx/conf.d/*.conf;
    include /etc/nginx/sites-enabled/*;


# roles of backend main.yml
---
nodejs_version: "14.x"
app_directory: "/opt/nodejs_app"
app_user: "nodejs"
app_group: "nodejs"
# roles/nodejs_backend/meta/main.yml
---
galaxy_info:
  author: YourName
  description: Role to install and configure Node.js as a backend server.
  company: YourCompany
  license: MIT
  min_ansible_version: 2.9

  platforms:
    - name: Debian
      versions:
        - buster
        - bullseye
    - name: Ubuntu
      versions:
        - bionic
        - focal
        - jammy

  categories:
    - web

dependencies: []
# handlers file for nodejs_backend
---
- name: restart nodejs_app
  systemd:
    name: nodejs_app
    state: restarted
  become: true
# roles of nodejs_backend main.yml
---
- name: Add NodeSource APT repository
  apt_key:
    url: https://deb.nodesource.com/gpgkey/nodesource.gpg.key
    state: present
  become: true

- name: Add NodeSource repository
  apt_repository:
    repo: deb https://deb.nodesource.com/node_14.x {{ ansible_distribution_release }} main
    state: present
  become: true

- name: Update APT package list
  apt:
    update_cache: yes
  become: true

- name: Ensure Node.js is installed
  apt:
    name: nodejs
    state: present
  become: true

- name: Copy Node.js application files
  copy:
    src: /path/to/your/app/
    dest: /opt/nodejs_app/
    owner: nodejs
    group: nodejs
    mode: 0755
  become: true

- name: Install Node.js dependencies only if the host is part of backend group
  apt:
    name: nodejs
    state: present
  when: "'backend' in group_names"

- name: Install npm only if the host is part of backend group
  apt:
    name: npm
    state: present
  when: "'backend' in group_names"
#- name: Install Node.js dependencies
 # npm:
   # path: /opt/nodejs_app
   # state: present
 # become: true

- name: Start Node.js application
  systemd:
    name: nodejs_app
    enabled: yes
    state: started
    daemon_reload: yes
    exec_start: /usr/bin/node /opt/nodejs_app/index.js
    user: nodejs
    group: nodejs
  become: true
# roles/nodejs_backend/templates/nodejs_app.service.j2
[Unit]
Description=Node.js Application

[Service]
ExecStart=/usr/bin/node /var/www/nodejs_app/app.js
Restart=always
User=nobody
Group=nogroup
Environment=PATH=/usr/bin:/usr/local/bin
Environment=NODE_ENV=production
WorkingDirectory=/var/www/nodejs_app

[Install]
WantedBy=multi-user.target

# vars file for nodejs_backend
app_name: my_nodejs_app
app_port: 3000
app_env: production

---
# defaults file for mysql_database
mysql_root_password: "root_password"
mysql_databases:
  - name: "app_db"
    encoding: "utf8"
mysql_users:
  - name: "app_user"
    password: "user_password"
    priv: "app_db.*:ALL"

---
# handlers file for mysql_database
- name: restart mysql
  service:
    name: mysql
    state: restarted
  become: true
# roles/mysql_database/meta/main.yml
---
galaxy_info:
  author: YourName
  description: Role to install and configure MySQL server.
  company: YourCompany
  license: MIT
  min_ansible_version: 2.9

  platforms:
    - name: Debian
      versions:
        - buster
        - bullseye
    - name: Ubuntu
      versions:
        - bionic
        - focal
        - jammy

  categories:
    - database

dependencies: []

---
# tasks file for mysql_database
- name: Install MySQL server
  apt:
    name: mysql-server
    state: present
  become: true

- name: Start and enable MySQL service
  service:
    name: mysql
    state: started
    enabled: true
  become: true

- name: Set MySQL root password
  mysql_user:
    name: root
    host: "{{ item }}"
    password: "{{ mysql_root_password }}"
    login_unix_socket: /var/run/mysqld/mysqld.sock
  with_items:
    - localhost
    - 127.0.0.1
    - ::1
  when: mysql_root_password != ''
  become: true

- name: Remove anonymous MySQL users
  mysql_user:
    name: ''
    host_all: yes
    state: absent
    login_user: root
    login_password: "{{ mysql_root_password }}"
  become: true

- name: Remove the MySQL test database
  mysql_db:
    name: test
    state: absent
    login_user: root
    login_password: "{{ mysql_root_password }}"
  become: true

- name: Create MySQL database
  mysql_db:
    name: "{{ mysql_databases }}"
    state: present
    login_user: root
    login_password: "{{ mysql_root_password }}"
  become: true

- name: Create MySQL user
  mysql_user:
    name: "{{ mysql_users.name }}"
    password: "{{ mysql_users.password }}"
    priv: "{{ mysql_users.priv }}"
    state: present
    login_user: root
    login_password: "{{ mysql_root_password }}"
  become: true


+ Inventory Configuration
Create an inventory file that defines the groups of hosts for each tier (frontend, backend, database).
+ Ensure proper group definitions and host variables as needed.
+ Playbook Creation
Create a playbook (deploy.yml) that includes and orchestrates the roles for deploying the application.
---
- name: Deploy Three-Tier Web Application
  hosts: all
  become: true
  roles:
    - role: mysql_database
      when: "'database' in group_names"
    - role: nodejs_backend
      when: "'backend' in group_names"
    - role: nginx_frontend
      when: "'frontend' in group_names"

+ Ensure the playbook handles the deployment order and variable passing between roles.
+ Role Customization and Variable Definition
Customize the roles by defining the necessary variables in group_vars or host_vars as needed for the environment.
Ensure sensitive data like database credentials are managed securely.
+ Testing and Validation
Create a separate playbook for testing the deployment (test.yml) that verifies each tier is functioning correctly and can communicate with the other tiers.
Use Ansible modules and tasks to check the status of services and applications.

# playbooks/test.yml
---
- name: Test Three-Tier Web Application Deployment
  hosts: all
  tasks:
    - name: Ensure MySQL service is running
      service:
        name: mysql
        state: started
      when: "'database' in group_names"

    - name: Ensure Node.js application is running
      shell: systemctl is-active nodejs_app
      register: nodejs_status
      changed_when: false
      when: "'backend' in group_names"

    - name: Check Node.js application status
      debug:
        msg: "Node.js app is {{ nodejs_status.stdout }}"

    - name: Ensure Nginx service is running
      service:
        name: nginx
        state: started
      when: "'frontend' in group_names"
+ Documentation
Document the setup process, including any prerequisites, role dependencies, and how to run the playbooks.
Include a README.md file that provides an overview of the project and instructions for use.
+ Deliverables
Ansible Project Directory Structure
Organized directory structure with roles, playbooks, inventory, and configuration files.
Role Definitions and Dependencies
meta/main.yml files for each role defining dependencies.
Customized roles with necessary configurations.
Inventory File
Inventory file defining groups and hosts for frontend, backend, and database tiers.
Playbook for Deployment (deploy.yml)
Playbook that orchestrates the deployment of the three-tier application.
Playbook for Testing (test.yml)
Playbook that verifies the deployment and functionality of each tier.
