# -*- mode: ruby -*-
# vi: set ft=ruby :

# this Vagrantfile only works with VirtualBox so we set the default provider here
# so we can skip the --provider virtualbox option
ENV['VAGRANT_DEFAULT_PROVIDER'] = 'virtualbox'

# use half of the available memory
def get_memory_setting(host)
  divider = 2
  if host =~ /darwin/
    mem = `sysctl -n hw.memsize`.to_i / 1024 / 1024 / divider
  elsif host =~ /linux/
    mem = `grep 'MemTotal' /proc/meminfo | sed -e 's/MemTotal://' -e 's/ kB//'`.to_i / 1024 / divider
  else # Windows
    mem = `for /F "tokens=2 delims==" %i in ('wmic computersystem get TotalPhysicalMemory /value') do @echo %i`.to_i / 1024 / 1024 / divider
  end
  return mem
end

def get_cpu_setting(host)
  if host =~ /darwin/
    cpus = `sysctl -n hw.ncpu`.to_i
  elsif host =~ /linux/
    cpus = `nproc`.to_i
  else # Windows
    cpus = `for /F "tokens=2 delims==" %i in ('wmic cpu get NumberOfCores /value') do @echo %i`.to_i
  end
  return cpus
end

Vagrant.configure(2) do |config|
  config.vm.synced_folder ".", "/vagrant"
  config.vm.define "docker-raspbian" do |config|
    config.vm.hostname = "docker-raspbian"
    config.ssh.forward_agent = true
    config.vm.provision "shell", path: "scripts/provision.sh", privileged: false
    config.vm.provider "virtualbox" do |vb, override|
       override.vm.box = "ubuntu/trusty64"
       # find out on which host os we are running
       host = RbConfig::CONFIG['host_os']
       vb.customize ["modifyvm", :id, "--ioapic", "on"]
       vb.memory = get_memory_setting(host)
       vb.cpus = get_cpu_setting(host)
    end
    config.vm.provider "docker" do |docker|
      docker.image = "tknerr/baseimage-ubuntu:14.04"
      docker.has_ssh = true
      docker.remains_running = false
    end
  end
end
