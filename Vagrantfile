# -*- mode: ruby -*-
# vi: set ft=ruby :

KUBE_VERSION="1.26.1"
MASTER_COUNT=1
WORKER_COUNT=0

Vagrant.configure("2") do |config|
  config.vm.box = "chavo1/rocky9.3"
  config.vm.provision "shell", inline: <<-SHELL
  echo "192.168.56.11       master-1" >> /etc/hosts
  echo "192.168.56.21       worker-1" >> /etc/hosts
  echo "192.168.56.22       worker-2" >> /etc/hosts
  echo "192.168.56.23       worker-3" >> /etc/hosts
  SHELL

1.upto(MASTER_COUNT)do |i|
  config.vm.define "master#{i}" do |master|
    master.vm.hostname  = "master-#{i}"
    master.vm.network "private_network", ip: "192.168.56.#{i+10}"
    master.vm.provision "shell", path: "./scripts/provision.sh"
    master.vm.provider "virtualbox" do |pmv|
      pmv.memory = 10000
      pmv.cpus = 2
    end
  end
end

1.upto(WORKER_COUNT) do |i|
    config.vm.define "worker#{i}" do |node|
      node.vm.hostname  = "worker-#{i}"
      # node.vm.provision "shell", path: "./scripts/common.sh", env: {"KUBE_VERSION" => KUBE_VERSION}
      # node.vm.provision "shell", path: "./scripts/worker.sh"
      node.vm.network "private_network", ip: "192.168.56.#{i+20}"
      node.vm.provider "virtualbox" do |pmv|
        pmv.memory = 2048
      end
    end
  end
end