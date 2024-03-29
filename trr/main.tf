variable hostname_blocks {}
variable name_bloks {}
variable images_blocks {}
variable cores_blocks {}
variable memory_blocks {}
variable core_fraction_blocks {}
variable ip_blocks {}

variable count_vm {}



#---- vms rabbitmq --------------
resource "yandex_compute_instance" "vm" {

  count = "${var.count_vm}"

  name = "${var.name_bloks[count.index]}" 
  hostname = "${var.hostname_blocks[count.index]}" 

  allow_stopping_for_update = true
  platform_id               = "standard-v1" 
  #zone                      = local.zone

  resources {
    core_fraction = "${var.core_fraction_blocks[count.index]}" 
    cores  = "${var.cores_blocks[count.index]}" 
    memory = "${var.memory_blocks[count.index]}"  
  }

  boot_disk {
    initialize_params {
      image_id = "${var.images_blocks[count.index]}"
      size = 16
    }
  }

#network_interface.0.ip_address

  network_interface {
    subnet_id = "${yandex_vpc_subnet.subnet-1.id}" 
    ip_address = "${var.ip_blocks[count.index]}"
    nat       = true
  }

  scheduling_policy {
  preemptible = true
   }

 metadata = {
    user-data = "${file("./meta.yaml")}" 
  }

#---------- создаем папки -----
#  provisioner "remote-exec" {
#    inline = [
#     "cd ~",
#     "mkdir -pv ansible"
#    ]
#  }

 
  provisioner "file" {
    source      = "../scripts/producer.py"
    destination = "/root/producer.py"
  }
 

  provisioner "file" {
    source      = "ansible/play.yaml"
    destination = "/root/play.yaml"
  }


#--- это не делаем т.к. через ансибл ставим все -------------------------------------------------------
#  provisioner "remote-exec" {
#    inline = [
#    "sudo apt update",
#    "sudo apt install -y rabbitmq-server",
#    "sudo rabbitmq-plugins enable rabbitmq_management",
#    "sudo rabbitmqctl add_user test passwd",
#    "sudo rabbitmqctl set_user_tags test administrator",
#    "sudo rabbitmqctl set_permissions -p / test \".*\" \".*\" \".*\"",
#    "sudo echo \"192.168.10.10 rabbitmq1\" >> /etc/hosts",
#    "sudo echo \"192.168.10.11 rabbitmq2\" >> /etc/hosts",
#    ]
#  }
  
# это через терраформ не заработало:
#    "sudo apt install -y pip",
#    "sudo pip install pika"

# это через терраформ не делал - делал вручную:
# rabbitmqctl set_policy ha-all "" '{"ha-mode":"all","ha-sync-mode":"automatic"}'
# rabbitmqctl set_policy -p 'elma365vhost' MirrorAllQueues ".*" '{"ha-mode":"all"}'

  #provisioner "file" {
  #  source      = "../configs/.erlang.cookie"
  #  destination = "/var/lib/rabbitmq/.erlang.cookie"
  #}


    connection {
      type        = "ssh"
      user        = "root"
      private_key = "${file("id_ed25519")}"
      host = self.network_interface[0].nat_ip_address
    }
 
}


