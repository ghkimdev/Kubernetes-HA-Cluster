# -*- mode: ruby -*-
# vi: set ft=ruby :

ENV['VAGRANT_NO_PARALLEL'] = 'yes'

VAGRANT_BOX         = "generic/ubuntu2004"
VAGRANT_BOX_VERSION = "4.2.6"
# master nodes
MASTER_NODE_COUNT   = 3
MASTER_NODE_CPUS    = 2
MASTER_NODE_MEMORY  = 2000
# worker nodes
WORKER_NODE_COUNT   = 4
WORKER_NODE_CPUS    = 2
WORKER_NODE_MEMORY  = 4000
# lb nodes
LB_NODE_COUNT   = 2
LB_NODE_CPUS    = 1
LB_NODE_MEMORY  = 500

Vagrant.configure(2) do |config|

  config.vm.provision "shell", path: "install/bootstrap.sh"
  config.vm.synced_folder "install/", "/opt/install"

  (1..LB_NODE_COUNT).each do |i|

    config.vm.define "lb0#{i}" do |node|

      node.vm.box               = VAGRANT_BOX
      node.vm.box_check_update  = false
      node.vm.box_version       = VAGRANT_BOX_VERSION
      node.vm.hostname          = "lb0#{i}.example.com"
      node.vm.network "private_network", ip: "172.16.0.12#{i}"

      node.vm.provider :virtualbox do |v|
        v.name    = "lb0#{i}"
        v.memory  = LB_NODE_MEMORY
        v.cpus    = LB_NODE_CPUS
      end

      node.vm.provider :libvirt do |v|
        v.nested  = true
        v.memory  = LB_NODE_MEMORY
        v.cpus    = LB_NODE_CPUS
      end

      node.vm.provision "shell", path: "install/install_loadbalancer.sh"
    end

  end

  (1..MASTER_NODE_COUNT).each do |i|

    config.vm.define "master0#{i}" do |node|

      node.vm.box               = VAGRANT_BOX
      node.vm.box_check_update  = false
      node.vm.box_version       = VAGRANT_BOX_VERSION
      node.vm.hostname          = "master0#{i}.example.com"

      node.vm.network "private_network", ip: "172.16.0.10#{i}"

      node.vm.provider :virtualbox do |v|
        v.name    = "master0#{i}"
        v.memory  = MASTER_NODE_MEMORY
        v.cpus    = MASTER_NODE_CPUS
      end

      node.vm.provider :libvirt do |v|
        v.nested  = true
        v.memory  = MASTER_NODE_MEMORY
        v.cpus    = MASTER_NODE_CPUS
      end


    end

  end

  (1..WORKER_NODE_COUNT).each do |i|

    config.vm.define "worker0#{i}" do |node|

      node.vm.box               = VAGRANT_BOX
      node.vm.box_check_update  = false
      node.vm.box_version       = VAGRANT_BOX_VERSION
      node.vm.hostname          = "worker0#{i}.example.com"
      node.vm.network "private_network", ip: "172.16.0.11#{i}"

      node.vm.provider :virtualbox do |v|
        v.name    = "worker0#{i}"
        v.memory  = WORKER_NODE_MEMORY
        v.cpus    = WORKER_NODE_CPUS
      end

      node.vm.provider :libvirt do |v|
        v.nested  = true
        v.memory  = WORKER_NODE_MEMORY
        v.cpus    = WORKER_NODE_CPUS
      end


    end

  end

end
