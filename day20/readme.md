+ Project 01
- Inventory Plugins
Activity: Configure a dynamic inventory plugin to manage a growing number of web servers dynamically. Integrate the plugin with Ansible to automatically detect and configure servers in various environments.
Deliverable: Dynamic inventory configuration file or script, demonstrating the ability to automatically update the inventory based on real-time server data.
Activity: Tune Ansible performance by adjusting settings such as parallel execution (forks), optimizing playbook tasks, and reducing playbook run time.
Deliverable: Optimized ansible.cfg configuration file, performance benchmarks, and documentation detailing changes made for performance improvement.
Create ansible.cfg 
Create aws_ec2.yml
plugin: aws_ec2
regions:
  - us-west-1
filters:
  instance-state-name:
    - running
    # tag:Name: Jasminbanu
hostnames:
  - dns-name
compose:
  ansible_host: public_dns_name

![alt text](<Screenshot from 2024-08-08 17-46-53.png>)
- Performance Tuning
Activity: Tune Ansible performance by adjusting settings such as parallel execution (forks), optimizing playbook tasks, and reducing playbook run time.
Deliverable: Optimized ansible.cfg configuration file, performance benchmarks, and documentation detailing changes made for performance improvement.

[defaults]
inventory = aws_ec2.yml
enable_plugins = script, aws_ec2
private_key_file = ansible-new.pem

- Debugging and Troubleshooting Playbooks
Activity: Implement debugging strategies to identify and resolve issues in playbooks, including setting up verbose output and advanced error handling.
Deliverable: Debugged playbooks with enhanced error handling and logging, including a troubleshooting guide with common issues and solutions.
- creating playbook
- name: Launch an EC2 instance
  hosts: localhost

  tasks:
  - name: Create security group
    amazon.aws.ec2_security_group:
      name: "new-security-group"
      description: "Sec group for app"
      rules:
        - proto: tcp
          ports:
            - 22
          cidr_ip: 0.0.0.0/0
          rule_desc: allow all on ssh port
![alt text](<Screenshot from 2024-08-08 22-24-09.png>)
- Exploring Advanced Modules
Activity: Use advanced Ansible modules such as docker_container to manage containerized applications and aws_ec2 for AWS infrastructure management, demonstrating their integration and usage.
Deliverable: Playbooks showcasing the deployment and management of Docker containers and AWS EC2 instances, along with documentation on the benefits and configurations of these advanced modules.
- create Docker Container module

- name: Docker Container Creation
  hosts: localhost

  tasks:
  - name: Create and start Docker container
    community.docker.docker_container:
      name: my_nginx
      image: nginx:latest
      state: started
      ports:
      - "8084:80"
      volumes:
      - /my/local/path:/usr/share/nginx/html
![alt text](<Screenshot from 2024-08-08 22-22-23.png>)