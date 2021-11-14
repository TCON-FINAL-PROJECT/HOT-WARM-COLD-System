#!/bin/bash

state=`curl -s -o /dev/null -w "%{http_code}" http://localhost:5601`

echo '# Creando y levantando el servicio web.'
echo '# Esto puede tardar unos minutos...'

while [ $state != 302 ]
do
        state=`curl -s -o /dev/null -w "%{http_code}" http://localhost:5601`
        echo 'HTTP Code '$state
        sleep 30
done

echo 'El cluster ha sido creado con éxito...'