#!/bin/bash

remove_imagem() {
    local imagem_id=$1
    if [[ -z $imagem_id ]]; then
        echo "Imagem ID não informado"
        return 1
    fi
    crictl -r unix:///run/containerd/containerd.sock rmi $imagem_id
}

IMAGENS_LATEST=$(crictl -r unix:///run/containerd/containerd.sock images | grep "mensageiro" | grep "latest" | awk '{print $1":"$2}')

for imagem in $IMAGENS_LATEST; do
    remove_imagem $imagem
done

MSG_IMAGENS="api backend websocket frontend"

for msg_imagem in $MSG_IMAGENS; do
    imagens=$(crictl -r unix:///run/containerd/containerd.sock images | grep "mensageiro" | grep $msg_imagem | awk '{print $3}')

    imagem_ultima=$(echo "$imagens" | tail -n 1)

    for imagem in $imagens; do
        if [[ $imagem != $imagem_ultima ]]; then
            remove_imagem $imagem
        fi
    done
done

