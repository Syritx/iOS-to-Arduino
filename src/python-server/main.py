import socket
import threading

server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
server.bind((socket.gethostbyname(socket.gethostname()), 6020))
server.listen(5)

clients = []


def clt_thread(client, addr):
    
    is_connected = True
    while is_connected:
        message = client.recv(1024).decode('utf-8')
        print(message)

        client.send(bytes("h", 'utf-8'))

        if str(message).startswith('disconnected'):
            is_connected = False
            break

        if str(message) == 'led':
            send_to_others(client, 'l')

    client.close()
    clients.remove(client)

def send_to_others(ignore, message):
    for client in clients:
        if client != ignore:
            client.send(bytes(message, 'utf-8'))


while True:
    print('waiting')
    clt, addr = server.accept()
    clients.append(clt)
    print('connection')

    thread = threading.Thread(target=clt_thread, args=(clt, addr))
    thread.start()