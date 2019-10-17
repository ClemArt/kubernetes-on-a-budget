# -*- mode: ruby -*-
# vi: set ft=ruby :

IP_PREFIX = "192.168.10.1"
IGNORE_PFERR = "Swap,NumCPU"

Vagrant.configure("2") do |config|

  if Vagrant.has_plugin?("vagrant-proxyconf")
    config.proxy.http     = "#{ENV['HTTP_PROXY']}"
    config.proxy.https    = "#{ENV['HTTP_PROXY']}"
    config.proxy.no_proxy = "#{ENV['NO_PROXY']},10.96.0.0/12,10.80.0.0/12,#{IP_PREFIX}0/24"
  end

  config.hostmanager.enabled = true
  config.hostmanager.manage_host = false
  config.hostmanager.manage_guest = true
  config.hostmanager.include_offline = true

  config.vm.box = "centos/7"
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "2048"
    vb.cpus = 1
  end

  config.vm.provision "ca_dependencies", type: "shell", inline: <<-EOF
    yum install -y ca-certificates
  EOF

  if Vagrant.has_plugin?("vagrant-proxyconf") && Dir.exists?("./ssl")
    config.vm.provision "custom_ssl", type: "shell", inline: <<-EOF
      cp /vagrant/ssl/*.pem /etc/pki/ca-trust/source/anchors/
      update-ca-trust
    EOF
  end

  config.vm.provision "file", source: "./scripts", destination: "/tmp/scripts"

  (1..3).each do |i|
    config.vm.define "node-#{i}" do |v|
      v.vm.hostname = "node-#{i}"
      v.vm.network "private_network", ip: "#{IP_PREFIX}#{i}"

      v.vm.provision "placeholder", type: "shell", inline: <<-EOF
        sed -i -e 's/${HOST_NAME}/node-#{i}/g' \
               -e 's/${HOST_IP}/#{IP_PREFIX}#{i}/g' \
               -e 's/${ETCD_NAME}/etcd#{i}/g' \
               -e 's/${PEER1_IP}/#{IP_PREFIX}1/g' \
               -e 's/${PEER2_IP}/#{IP_PREFIX}2/g' \
               -e 's/${PEER3_IP}/#{IP_PREFIX}3/g' \
               /tmp/scripts/*
          
        chmod +x /tmp/scripts/*.sh
      EOF

      v.vm.provision "docker", type: "shell", inline: "/tmp/scripts/docker-install.sh"

      v.vm.provision "etcd", type: "shell", inline: "/tmp/scripts/etcd-install.sh"

      v.vm.provision "k8s", type: "shell", inline: "/tmp/scripts/install-k8s-binaries.sh"

      v.vm.provision "kubeadm", type: "shell", inline: <<-EOF
        if [ #{i} -eq 1 ]; then
          kubeadm init --config /tmp/scripts/kubeadm-config.yml --ignore-preflight-errors=#{IGNORE_PFERR}
        else
          kubeadm join --config /tmp/scripts/kubeadm-config.yml --ignore-preflight-errors=#{IGNORE_PFERR} 192.168.10.11:6443
        fi
      EOF
    
    end
  end

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # NOTE: This will enable public access to the opened port
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine and only allow access
  # via 127.0.0.1 to disable public access
  # config.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  # config.vm.provider "virtualbox" do |vb|
  #   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  #
  #   # Customize the amount of memory on the VM:
  #   vb.memory = "1024"
  # end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  # config.vm.provision "shell", inline: <<-SHELL
  #   apt-get update
  #   apt-get install -y apache2
  # SHELL
end
