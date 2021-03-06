Ansible Networking
=================


<ul>
<li>
<ul>
<li><a href="#common-commands">Common Commands</a></li>
</ul>
</li>
<li><a href="#network-automation-using-ansible">Network Automation using Ansible</a>
<ul>
<li><a href="#ansibles-role-in-network-automation">Ansible’s role in Network Automation</a></li>
<li><a href="#templating-with-jinja2">Templating with Jinja2</a></li>
<li><a href="#napalm">NAPALM</a></li>
<li><a href="#ntc-ansible">NTC-Ansible</a></li>
<li><a href="#regex--textfsm">Regex / TextFSM</a></li>
<li><a href="#ara-ansible-run-analysis">ARA: Ansible Run Analysis</a></li>
</ul>
</li>
<li><a href="#installation">Installation</a>
<ul>
<li><a href="#enable-virtualisation">Enable Virtualisation</a></li>
<li><a href="#install-virtual-box">Install Virtual Box</a></li>
<li><a href="#install-vagrant">Install Vagrant</a></li>
<li><a href="#running-vm--vagrant-file">Running VM / Vagrant File</a></li>
<li><a href="#startstop-vagrant-image">Start/Stop Vagrant image</a></li>
</ul>
</li>
<li><a href="#running-ansible">Running Ansible</a>
<ul>
<li><a href="#explaining-docker">Explaining Docker</a></li>
<li><a href="#running-ansible--ara-docker-container">Running Ansible & ARA Docker Container</a>
<ul>
<li><a href="#start-ara-and-ansible-container">Start ARA and Ansible container:</a></li>
<li><a href="#start-ansible-container-only">Start Ansible container only:</a></li>
<li><a href="#stop-containers">Stop containers:</a></li>
</ul>
</li>
<li><a href="#running-ansible-playbook">Running Ansible Playbook</a>
<ul>
<li><a href="#run-playbook---helloworld.yml">Run Playbook - HelloWorld.yml</a></li>
</ul>
</li>
</ul>
</li>
<li><a href="#running-ansible-on-network-devices">Running Ansible on Network Devices</a>
<ul>
<li><a href="#gns3-as-a-test-platform-optional">GNS3 as a test platform (optional)</a></li>
<li><a href="#roles">Roles</a></li>
<li><a href="#configuration-file---ansible.cfg">Configuration file - Ansible.cfg</a></li>
<li><a href="#inventory-file--hosts-file">Inventory File / Hosts File</a></li>
<li><a href="#host-vars--group-vars">host vars / group vars</a></li>
<li><a href="#vars-in-excel">Vars in Excel</a></li>
<li><a href="#running-playbook-on-ios">Running Playbook on IOS</a></li>
<li><a href="#providers-authentication">Providers (Authentication)</a></li>
</ul>
</li>
<li><a href="#ara">ARA</a></li>
<li><a href="#facts">Facts</a>
<ul>
<li><a href="#show-commands">Show Commands</a></li>
<li><a href="#napalm-get-facts">NAPALM Get Facts</a></li>
<li><a href="#ntc-show-command">NTC Show Command</a></li>
<li><a href="#textfsm">TextFSM</a>
<ul>
<li><a href="#advanced-textfsm---multi-line-parsing">Advanced TextFSM - Multi-line parsing</a></li>
</ul>
</li>
</ul>
</li>
<li><a href="#config">Config</a>
<ul>
<li><a href="#jinja2-templating">Jinja2 Templating</a></li>
<li><a href="#config-merge-role">Config Merge Role</a></li>
<li><a href="#config-replace-role">Config Replace Role</a></li>
<li><a href="#config-backup-role">Config Backup Role</a></li>
<li><a href="#config-on-interfaces--dynamic-config">Config on interfaces / Dynamic Config</a></li>
</ul>
</li>
</ul>
 

Common Commands
----------------------
| Description | Command |
|--|--|
| start vagrant | vagrant up |
| ssh into vagrant | vagrant ssh |  
| start Ansible and ARA containers | cd /vagrant && docker start ara  && docker-compose run --service-ports --rm ansible |
| Run Ansible Playbook | ansible-playbook PLAYBOOK.yml -e ansible_user=USERNAME |
| shutdown vagrant machine | vagrant halt |
| view all containers | docker ps -a |
| stop all containers | docker stop $(docker ps -aq) |
| remove all containers| docker rm $(docker ps -aq) |
| Container initial launch | cd /vagrant && docker-compose run --service-ports  --name ara -d ara  && docker-compose run --service-ports --rm ansible |

Network Automation using Ansible
============================

