variable hostname_blocks {}
variable name_bloks {}
variable images_blocks {}
variable cores_blocks {}
variable memory_blocks {}
variable core_fraction_blocks {}
variable ip_blocks {}

variable count_vm {}

#---- vms --------------
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
#     "mkdir -pv configs"
#    ]
#  }

#---------- копируем файлы ----


  provisioner "file" {
    source      = "../scripts/consumer.py"
    destination = "/home/dmil/consumer.py"
  }

  
  provisioner "file" {
    source      = "../scripts/producer.py"
    destination = "/home/dmil/producer.py"
  }
    

#----------------------------------------------------------

  provisioner "remote-exec" {
    inline = [
    "sudo apt update",
    "sudo -i",
    "sudo echo \"192.168.10.10 rabbitmq1\" >> /etc/hosts" ,
    "sudo echo \"192.168.10.11 rabbitmq2\" >> /etc/hosts" ,
    "sudo apt install -y rabbitmq-server",
    "sudo rabbitmq-plugins enable rabbitmq_management",
    "sudo rabbitmqctl add_user test passwd",
    "sudo rabbitmqctl set_user_tags test administrator",
    "sudo rabbitmqctl set_permissions -p / test \".*\" \".*\" \".*\""
    ]
  }
#    "sudo apt install -y pip",
#    "sudo pip install pika"

# rabbitmqctl set_policy ha-all "" '{"ha-mode":"all","ha-sync-mode":"automatic"}'
# rabbitmqctl set_policy -p 'elma365vhost' MirrorAllQueues ".*" '{"ha-mode":"all"}'


#    "sudo apt-get install -y ca-certificates curl gnupg",
#    "sudo install -m 0755 -d /etc/apt/keyrings",
#    "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg",
#    "sudo chmod a+r /etc/apt/keyrings/docker.gpg",
#    "echo \"deb [arch=\"$(dpkg --print-architecture)\" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \"$(. /etc/os-release && echo \"$VERSION_CODENAME\")\" stable\" |  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
#    "sudo apt-get update",
#    "sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin",
#    "sudo chmod +x /home/dmil/docker-compose.yaml",
#    "sudo apt update",
#    "sudo apt install -y nginx",
#    "sudo chmod 777 /var/log/nginx/access.log",
#    "sudo apt install -y redis",
#    "sudo curl localhost",
#    "sudo systemctl restart redis",
#    "sudo chmod o+rx -R /var/log/redis",
#    "sudo docker compose up -d"


  #provisioner "file" {
  #  source      = "../configs/.erlang.cookie"
  #  destination = "/var/lib/rabbitmq/.erlang.cookie"
  #}


    connection {
      type        = "ssh"
      user        = "dmil"
      private_key = "${file("id_ed25519")}"
      host = self.network_interface[0].nat_ip_address
    }
 
}


