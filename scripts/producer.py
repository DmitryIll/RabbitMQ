#!/usr/bin/env python
# coding=utf-8
import pika

connection = pika.BlockingConnection(pika.ConnectionParameters('localhost'))
#connection = pika.BlockingConnection(pika.URLParameters('amqp://test:passwd@rabbitmq2:5672')) 
channel = connection.channel()
channel.queue_declare(queue='hello')
channel.basic_publish(exchange='', routing_key='hello', body='Hello Netology!')
connection.close()
