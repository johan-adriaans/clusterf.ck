# -*- mode: ruby -*-
# # vi: set ft=ruby :

require 'fileutils'

Vagrant.require_version ">= 1.6.0"

$num_instances = 3
$update_channel = "stable"
$image_version = "current"
$memory = 560
$vb_cpuexecutioncap = 100

# Attempt to apply the deprecated environment variable NUM_INSTANCES to
# $num_instances while allowing config.rb to override it
if ENV["NUM_INSTANCES"].to_i > 0 && ENV["NUM_INSTANCES"]
  $num_instances = ENV["NUM_INSTANCES"].to_i
end

Vagrant.configure("2") do |config|
  # forward ssh agent to easily ssh into the different machines
  config.ssh.forward_agent = true
  config.ssh.insert_key = false

  config.vm.box = "coreos-%s" % $update_channel
  if $image_version != "current"
    config.vm.box_version = $image_version
  end

  config.vm.box_url = "https://storage.googleapis.com/%s.release.core-os.net/amd64-usr/%s/coreos_production_vagrant.json" % [$update_channel, $image_version]

  config.vm.provider :virtualbox do |v|
    # On VirtualBox, we don't have guest additions or a functional vboxsf
    # in CoreOS, so tell Vagrant that so it can be smarter.
    v.check_guest_additions = false
    v.functional_vboxsf = false
  end

  # plugin conflict
  if Vagrant.has_plugin?("vagrant-vbguest") then
    config.vbguest.auto_update = false
  end

  (1..$num_instances).each do |i|
    config.vm.define vm_name = "cluster-member-%d" % i do |config|
      config.vm.provider :virtualbox do |vb|
        vb.gui = false
        vb.cpus = 1
        vb.customize ["modifyvm", :id, "--cpuexecutioncap", "#{$vb_cpuexecutioncap}"]
        vb.memory = $memory

        # Only attach disk to the first 2 members
        if i <=2
          disk = ".nfs-storage-%s.vdi" % i
          unless File.exist?(disk)
            vb.customize ['createhd', '--filename', disk, '--variant', 'Fixed', '--size', 100]
          end
          vb.customize ['storageattach', :id,  '--storagectl', 'IDE Controller', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', disk]
        end
      end

      # Internal networking for eth1
      ip = "10.0.0.#{i+9}"
      config.vm.network :private_network, ip: ip

      # Per host ansible provisioning
      config.vm.provision "ansible" do |ansible|
        ansible.verbose = "v"
        ansible.playbook = "playbook_bootstrap.yml"
        ansible.inventory_path = "inventory/vagrant"
        ansible.raw_arguments = [
          "--private-key=~/.vagrant.d/insecure_private_key",
          "-u vagrant"
        ]
      end
    end
  end
end
