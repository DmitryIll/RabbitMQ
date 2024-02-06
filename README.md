# Домашнее задание к занятию  «Очереди RabbitMQ» Илларионов Дмитрий


---

### Задание 1. Установка RabbitMQ

Используя Vagrant или VirtualBox, создайте виртуальную машину и установите RabbitMQ.
Добавьте management plug-in и зайдите в веб-интерфейс.

*Итогом выполнения домашнего задания будет приложенный скриншот веб-интерфейса RabbitMQ.*

#### Решение

Создал ВМ через терраформ в облаке, и в коде терраформ сразу указал команды для установки Rabbitmq:

```
  provisioner "remote-exec" {
    inline = [
    "sudo apt update",
    "sudo apt install -y rabbitmq-server",
    "sudo rabbitmq-plugins enable rabbitmq_management",
    "sudo rabbitmqctl add_user test passwd",
    "sudo rabbitmqctl set_user_tags test administrator",
    "sudo rabbitmqctl set_permissions -p / test \".*\" \".*\" \".*\""
    ]
  }
```

Получил ВМ в облаке с установлленным rabbitmq:

![Alt text](image.png)

Проверил статус сервиса:

![Alt text](image-1.png)

Заше на Web интерфейс:

![Alt text](image-2.png)

---

### Задание 2. Отправка и получение сообщений

Используя приложенные скрипты, проведите тестовую отправку и получение сообщения.
Для отправки сообщений необходимо запустить скрипт producer.py.

Для работы скриптов вам необходимо установить Python версии 3 и библиотеку Pika.
Также в скриптах нужно указать IP-адрес машины, на которой запущен RabbitMQ, заменив localhost на нужный IP.

```shell script
$ pip install pika
```

Зайдите в веб-интерфейс, найдите очередь под названием hello и сделайте скриншот.

![Alt text](image-3.png)   

После чего запустите второй скрипт consumer.py и сделайте скриншот результата выполнения скрипта

![alt text](image-6.png)

![alt text](image-4.png)

![alt text](image-5.png)

*В качестве решения домашнего задания приложите оба скриншота, сделанных на этапе выполнения.*

Для закрепления материала можете попробовать модифицировать скрипты, чтобы поменять название очереди и отправляемое сообщение.

---

### Задание 3. Подготовка HA кластера

Используя Vagrant или VirtualBox, создайте вторую виртуальную машину и установите RabbitMQ.
Добавьте в файл hosts название и IP-адрес каждой машины, чтобы машины могли видеть друг друга по имени.

Пример содержимого hosts файла:
```shell script
$ cat /etc/hosts
192.168.0.10 rmq01
192.168.0.11 rmq02
```
После этого ваши машины могут пинговаться по имени.
Затем объедините две машины в кластер и создайте политику ha-all на все очереди.

#### Решение

Через терраформ создал две ВМ (см. код в git).
На обоих серверах добавил в hosts:

```
192.168.10.10 rabbitmq1
192.168.10.11 rabbitmq2
```
еще добавил на обоих:

```
echo "12345" > /var/lib/rabbitmq/.erlang.cookie
```
На обоих серверах выполнил:

```
# systemctl restart rabbitmq-server.service
# systemctl status rabbitmq-server.service
```

![alt text](image-7.png)

На 2-м:
```
root@rabbitmq2:~# rabbitmqctl stop_app
root@rabbitmq2:~# rabbitmqctl reset
root@rabbitmq2:~# rabbitmqctl join_cluster rabbit@rabbitmq1
root@rabbitmq2:~# rabbitmqctl start_app 
root@rabbitmq2:~# rabbitmqctl cluster_status
```  

![alt text](image-8.png)

То что были некоторые errors - нормально.

![alt text](image-9.png)
![alt text](image-10.png)

На 1м сервере:

```
root@rabbitmq1:~# rabbitmqctl set_policy ha-all "" '{"ha-mode":"all","ha-sync-mode":"automatic"}'
```
![alt text](image-11.png)

*В качестве решения домашнего задания приложите скриншоты из веб-интерфейса с информацией о доступных нодах в кластере и включённой политикой.*

![alt text](image-12.png)
![alt text](image-13.png)

Также приложите вывод команды с двух нод:

```shell script
$ rabbitmqctl cluster_status
```

![alt text](image-14.png)
![alt text](image-15.png)

Для закрепления материала снова запустите скрипт producer.py и приложите скриншот выполнения команды на каждой из нод:

```shell script
$ rabbitmqadmin get queue='hello'
```

![alt text](image-16.png)
![alt text](image-17.png)


После чего попробуйте отключить одну из нод, желательно ту, к которой подключались из скрипта, затем поправьте параметры подключения в скрипте consumer.py на вторую ноду и запустите его.

*Приложите скриншот результата работы второго скрипта.*

На первом сервере отключил службу rabbitmq

![alt text](image-18.png)

Поправил скрипт:

![alt text](image-19.png)

На первом сервере выполнил отправку сообщений но уже на второй сервер:
![alt text](image-20.png)

В веб интерфейсе на втором сервере:

![alt text](image-21.png)

Прочитал все сообщения на второй ноде:
![alt text](image-22.png)
![alt text](image-23.png)

видно что ничего не пропало.


## Дополнительные задания (со звёздочкой*)
Эти задания дополнительные, то есть не обязательные к выполнению, и никак не повлияют на получение вами зачёта по этому домашнему заданию. Вы можете их выполнить, если хотите глубже шире разобраться в материале.

### * Задание 4. Ansible playbook

Напишите плейбук, который будет производить установку RabbitMQ на любое количество нод и объединять их в кластер.
При этом будет автоматически создавать политику ha-all.

*Готовый плейбук разместите в своём репозитории.*

