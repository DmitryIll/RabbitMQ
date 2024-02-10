#---- vm Ansible --------------

resource "yandex_compute_instance" "ansible" {
  name                      = "ansible"
  hostname = "ansible"
  allow_stopping_for_update = true
  platform_id               = "standard-v1"
  #zone                      = local.zone

  resources {
    core_fraction = 100
    cores  = "2"
    memory = "2"
  }

  boot_disk {
    initialize_params {
      image_id = "fd8kb72eo1r5fs97a1ki"   #ubuntu 2204
      size = 10
    }
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.subnet-1.id}"
    nat       = true
  }

  scheduling_policy {
  preemptible = true
   }

 metadata = {
    user-data = "${file("./meta.yaml")}" 
  }

#---------- копируем файлы ----

  provisioner "file" {
    source      = "id_ed25519"
    destination = "/root/.ssh/id_ed25519"
  }

  provisioner "file" {
    source      = "id_ed25519.pub"
    destination = "/root/.ssh/id_ed25519.pub"
  }

  provisioner "file" {
    source      = "ansible/play.yaml"
    destination = "/root/play.yaml"
  }

 provisioner "remote-exec" {
    inline = [
    "sudo apt-add-repository -y ppa:ansible/ansible",
    "sudo apt update",
    "sudo apt install -y ansible",
    "cd ",
    "sudo ansible-config init --disabled -t all > ansible.cfg",
    "echo \"[rabbitmq-cluster] \n rabbitmq[1:2] ansible_ssh_user=root \" >> /etc/ansible/hosts",
    "sudo echo \"192.168.10.10 rabbitmq1\" >> /etc/hosts",
    "sudo echo \"192.168.10.11 rabbitmq2\" >> /etc/hosts",
    "sudo chmod 600 /root/.ssh/id_ed25519",
    "ssh-keyscan -H rabbitmq1 >> /root/.ssh/known_hosts",
    "ssh-keyscan -H rabbitmq2 >> /root/.ssh/known_hosts",
    "ansible-playbook play.yaml"
    ]
  }
    connection {
      type        = "ssh"
      user        = "root"
      private_key = "${file("id_ed25519")}"
      host = self.network_interface[0].nat_ip_address
    }


}