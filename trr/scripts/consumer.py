  GNU nano 6.2                                        consumer.py
#!/usr/bin/env python
# coding=utf-8
import pika

connection = pika.BlockingConnection(pika.ConnectionParameters('localhost'))
channel = connection.channel()
channel.queue_declare(queue='hello')


def callback(ch, method, properties, body) -> None:
    print(" [x] Received %r" % body)


channel.basic_consume(
    queue='hello',
    on_message_callback=callback,
    auto_ack=True,
    consumer_tag='dmil_consumer')

channel.start_consuming()
