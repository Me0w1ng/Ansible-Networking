FROM ubuntu:16.04

RUN echo "===> Adding Ansible's PPA..."  && \
    echo "deb http://ppa.launchpad.net/ansible/ansible/ubuntu xenial main" | tee /etc/apt/sources.list.d/ansible.list           && \
    echo "deb-src http://ppa.launchpad.net/ansible/ansible/ubuntu xenial main" | tee -a /etc/apt/sources.list.d/ansible.list    && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 7BB9C367    && \
    DEBIAN_FRONTEND=noninteractive  apt-get update  && \
    \
    \
    echo "===> Installing Ansible..."  && \
    apt-get install -y ansible  && \
    \
    \
    echo "===> Installing handy tools (not absolutely required)..."  && \
    apt-get install -y python-pip              && \
    pip install --upgrade pip                  && \
    pip install --upgrade pywinrm              && \
    apt-get install -y sshpass openssh-client  && \
    \
    \
    echo "===> Removing Ansible PPA..."  && \
    rm -rf /var/lib/apt/lists/*  /etc/apt/sources.list.d/ansible.list  && \
    \
    \
    echo "===> Adding hosts for convenience..."  && \
    echo 'localhost' > /etc/ansible/hosts
    
#long line = napalm dependencies and ntc ansible from zlib1g
RUN echo "===> Installing ..."  && \
	  apt-get update -y && \
    apt-get install -y libssl-dev libffi-dev python-dev python-cffi libxslt1-dev libssl-dev python-pip zlib1g-dev libxml2-dev libxslt-dev && \
    apt-get install git iputils-ping -y && \
    pip install setuptools --upgrade && \
    pip install netmiko napalm ntc-ansible && \ 
    pip install openpyxl fasteners

# ==> Copying Ansible playbook....
WORKDIR /ansible
CMD ["bash"]