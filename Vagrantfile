Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/xenial64"
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "1024"
  end
  config.vm.network :forwarded_port, guest: 22, host: 4567, id: "ssh"
  config.vm.network :forwarded_port, guest: 443, host: 4568
  config.vm.provision "shell", inline: <<-SHELL
    sudo apt update
    sudo apt install -y python-minimal
  SHELL
end