The focus of this document is to explain the process of network automation for Cisco IOS devices. I will take you through the fundamentals of Ansible and provide a user guide for the [Ansible-Networking Git repository](https://github.com/TheKnightCoder/Ansible-Networking).

The two main automation processes covered in this document are:
> - Adding/Replacing Config
> - Gathering facts/information on network devices

To understand the automation process it is important to have a brief understanding of the following libraries and frameworks:

Ansible's role in Network Automation
----------------------------------------------
![Ansible Logo](https://upload.wikimedia.org/wikipedia/commons/0/05/Ansible_Logo.png)

Ansible is an open source automation platform. It can help you with configuration management, application deployment, task automation and IT orchestration. For example it can install a software on hundreds of servers from a single control machine, it will not reinstall software if the same version is already installed and can make server specific configuration changes. It can also run IOS commands and config changes!

Think of Ansible as the distribution center, it will send a task to many devices from a central Ansible control machine. Ansible runs tasks from a 'playbook'.  A playbook is simply put a list of tasks, along with some settings such as which machines to run the playbook on. A task is a command to be executed, such as creating a new folder. Every task corresponds to a module, which is either in-built, community created or custom. Every module is written in the Python programming language, therefore you can run your own python code in Ansible by creating a custom modules.

So if we break it down we are essentially running python code on multiple devices and Ansible is helping us do that, it is like the glue that sticks everything together.

As Cisco IOS devices cannot run python we set Ansible to run in 'local' connection mode and we access the IOS devices via SSH. The python code is run on the control machine and commands are sent and outputs to devices retrieved from the devices via SSH.

![1ansible_diagram](https://user-images.githubusercontent.com/24293640/33616163-0c3ff590-d9d4-11e7-95f4-19280b1c223c.png)

Watch these video tutorials to gain a greater understanding of Ansible: 
> - [Code Review Videos](https://www.codereviewvideos.com/course/ansible-tutorial) - (First 4 videos are just installation, it is recommended to use the installation guide below rather than the one in this video)
> - [Ben's IT Lessons](https://www.youtube.com/watch?v=icR-df2Olm8&list=PLFiccIuLB0OiWh7cbryhCaGPoqjQ62NpU)

For more information visit the [Ansible docs](http://docs.ansible.com/ansible/latest/intro_getting_started.html).

Templating with Jinja2
----------------------------
![Jinja2 Logo](http://jinja.pocoo.org/docs/2.10/_static/jinja-small.png)

Templating is the most important thing to know when automating network config, thankfully it can also be the simplest. 

A Jinja2 template is just a regular text file with a twist, it uses special notations which are then replaced with a variables. Jinja2 variables have the following notation `{{ foo }}`. When the template is processed to produce an output text file, it will replace all `{{ foo }}` with the actual 'foo' variable defined in Ansible. (foo may be replaced with any variable name).

A lot can be accomplished with the above information however Jinja2 is capable of much more with its ability to use for loops, if statements, filters and inheritance. The [Jinja2 documentation](http://jinja.pocoo.org/docs/2.10/) is very well written and can be used to learn how to implement these concepts.

An in-depth understanding of Ansible and Python is not needed for most config changes, however it can be useful when making more complex templates. An example of this is when you need to add config to every interface on multiple switches of varying models. One device may have 4 interfaces while the other has 7, and the interfaces may have different names such as Fa0/1 and Gi0/1. One way to solve this problem is to use a show command to dynamically get the list of interfaces and then apply the config to those interfaces, this will need comprehensive understanding of Ansible. A simpler solution to this problem would be to group the devices by model and manually list the interfaces for each group (in the group vars). This would require knowledge of the number and names of the interfaces for each model in the network but would require no additional Ansible/Python.

N.B. This specific problem has been solved, see [Dynamic Config](#config-on-interfaces--dynamic-config) section for more detail.
 
For more information visit the [Jinja2 docs](http://jinja.pocoo.org/docs/).

NAPALM
------------
![NAPALM Logo](https://avatars0.githubusercontent.com/u/16415577?s=200&v=4)

NAPALM (Network Automation and Programmability Abstraction Layer with Multi-vendor support) is a Python library that implements a set of functions to interact with different network device Operating Systems using a unified API. By using NAPALM it makes it much easier to carry out tasks on network devices such as config replacement. NAPALM has Ansible modules which allows them to fully integrate with Ansible.

In the Ansible Networking repository NAPALM is primarily used to install config by using the [napalm_install_config](https://github.com/napalm-automation/napalm-ansible/blob/develop/napalm_ansible/modules/napalm_install_config.py) module. When NAPALM is used to replace/merge your config it is able to generate a diff file, this file will outline all changes that will be made on the devices which can then be verified and then committed. A backup is also automatically generated and stored in a offline location (and locally on network device) ensuring you are able to rollback changes.

NAPALM also has other useful modules such as [napalm_get_facts](https://github.com/napalm-automation/napalm-ansible/blob/develop/napalm_ansible/modules/napalm_get_facts.py) which is a module that standardises the retrieval of information from network devices regardless of which vendor is being used. This means that the same code can be used and the structure of the output is known. To find out more about the information napalm_get_facts is capable of retrieving visit 'NetworkDevices' in the [docs](http://napalm.readthedocs.io/en/latest/base.html). Also see `Ansible-Networking\example-playbooks\reporting\napalm_get_facts.yml` playbook for an example of how to use 'napalm_get_facts' with Ansible.

Other useful NAPALM Modules:
- [napalm_ping](https://github.com/napalm-automation/napalm-ansible/blob/develop/napalm_ansible/modules/napalm_ping.py) - Executes ping on the device and returns response using NAPALM
- [napalm_validate](https://github.com/napalm-automation/napalm-ansible/blob/develop/napalm_ansible/modules/napalm_validate.py) - Validate deployments using YAML file describing the state you expect your devices to be in. See [Validating deployments docs](http://napalm.readthedocs.io/en/latest/validate/).
>Note that this is meant to validate state, meaning live data from the device, not the configuration. Because that something is configured doesn’t mean it looks as you want.

Although the code in our repository has been designed for Cisco IOS, it can be adapted to work with other vendors by changing very little code thanks to NAPALM. 

This can be done by copying the `Ansible-Networking\lib\roles\ios` folder and adapting the code:
- Adapting the dev_os variable in `Ansible-Networking\lib\roles\ios\connect\defaults` (see [drivers names](http://napalm.readthedocs.io/en/latest/support/index.html) for supported devices) 
- Adapting ios\backup role `Ansible-Networking\lib\roles\ios\backup`
- Remove `configure archive` task in the ios\replace role.
- Changing any other IOS specific code

For more information visit the [NAPALM docs](https://napalm.readthedocs.io/en/latest/), [NAPALM repository](https://github.com/napalm-automation/napalm) and the [NAPALM Ansible repository](https://github.com/napalm-automation/napalm-ansible)

NTC-Ansible
----------------
NTC-Ansible is another library for network devices. This another library which supports IOS, Nexus and Arista. NTC-Ansible has useful modules for IOS such as outputting structured data for IOS specific show commands, copying files to the network device, updating firmware.

Useful NTC modules:
- ntc_show_command - gets structured data from devices that don't have an API
- ntc_install_os -  installs a new operating system or just sets boot options
- ntc_file_copy - copies a file from the Ansible control host to a network device.
- ntc_reboot - reboots a network device.

For more information visit the [NTC-Ansible repository](https://github.com/networktocode/ntc-ansible)

Regex / TextFSM
---------------------
Regular Expression (Regex) is another essential skill which is needed in network automation, it will give you the ability to format a 'show' command into something a computer can easily handle. Currently the Cisco IOS is built for human-readability however it is not very good for computers. For computers to be able to handle data it needs to be formatted in a way that is more appropriate such as dictionaries, csv, json, sql etc rather than a block of text. TextFSM will help you do just that, it will take a template file, and text input (such as command responses from the CLI of a device) and returns a list of records that contains the data parsed from the text. It is a python library which is integrated into Ansible. 
(NTC-Ansible ntc_show_commands also uses TextFSM to parse it's data.)

To create TextFSM templates you will need to know regex. This will give you the ability to parse any show command into Ansible. To learn regex I recommend watching these [videos tutorials by The Coding Train](https://www.youtube.com/watch?v=7DG3kCDx53c&list=PLRqwX-V7Uu6YEypLuls7iidwHMdCM6o2w). The ntc_show_commands has a library of templates already written for IOS show commands. These templates can be found in `Ansible-Networking\lib\modules\ntc-ansible\ntc-templates\templates`

To learn more about regular expressions watch [The Coding Train Videos](https://www.youtube.com/watch?v=7DG3kCDx53c&list=PLRqwX-V7Uu6YEypLuls7iidwHMdCM6o2w).

Also practice regular expressions at [regexr.com](https://regexr.com/). Make sure to turn on the multi-line flag as TextFSM uses multi-line regex.

See the [TextFSM docs](https://github.com/google/textfsm/wiki/TextFSM) to learn how to create templates.

ARA: Ansible Run Analysis
--------------------------------
![ARA Logo](https://github.com/openstack/ara/raw/master/doc/source/_static/ara-with-icon.png)

ARA records Ansible playbook runs and makes the recorded data available and intuitive for users and systems. ARA keeps a record of all playbook runs on a database. In this repository ARA has been set to save runs in a SQLite file located at `files/db/ara.sqlite`. SQLite is being used as it keeps ARA simple and portable, all data is stored in a file in the ansible folder and nothing is stored in the Docker containers or VM. 

If needed the ARA database can be changed to a centralized database by changing the ARA_DATABASE environment variable in both the ARA and Ansible containers.

![ARA screenshot](https://github.com/openstack/ara/raw/master/doc/source/_static/reports.png)

As you can see from the image above, ARA shows you a complete summary of playbooks that have been run. It gives you very useful information such as which hosts the playbook was run on, the duration of the run and whether the playbook was successful.

Installation
=========
Ansible only runs on linux and therefore you need a Virtual Machine (VM) if you are running Mac OSX or Windows. A VM is a virtual operating system (OS) running on-top of your current OS, allowing you to run linux on Windows/OSX. This guide will assume you are running windows, if you are using Linux you will need to install docker and skip to [Running Ansible](#running-ansible) section.

Enable Virtualisation
-------------------------
You must enable virtualisation to run Virtual Machine (VM). To do this you need to enable Intel VT-x and VT-d if available in the BIOS/UEFI. You may need to visit your system Administrator. 

1. Turn on your computer and repeatedly press Delete, Esc, F1, F2, or F4. (Exact button depends on your PC model).
2. Find and enable Intel-VTx (The option may also be called VT-x, AMD-V, SVM, or Vanderpool).
3. If available enable Intel VT-d or AMD IOMMU

![virtualisation_bios](https://user-images.githubusercontent.com/24293640/33605215-a9727aaa-d9b0-11e7-8c28-987473d5b2ff.jpg)

Install Virtual Box
----------------------
Virtual Box is a free open-source software that allows you to run a virtual machine.  To install Virtual Box [download](https://www.virtualbox.org/wiki/Downloads) the 'Virtual box platform package', run the installer and keep hitting next until the installation is complete.

Install Vagrant
------------------
Vagrant is a tool for building and managing virtual machine environments in a single workflow. It will allow you to set up your virtual machine and install all the software packages with a single command  and the vagrant file found in this repository. By using vagrant we can ensure that all VMs using the same vagrant file are identical.

To install Vagrant [download](https://www.vagrantup.com/downloads.html) the installer, run the installer and keep hitting next until the installation is complete.

You will now need to reboot to complete the installation.

Running VM / Vagrant File
--------------------------------
1. Create a New Folder and rename it.
	I will be referring to this folder as the 'Ansible folder', this will be where all your Ansible files are stored.
2. Download and extract the [repository](https://github.com/TheKnightCoder/Ansible-Networking/archive/master.zip) into the root of your Ansible folder. (or you can clone the repo with recursive mode enabled)

>Make sure the actual files (vagrantfile etc.) are in the root of the Ansible folder.
>N.B: Alternatively you can clone the git command `git clone --recurse-submodules https://github.com/TheKnightCoder/Ansible-Networking-Docker /ansible`. Make sure recursive is enabled to ensure sub-modules are also cloned.

4. Open command prompt and navigate to the Ansible folder's location
	- Win+R then type `cmd` then ok
	- Enter command `cd C:\Path\to\AnsibleFolder` (replace the path)
>Tip: You can `Shift + Right Click` in the file explorer and select `open command window here`
5. Type `vagrant up` to start the VM
> Note: The first time this is run the vagrant image will be downloaded and VM will be provisioned. This may take some time, it will be faster after initial launch. (Make sure you are on a network that can does not block vagrant cloud or docker hub) 
6. Type `vagrant ssh` to ssh into the VM and access it's shell
7. To exit SSH type `exit` 
8. To turn off the VM type `vagrant halt`
9. Synced Folders - Any files stored in the Ansible folder can be accessed by the VM via the path /vagrant

Start/Stop Vagrant image
-------------------------------
- Start VM - To start the VM you simply need to navigate to the Ansible folder and type `vagrant up`
- SSH - You can access the VM shell by entering `vagrant ssh` command. Type `exit` to exit ssh. You can ssh into the VM in multiple windows.
- Stop VM - To stop the VM type `vagrant halt` from cmd Ansible folder.

Running Ansible
=============
To run Ansible I have created a Docker container with all the tools needed for network automation in this container. This has quite a few advantages over installing it directly onto the VM via vagrant such as being able to run network automation on any Linux machine without installation using the Docker image and using less resources if multiple instances of Ansible is needed.

Watch this video on [Docker Containers](https://www.youtube.com/watch?v=pGYAg7TMmp0) to find out more about the differences between Docker and Vagrant.

Explaining Docker
----------------------
Docker is a resource friendly way to run applications in an isolated environment which is easily replicable across multiple machines. Vagrant VMs achieve a similar function however are much more resource heavy because each VM needs an entire OS. They also usually have more than one application per VM which causes instability.

![docker-vm-container](https://user-images.githubusercontent.com/24293640/33762832-02dabeca-dc06-11e7-8bde-c6be1fa530b8.png)

Docker File - A Docker file is the source code of the Docker image. It is very similar to a vagrant file and contains information on what packages to install when building the image. Once compiled it forms a Docker Image.

Docker Image - This image contains the actual packages etc that were defined in the Docker File.

Container - This is an instance of the docker image. You may have multiple containers of one image and any change in one container is not reflected in the next container.

Volume - This is the permanent storage for a container. Containers are meant to be destroyed and recreated and important  data should be kept in a volume. The volume can be accessed by the host machine and any other container that is linked to the volume. Volumes can be mapped to a specific directory on the host machine.

Port Forwarding - For the docker container to access ports on your machine you must map the ports. 

Note: This must also be define in your Vagrant file so that the VM can access your machine

In this setup we use a Vagrant Synced folder to map your Ansible folder to /vagrant. We will then map this /vagrant folder to the Docker Container using volumes resulting in a link between your machine and the Docker container. (This folder in the docker container will be named /ansible)

See [this video](https://www.youtube.com/watch?v=pGYAg7TMmp0&index=1&list=PLoYCgNOIyGAAzevEST2qm2Xbe3aeLFvLc) from LearnCode.academy for a overview of docker.
For an in-depth guide on Docker search the many available tutorials on YouTube.  

Running Ansible & ARA Docker Container
------------------------------------------
The Ansible networking repository has two containers that can be run. One is the container that runs Ansible itself, the source code for this container can be found in `Dockerfile`. The other is ARA web server which allows you to view a report of all Ansible playbooks that have run via the web browser, the source code for this container can be found in `ARADockerfile`.

To run these two containers we will utilising the `docker-compose.yml` file which contains configuration for the containers such as ports and volumes.

### Start ARA and Ansible container:
1. SSH into vagrant VM (see [Running VM / Vagrant File](#running-vm--vagrant-file))
2. Enter the following command on **first ever** run:
<pre><code>cd /vagrant && docker-compose run --service-ports  --name ara -d ara  && docker-compose run --service-ports --rm ansible</code></pre>
3. Enter the following command on subsequent runs:
<pre><code>cd /vagrant && docker start ara  && docker-compose run --service-ports --rm ansible</code></pre>
>  - cd /vagrant - change directory to Ansible folder
>  - docker-compose run - starts the container using the configuration in the `docker-compose.yml` file
>  - --name <container name> - specifies container name
>  - --service-ports - maps the ports defined in the `docker-compose.yml` file
>  - -d - run in detached mode
>  - --rm - remove container on exit (Not working with ARA container)

Note: docker-compose up is not used as the ansible container needs to run bash in interactive mode

### Start Ansible container only:
1. If you would like to start Ansible without ARA. Enter the following command from VM:
<pre><code>cd /vagrant && docker-compose run --service-ports --rm ansible</code></pre>

### Stop containers:
1. `exit` out of Ansible container (this will stop and remove container due to --rm flag)
2. `docker stop ara`  stop ARA container

>Note: To stop all containers enter command `docker stop $(docker ps -aq)`

Running Ansible Playbook
--------------------------------

### Run Playbook - HelloWorld.yml
To run the `HelloWorld.yml` playbook go the `example-playbooks` folder directory then enter the following command:
```ansible-playbook HelloWorld.yml```

If successful the playbook will have created a new folder with the name `hello_world`

> Note: You must have an `ansible.cfg` file in the same folder with at least the following setting:
>```
> [defaults]
> inventory=./inventory
> ```

```
---
- name: Hello World!
  hosts: localhost
  gather_facts: false
  
  tasks:
  - name: Create a directory
    file: path=hello_world state=directory
```
YAML is white space sensitive, the indentation is very important when writing in YAML. Also take note of the single hyphens which denote the start of a list. See [YAML Syntax](http://docs.ansible.com/ansible/latest/YAMLSyntax.html) for more info.

- `---` Three Hyphens - This serves to signal the start of a document for YAML files
- `- name: Hello World!` - This is the name of the playbook being run
- `  hosts: localhost`  - This tells Ansible which hosts to run the playbook on
- `  gather_facts: false` - By default ansible will gather facts about each host it connects to. This task fails when connecting to Cisco devices and therefore is set to false.
- `tasks:`  - This is where the list of tasks begin for the playbook
- `-name: Create a directory` - descriptive name of task
- ` file: path=hello_world state=directory` - The name of the module to be run followed by arguments sent to the module.
`path` is the file being managed and `state=directory` is the state the path should be in. 
See [docs](http://docs.ansible.com/ansible/latest/file_module.html) for more information on the file module.

To understand the capabilities of each in-built module you must visit the [Ansible Documentation.](http://docs.ansible.com/ansible/latest/list_of_all_modules.html)


Running Ansible on Network Devices
=============================
GNS3 as a test platform (optional)
-----------------------------------------
Prerequisite:
- GNS3 installed 
- IOS image on local server

![gns3](https://user-images.githubusercontent.com/24293640/37344276-d8f08566-26c1-11e8-841a-9a3275172dc8.png)
1. Add a cloud device, this will represents your PC and will be used to connect your PC to the network. 
2. Right click the cloud and click configure.

![gns3-2](https://user-images.githubusercontent.com/24293640/37344675-ec844c4c-26c2-11e8-963d-aff6e0e2e45f.png)

3. You must now select a network interface for your virtual network to connect to.
4. Check `Show special Ethernet interfaces` to see all networks
5. Select `VirtualBox Host-Only Network`, then click 'Add' and 'OK'
6. Next build out your virtual network, you may connect your PC (cloud) to the network via a simple Ethernet Switch

![gns3-3](https://user-images.githubusercontent.com/24293640/37345990-2a9a1b94-26c6-11e8-9eb0-d1408230809a.png)

7. If you will be using NAPALM Config replace, NAPALM will require flash memory on the device. 
    To enable this on GNS3
    - Right click the device and select Configure.
    - Select memory and disks tab
    - Add memory to PCMCIA disk0
    - Click OK

![flash](https://user-images.githubusercontent.com/24293640/37591394-4df31892-2b63-11e8-98bb-ab399c795c79.png)    

8. Configure your network devices. SSH must be enabled on the devices. When configuring please consider the subnet of the network selected on step 5 which is used to connect the PC to the virtual network.
9. To configure start the device then right click and select console.

![subnet](https://user-images.githubusercontent.com/24293640/37591390-4aa21e54-2b63-11e8-986c-36ff2e1da563.png)

10. Once devices have been configured, start the devices and get ready to use Ansible with your virtual GNS3 network

Roles
-------
Roles are essentially tasks and variables from a playbook that have been separated for re-usability and abstraction. For more detail on roles visit the [Ansible docs](http://docs.ansible.com/ansible/latest/user_guide/playbooks_reuse_roles.html).

To use a role in the middle of a playbook use the [`include_role`](http://docs.ansible.com/ansible/latest/modules/include_role_module.html) module. See `example-playbook/config/storm_control.yml` for an example.

The roles created in this repository can be found in `lib/roles`

Configuration file - Ansible.cfg
-------------------------------------
The `ansible.cfg` file is used to modify the settings of Ansible, it resides in the same folder as the Ansible playbook.
The following are the the `ansible.cfg` settings used in this repository to run playbooks on Cisco IOS devices.
```
[defaults]
inventory = ./inventory
host_key_checking = false
timeout = 5
library = /ansible/lib/modules/
roles_path = /ansible/lib/roles/
remote_user = user
ask_pass = True
```
- inventory - Path to the inventory file
- host_key_checking - SSH key checking (see [docs](http://docs.ansible.com/ansible/latest/intro_getting_started.html#host-key-checking) for more info)
- timeout - SSH timeout to use on connection attempts
- library - Path to library/module files. Modules allow you to run user created custom functionality on Ansible  (see [docs](http://docs.ansible.com/ansible/latest/dev_guide/developing_modules.html) to find out more about modules).
- roles_path - Path to Roles. Roles essentially assist in the re-usability of Ansible tasks (see [docs](http://docs.ansible.com/ansible/latest/playbooks_reuse_roles.html) to find out more about roles).
- remote_user - default username Ansible will use in SSH 
- ask_pass - This controls whether an Ansible playbook should prompt for a password by default. 

For more settings visit the [docs](http://docs.ansible.com/ansible/latest/intro_configuration.html)

Inventory File / Hosts File
--------------------------------
The inventory file lists all the hosts that Ansible will connect to. These hosts can be put into groups to allow running playbooks against a specific group. The heading in brackets are the group names, under the group name is a list of hosts in the group.

Hosts can be listed with their domain name, if a domain name does not exist then an alias can be used and paired with the hosts IP address as shown below.

A host can have multiple groups and groups can child group within it. See [docs.](http://docs.ansible.com/ansible/latest/intro_inventory.html#groups-of-groups-and-group-variables)
```
[group_A]
hostA ansible_host='192.168.1.1'
hostB ansible_host='192.168.1.2'
hostC ansible_host='192.168.1.3' 

[group_B]
hostA
hostD ansible_host='192.168.1.4'
```
Visit the [docs](http://docs.ansible.com/ansible/latest/intro_inventory.html) for more information on the inventory file.

host vars / group vars
--------------------------
Each host and group assigned in the [inventory file](#inventory-file--hosts-file) can have variables assigned to them. This can be done within the inventory file itself, just like the `ansible_host` variable in the file above.

Defining variables in the inventory file can become inconvenient and convoluted, to resolve this we can use host_vars and group_vars variable files. These variable files are located in the folder `group_vars` and `host_vars` relative to the Ansible playbook file.

The files are named after the host/group name without an extension. For example the variable file for `hostA` will be located at `host_vars\hostA`. This file will be a YAML file (see [YAML docs](http://www.yaml.org/spec/1.2/spec.html) on how to write YAML files).

Here is an example variable file for hostA, 
```
hostname : hostA
vlans: 
	- name : VLAN_34
      ID: 34
      IP_address: 10.120.53.254 
      subnet_mask: 255.255.255.128
interfaces:
	- name : Fa0/1
      link_type : trunk
      description : Network::FROM_A::B
      allowed_vlans : [34,242,1,431,434,13]
    - name : Fa0/2
      link_type : trunk
      description : Network::FROM_A::C
      allowed_vlans : [34,232,431,414,13]
```
Same rules apply to group vars. All variables in a group var file will be given to each host within that group.

The variables can be used within the playbook and Jinja2 templates. To access the variables use Jinja2 notation, for example to access the hostname in the variable file type `{{ hostname }}`. 

N.B: When using variables in Ansible playbook they should also be surrounded in quotes e.g. `"This is {{ hostname }}"`

To access an index in a array use square brackets [i] and to access a variable within a dictionaries use dot separators.
e.g. `{{ interfaces[1].name }}` will refer to `Fa0/2`

To find out more about host and group variables visit [inventory docs](http://docs.ansible.com/ansible/latest/intro_inventory.html#hosts-and-groups).
To find out more about variable visit [variable docs](http://docs.ansible.com/ansible/latest/playbooks_variables.html)

Vars in Excel 
----------------
If you needed to generate config for 50 switches you may need to create 50 different host_var files. To make this easier I have created the `generate_vars` module that converts an excel sheet into group var and host var YAML files so that it can be read by Ansible. This does mean that var files will have less flexibility due the the 2 dimensional nature of excel sheets. The excel sheet is not able to represent 2 dimensional arrays or an dictionary within an dictionary. Arrays can be represented by using comma separated values in square bracket in a single cell, for example `[foo,bar]`.

![host_vars](https://user-images.githubusercontent.com/24293640/37835079-3960ca18-2ea7-11e8-9eb9-7e3bf4c3a7e8.png)

Above is an example of sheet for host vars, the sheet must be named `host_vars`. 
The first column is a list of all hostnames for which you would like to generate host var yaml files. All subsequent columns are variables, the heading of each column defines the variable name and the value in each cell is the value of that variable for a given host. When square brackets are used in a cell, with commas to separate the value it will be interpreted as and array.

![group_vars](https://user-images.githubusercontent.com/24293640/37834987-03b74bbc-2ea7-11e8-945e-be91d1e9073a.png)

The exact same rules apply to group vars as host vars. The sheet must be named `group_vars` and the first column is a list of group names.
See  \example-playbooks\config\var.xlsx for an example

Example (see \example-playbooks\config\generate_vars.yml):
```
  tasks:
    - name: generating vars
      generate_vars:
        src: vars.xlsx
```
After running the playbook your excel file will be converted into yml files that can be read by ansible. The files will be placed in a host_vars and group_vars folder.
![generated_hostvars](https://user-images.githubusercontent.com/24293640/37907019-ce9897a4-30fb-11e8-842c-2f5c8a718631.png)

|parameter  |required  |comment  |
|--|--|--|
|src  |Yes  |Path to excel var file  |


Running Playbook on IOS
-------------------------------
To run Ansible on Cisco IOS some parameters and settings need to be set. Firstly in the ansible.cfg it is essential that `host_key_checking = false` also within the playbook  `gather_facts: false` and `connection: local`. Connection is set to local because Cisco IOS devices cannot run python, therefore in local mode the Ansible controller will run the python and communicate with IOS device via SSH.

Here is an example of a simple playbook for IOS. It will run the `show ip interface brief`command and display it on screen.
```
---
- name: Output Show command
  hosts: "all"
  gather_facts: false
  connection: local
  
  tasks:                                    
    - name: show cmd that user entered 
      ios_command:
        commands: "show ip int br"
      register: output

    - name: show output on screen
      debug:
        var: output
```
A similar playbook can be found in `example-playbooks/reporting/show_cmd.yml`
Ansible.cfg:
```
[defaults]
inventory = ./inventory
host_key_checking = false
timeout = 5
library = /ansible/lib/modules/:$ara_location/plugins/modules
roles_path = /ansible/lib/roles/
remote_user = user
ask_pass = True
```
This file can be found in `example-playbooks/ansible.cfg` (Must be in same folder as playbook)

To run this playbook on a Cisco IOS device:
1. Make sure SSH is enabled and configured on the device and connected to your Ansible control machine via an Ethernet cable.
2. Make sure the `ansible.cfg` file settings are correct and is in the same folder as the playbook
3. Run the following command 
`ansible-playbook PLAYBOOK.yml -e ansible_user=USERNAME`
(You must replace PLAYBOOK with the name of your playbook and USERNAME with the SSH username used to access your  Cisco device)
Note: if `ask_pass = false` in ansible.cfg then add `-k` flag to the ansible-playbook command to prompt for password

`-e` allows you to set an Ansible variable via the command line before run-time.

Providers (Authentication)
--------------------------------
When connecting to network devices authentication is usually needed. This authentication data needs to given to the provider parameter in modules (NAPALM, NTC-Ansible and built-in modules). This can be done by creating a dictionary variable in the playbook/group vars/host vars. To make this easier I have created an Ansible role which is compatible with NAPALM, NTC-Ansible and built-in modules (See /lib/roles/ios/connect).

ios/connect role (default/main.yml)
```
provider:
  hostname: "{{ ansible_host }}"         #This is a parameter and is derived from your ansible inventory file
  host: "{{ ansible_host }}"             #Added for use with in-build IOS modules  
  username: '{{ ansible_user }}'         #The username to ssh with
  password: '{{ ansible_password }}'     #The line level password
  dev_os: 'ios'                          #The hardware operating system 
  
  platform: "cisco_ios"                  #NTC-Ansible specific variable
  connection: 'ssh'
```
As you can see the username is stored in the `ansible_user` variable and the password is stored in the `ansible_password` variable. The `ansible_user` variable should be entered in the command to run the playbook using the `-e` flag. The `ansible_password` will be prompted for if `ask_pass=true` in the ansible.cfg or the `-k` flag is used e.g. `ansible-playbook PLAYBOOK.yml -e ansible_user=USERNAME -k`.
(If you would like to store usernames and passwords I recommend using [Ansible Vault](https://docs.ansible.com/ansible/2.4/vault.html) for security)

N.B: The default user can be changed in the ansible.cfg file `remote_user = user`
N.B: ios/connect will not work in cases where user and passwords are different for each network devices. In these cases you can use group vars and host vars. (use [Ansible Vault](https://docs.ansible.com/ansible/2.4/vault.html) to secure any stored passwords)


ARA
===
ARA is a third party application which keeps record and records Ansible playbook runs. To access ARA run the ARA docker container in the [Running Ansible & ARA Docker Container](#running-ansible--ara-docker-container) section then open a web browser and visit [http://127.0.0.1:9191](http://127.0.0.1:9191)

For more on ARA see [docs](https://ara.readthedocs.io/en/latest/)

![ara](https://user-images.githubusercontent.com/24293640/37907452-124b4176-30fd-11e8-9f8e-ea9fe9c87985.png)


Facts
=====
In this section we will go over how to retrieve data from network devices and convert the data from human readable text to data structures that computers can easily manipulate. For example the command`show cdp neighbors` displays an output of a white space separated table, this data is difficult for computers to work with and it would be better if the data was converted to variables/dictionaries. 

Show Commands
----------------------
Ansible has a [built-in network modules](http://docs.ansible.com/ansible/latest/modules/list_of_network_modules.html) for Cisco IOS and other network devices. One of these modules is the [ios_command](http://docs.ansible.com/ansible/latest/modules/ios_command_module.html) module which allows you to enter show commands and retrieve the output.

This module is great for quickly displaying or logging a show command however it is not ideal in more complex operations due to the format Cisco IOS show commands are formatted.

See Example Playbook: `example-playbooks\reporting\show_cmd.yml`


NAPALM Get Facts
-----------------------
The `napalm_get_facts` module is able to retrieve structured data from network devices, this module creates a layer of abstraction allowing you to use the same playbook for multiple vendors. However due to its vendor agnostic nature it does not include commands specific to Cisco such as `show cdp neighbors` in it's base network driver (Network drivers can be extended to add functionality).

To get a full list of base data structures NAPALM is able to retrieve visit the [Network Driver](http://napalm.readthedocs.io/en/latest/base.html) section in the docs.

See Example Playbook: `example-playbooks\reporting\napalm_get_facts.yml`

```
---

- name: Napalm get facts
  hosts: all
  gather_facts: false
  connection: local 
  roles: 
    - ios/connect 

  tasks:      
    - name: get facts from device
      napalm_get_facts:                      
        provider: "{{ provider }}"
        filter: 'facts'               
      register: output                      

    - name: output to screen
      debug:
        var: output.ansible_facts.napalm_facts
```

The `ios/connect` role abstracts the provider variable needed to connect to napalm. This role can be found in `lib/roles/ios/connect`

This playbook is currently outputting the `get_facts()` function in the [docs](http://napalm.readthedocs.io/en/latest/base.html#napalm.base.base.NetworkDriver). To output other functions you must change`filter: 'facts'` in the playbook to the name of the function in the docs omitting the `get_`.

For example `filter: 'interfaces'` for the `get_interfaces()` function. 

(`output.ansible_facts.napalm_facts` may also need to be changed)

Update: It is possible to extend drivers and add custom functionality to NAPALM such as adding `show cdp neighbors` to the IOS driver. This has not been explored as the documentation for this was not available at the time of creating this repository. The documentation can be found in the [NAPALM docs](http://napalm.readthedocs.io/en/latest/tutorials/extend_driver.html).

NTC Show Command 
--------------------------
NTC Ansible's ntc_show_command is another Ansible module that will assist you in gather data from your networking devices. NTC Ansible supports IOS, NX-API for Nexus, and eAPI for Arista. 

NTC Ansible uses [TextFSM](#textfsm) to parse show commands into dictionaries. The TextFSM templates for NTC Ansible can be found in `lib/modules/ntc-ansible/ntc-templates/` directory. In the folder you are able to see all show commands supported and can view the source code to see how it works and/or to edit. Additional show commands can be easily added by creating a template and editing the `index` file in the ntc-template folder. (It may be better to use Ansible's native TextFSM support. see [TextFSM](#textfsm) section)

![templates](https://user-images.githubusercontent.com/24293640/37966732-3bf46b64-31c1-11e8-9ca1-fba8b0dce684.png)

NTC Template location `lib/modules/ntc-ansible/ntc-templates/`

See Example Playbook: `example-playbooks\reporting\ntc_show_command.yml`
```
---
- name: NTC Ansible show
  hosts: all
  gather_facts: false
  connection: local 
  roles: 
    - ios/connect 
   
  tasks:      
    - ntc_show_command:
        command: 'show ip int brief'
        template_dir: '/ansible/lib/modules/ntc-ansible/ntc-templates/templates'
        provider: "{{ provider }}"
      register: output                      

    - name: output to screen
      debug:
        var: output
```
template_dir - Path to NTC templates
command - show command you are trying to retrieve. Supported show commands can be found by looking in the NTC templates folder

Note: A limitation to create your own ntc_show_command is that every show command can only be linked to one template file. Therefore you cannot have two different data structures for a single command. In this case you may use Ansible's native TextFSM support.

For more visit [NTC Ansible docs](https://github.com/networktocode/ntc-ansible)

TextFSM
-----------
TextFSM is a flexible generic text parser that is primarily used for parsing the output of router CLI commands in Python. By writing relatively simple regex based text files, a multitude of command outputs can be parsed with minimal code.

The engine takes two inputs - a template file, and text input (such as command responses from the CLI of a device) and returns a list of records that contains the data parsed from the text.

It is essential to learn regex to be able to create TextFSM templates. To learn more about regular expressions watch [The Coding Train Videos](https://www.youtube.com/watch?v=7DG3kCDx53c&list=PLRqwX-V7Uu6YEypLuls7iidwHMdCM6o2w). Also practice regular expressions at [regexr.com](https://regexr.com/). Make sure to turn on the multi-line flag as TextFSM uses multi-line regex.

Once you have learned regex see the [TextFSM docs](https://github.com/google/textfsm/wiki/TextFSM) to learn how to create templates. 

To use the template in Ansible see the [docs](http://docs.ansible.com/ansible/latest/user_guide/playbooks_filters.html#network-cli-filters)
Also see the Example Playbook at `/example-playbooks/reporting/TextFSM_example.yml`


### Advanced TextFSM - Multi-line parsing 

The ntc_show_command templates do not take into account text which spans over multiple lines in a CLI table. An example of this situation is when you have a very long hostname, which results in the initial portion of the hostname being cut off when parsing the data. This is a problem I faced with `show cdp neigbors`. 

![CLI table](https://user-images.githubusercontent.com/24293640/34607820-4551031e-f20d-11e7-88e7-0e89fa6b6254.png)

NTC-Ansible CDP Neigbors Template
![cdp n](https://user-images.githubusercontent.com/24293640/37968074-18de3016-31c5-11e8-9c69-78ecc01371d4.png)

Custom CDP Neigbors Template to handle multiple lines
![cdp_neighbor_v2](https://user-images.githubusercontent.com/24293640/37968295-a38871cc-31c5-11e8-92e2-76287382246a.png)

As you can see from the above images I have used `-> Continue` line action to the read the Device ID over multiple lines. 

Every line of regex written in the template is a rule (excluding value lines).
Each state definition consists of a list of one or more rules. The FSM reads a line from the input buffer and tests it against each rule, in turn, starting from the top of the current state. If a rule matches the line, then the action is carried out and the process repeats (from the top of the state again) with the next line. However when the continue line action is used, the current line is retained and the next line resumes matching from the current rule. Since 'continue' line action retains the current line it allows matching over multiple lines. 

Config
======
Jinja2 Templating
---------------------
When automating configs for network devices Jinja2 is essential to learn. I highly recommend going through the 
[Jinja2 docs](http://jinja.pocoo.org/docs/2.10/) which is very well documented and easy to read.

A Jinja2 template is just a regular text file with a twist, it contains special notations which will be replaced with a variable. Jinja2 variables have the following notation `{{ foo }}`. When the template is processed to produce an output text file, it will replace all `{{ foo }}` with the actual 'foo' variable defined in Ansible. (foo may be replaced with any variable name).

A lot can be accomplished with the above information however Jinja2 is capable of much more with its ability to use for loops, if statements, filters and inheritance. The [Jinja2 documentation](http://jinja.pocoo.org/docs/2.10/) is very well written and can be used to learn how to implement these concepts.

Config Merge Role
----------------------
NAPALM has a module called `napalm_install_config` which will automate the process of installing config onto network devices. The ios/merge role (path `lib/roles/ios/merge`) uses the napalm_install_config module to merge configs. This role was built for Cisco IOS devices but can easily be adapted to work with other vendors. 

> N.B: To use with other vendors modify the provider (`dev_os` variable) of `ios/connect`. Also the ios/backup role must be recreated to work with the vendor. You may also use ios/universal_backup instead of ios/backup but it will be slower during run-time. 

This role will: 
- Use your Jinja2 config template file
- Generate the config files with template and variables (either using the excel sheet or the standard group_vars/host_vars folder)
- Create a backup of your current running config
- Generate Diff files of differences between old and new config
- Prompt to continue with Merge
- Merge the config
- Create config backup after changes

Dependencies:
- NAPALM Ansible
- ios/backup
- ios/connect
- generate_vars module

|parameter  |required  |comment  |
|--|--|--|
| template_path | Yes  | Path to config template  |
| var_path | Optional | Path to vars excel file. Uses generate_var module to convert excel to host/group vars. See [Vars in excel](#vars-in-excel) |
| dest | Optional | Path to output files (default ./files/config)|

See Example Playbook `example-playbooks\config\config_merge.yml`

See [NAPALM docs](http://napalm.readthedocs.io/en/latest/tutorials/ansible-napalm.html#install) to find out more about `napalm_install_config` module.

Config Replace Role
------------------------
NAPALM has a module called `napalm_install_config` which will automate the process of installing config onto network devices. The ios/replace role (path `lib/roles/ios/replace`) uses the napalm_install_config module to replace configs. This role was built for Cisco IOS devices but can easily be adapted to work with other vendors. 

> N.B: To use with other vendors modify the provider (`dev_os` variable) of `ios/connect` (see [drivers names](http://napalm.readthedocs.io/en/latest/support/index.html) for supported devices) . Also the ios/backup role must be recreated to work with the vendor. You may also use ios/universal_backup instead of ios/backup but it will be slower during run-time. Remove `configure archive` task (replace if needed).

This role will: 
- Turn on archive and set path to flash:mybackup (Cisco IOS cannot run a config replace without an archive path)
- Use your Jinja2 config template file
- Generate the config files with template and variables (either using the excel sheet or the standard group_vars/host_vars folder)
- Create a backup of your current running config
- Generate Diff files of differences between old and new config
- Prompt to continue with Replace
- Replace the config
- Create config backup after changes

Dependencies:
- NAPALM Ansible
- ios/backup
- ios/connect
- generate_vars module

|parameter  |required  |comment  |
|--|--|--|
| template_path | Yes  | Path to config template  |
| var_path | Optional | Path to vars excel file. Uses generate_var module to convert excel to host/group vars. See [Vars in excel](#vars-in-excel) |
| dest | Optional | Path to output files (default ./files/config)|

See Example Playbook `example-playbooks\config\config_replace.yml`

See [NAPALM docs](http://napalm.readthedocs.io/en/latest/tutorials/ansible-napalm.html#install) to find out more about `napalm_install_config` module.

Config Backup Role
------------------------
This role uses Ansible's built in [`ios_command`](http://docs.ansible.com/ansible/latest/modules/ios_command_module.html) module to run a `show running-config` command then stores the output in a text file. As it uses IOS specific modules and commands it will only work with IOS devices and must be recreated for other vendors. There is also the option to compress the output.

See Example Playbook `example-playbooks\config\backup.yml`

|parameter  |required  |comment  |
|--|--|--|
| backup_dir | Optional | Path to output backup configs (Default ./files/backup ) |
| isArchive | Optional | If set to true the output will be compressed (Default = true) |

Config on interfaces / Dynamic Config
-----------------------------------------------
By bringing together fact gathering and config templates you are able to produce dynamic configs. The idea is to pull data from network devices and use that information to produce a config. This is useful when working with interfaces as the number of interfaces may differ between network devices.

One specific example of this is adding storm control to every access port on the network. To do this we first need to gather a list of access ports then we apply the config with a template.

1.  To gather a list of access ports we first check the [NAPALM](http://napalm.readthedocs.io/en/latest/base.html) and [NTC-Ansible](https://github.com/networktocode/ntc-templates/tree/eabee5b6740d5128c272201c848b311db9d336ad/templates) library to see if there was any available templates to gather the data I needed.
2. If there are no suitable template we need to create our own using [TextFSM](#textfsm) and the [ios_command](http://docs.ansible.com/ansible/latest/modules/ios_command_module.html) module.

We can create a template to parse the `show interfaces status` command. This command displays both trunk and access ports, however we only want the access ports. Therefore we need to keep this in mind when creating our TextFSM template. As you can see from the image below all access ports have a number in the 'Vlan' column whereas trunk ports are labelled trunk. 

![show-interface-status](https://user-images.githubusercontent.com/24293640/38034036-498556b6-3299-11e8-98dd-b5191f520fcc.jpg)

Here is the TextFSM template:
```
Value INTERFACE (\S+\/\d+)

Start
  ^$INTERFACE\s+\S*\s+\S+\s+\d+\s+\S+\s+\S+\s+\S+ -> Record
```
I have used the `\d+` regular expression to only select rows where the 'vlan' columns have a number.

3. We now can create the Ansible playbook that uses the TextFSM template
```
---
- name: Apply storm control to all access ports (not trunk)
  hosts: "all"
  gather_facts: false
  connection: local
  
  tasks:                                    
    - name: Get access ports
      ios_command:
        commands: "show interface status"
      register: interfaces_temp
    - set_fact: 
        interfaces: "{{ interfaces_temp.stdout[0] | parse_cli_textfsm('/ansible/lib/parse_cli/cisco_ios_get_access_ports.template') }}"
    
    - name: Output test
	  debug:
	    var: interfaces
```
As you can see we have used the `ios_command` module to run the `show interface status` command and store the output into `interfaces_temp` variable. We then use the `set_fact` module to copy `interfaces_temp` to `interfaces` after using the [parse_cli_textfsm](http://docs.ansible.com/ansible/latest/user_guide/playbooks_filters.html#network-cli-filters) filter to parse the cli output with our TextFSM template. 

Then the debug module is used for testing, to see if the output is as expected.

4. Creating the [Jinja2 Config](#jinja2-templating)
The config is simply a for loop, looping through the list of interfaces extracted and applying storm control to each interface.
```
{% for int in interfaces %}
interface {{ int.INTERFACE }}
  storm-control broadcast level 5.00 3.00
{% endfor %}
```
5. Bringing it all together and completing the playbook
```
---
- name: Apply storm control to all access ports (not trunk)
  hosts: "all"
  gather_facts: false
  connection: local
  
  tasks:                                    
    - name: Get access ports
      ios_command:
        commands: "show interface status"
      register: interfaces_temp
    - set_fact: 
        interfaces: "{{ interfaces_temp.stdout[0] | parse_cli_textfsm('/ansible/lib/parse_cli/cisco_ios_get_access_ports.template') }}"
        
    - include_role: 
        name: ios/merge
      vars:
        template_path: "files/templates/storm_control.j2"
```
Replace the debug module with the ios/merge role with the template_path directing to your config template.


