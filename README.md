# SISTEMA CON ARQUITECTURA HOT-WARM-COLD USANDO CONTENEDORES COMO TECNOLOGÍA
#### ESCUELA COLOMBIANA DE INGENIERÍA JULIO GARAVITO
#### BOGOTÁ D.C. - COLOMBIA

#### Estudiante
- Brayan Macias
#### Materia
- TCON_M


#### &nbsp;
## DESCRIPCIÓN DEL PROYECTO
El presente proyecto tiene como fin poder generar un proceso de gestión de datos a través de del manejo de fases y transición entre estas para los datos. De esta manera, definimos un sistema de 3 fases con arquitectura HOT-WARM-COLD, en el que los datos serán procesados en las distintas fases (HOT, WARM y COLD) y harán tránsito de una fase a otra dependiendo de ciertas condiciones que definimos deben cumplir los datos. Estas condiciones que decimos deben cumplir los datos, son las políticas que dictan si un dato está o no listo para realizar la transición de una fase a otra. Las políticas se basan en propiedades sobre los datos tales como tamaño y edad, así que manejaremos rangos sobre estas propiedades de los datos para que se pueda realizar la evaluación y finalmente decidir si el dato cambiará de fase. A las políticas definidas también las llamaremos ILM (Index Lifecycle Management).

![HWC System](https://github.com/TCON-FINAL-PROJECT/HOT-WARM-COLD-System/blob/main/Img/HWC.png)

Al ser un sistema de 3 fases, la transición se da solo de una fase a otra, así, desde la fase HOT solo se puede hacer tránsito a la fase WARM , y de esta solo se puede hacer tránsito a la fase COLD. Las políticas de transición de cada fase le dan mayor coherencia al proceso de tránsito porque en realidad son las que permiten que una fase sea más o menos "caliente".

Para que el sistema tenga sentido, tendremos que generar un punto de inyección de datos, este punto de entrada de datos estará conectado a la fase HOT, ya que esta es la primera fase en el orden de transición.
Una vez los datos estén circulando a través del sistema, va a ser sumamente importante poder generar respaldos (o Snapshots) del sistema en algún punto del tiempo, estos respaldos van a servir como Back-up. La construcción de respaldos la haremos definiendo ciertas políticas basadas en periodos de tiempo. A estas nuevas políticas las llamaremos SLM (Snapshots Lifecycle Management).

Para poder llevar a cabo todo el proceso anterior, haremos uso de ciertas herramientas y tecnologías.

![SLK Stack](https://github.com/TCON-FINAL-PROJECT/HOT-WARM-COLD-System/blob/main/Img/ELK.png)

#### DOCKER
Nos va a servir como plataforma de trabajo proveyéndonos todas las herramientas necesarias para poder generar un ambiente idóneo para desarrollar el sistema. Principalmente, nos va a permitir construir las imágenes y consecuentemente los contenedores necesarios para poder levantar y ejecutar cada uno de los servicios que necesitaremos.
Para poder levantar el sistema, será asignado un contenedor para cada uno de los servicios y los conectaremos a través de Docker Compose para que puedan comunicarse entre ellos.
#### ELASTICSEARCH
Va a ser el servicio principal y estará dispuesto en 3 contenedores (uno por cada fase). ElasticSearch va a proveernos la base de datos y un entorno para poder gestionar y monitorear el sistema en general.
#### LOGSTASH
Permitirá gestionar la entrada de datos al sistema, analizándolos y permitiendo un flujo constante y estable.
#### KIBANA
Kibana nos será de gran ayuda a la hora de querer monitorear el sistema, de manera que podremos visualizar los distintos procesos para corroborar que todo esté funcionando correctamente.


### &nbsp;
## INSTRUCCIONES DE USO
A continuación, se presentan las instrucciones que se deben seguir para lograr la correcta ejecución del proyecto.

### Clonar el Repositorio
Clone o descargue el repositorio en su máquina local.
```sh
   git clone https://github.com/TCON-FINAL-PROJECT/HOT-WARM-COLD-System.git
```
Y nos moveremos al directorio del servicio
```sh
   cd HOT-WARM-COLD-System
```

### Dar permisos de Ejecución
Antes de iniciar con la ejecución misma del clúster, va a ser necesario que asigne permisos de ejecución a los 3 scripts que incluye el repositorio, ya que son realmente necesarios para la posterior ejecución correcta del sistema.
```sh
   sudo chmod +x pc_stats.sh up_cluster.sh verify_cluster_status.sh
```
Si lo desea, puede verificar en cualquier momento la implementación de cada script, para  que pueda tener certeza sobre lo que ejecutan.
Descripción de la funcionalidad de cada script

+ #### pc_stats.sh
    Este es el script que va a realizar la lectura de datos y los va a enviar a logstash a través de la dirección y puerto definidos.
    Para la captura de datos, se están leyendo constantemente el uso de CPU, RAM y cantidad de procesos ejecutándose en el sistema. 
+ #### verify_cluster_status.sh
	Este script va verificando constantemente si el servicio web del clúster se encuentra disponible. Este proceso solo se realiza una ves durante el levantamiento del sistema.
+ #### up_cluster.sh
	Este es el script principal, y automatiza ciertas características de configuración del sistema.
	Internamente, el script ejecuta 5 pasos. A medida que se vayan realizando las distintas configuraciones, se le irá informando qué paso se está ejecutando. También se le informará cuando el sistema esté listo.

### Iniciar el levantamiento del clúster
En este punto ejecutaremos el script ``` up_cluster.sh ```, que, como ya vimos, va a realizar el levantamiento del sistema.
Para poder iniciar el script ejecute el siguiente comando
```sh
   ./up_cluster.sh
```
Las configuraciones se irán haciendo solas, así que no es necesario que haga nada en este punto. Se le indicará cuando todo esté listo.
Como el script realiza distintos pasos, detallamos cada uno para que pueda corroborar el proceso de ejecución.

1. #### PASO 1: CREANDO EL CLUSTER
	En este paso es en el que se realiza el levantamiento del clúster y es el que más tiempo toma.
	Cuando el sistema esté creado, va a continuar con el inicio del servicio web, que es fundamental para poder aplicar varias configuraciones importantes y necesarias.
	Aquí entra en acción el script ``` verify_cluster_status.sh ```, ya que no va a permitir la ejecución del siguiente paso hasta que el servicio web esté listo.
	Al final de este paso debería ver algunas líneas como las siguientes
	```
       HTTP Code 000
       HTTP Code 503
       HTTP Code 503
       HTTP Code 503
       HTTP Code 503
       HTTP Code 000
       HTTP Code 503
       HTTP Code 302
       El cluster ha sido creado con éxito...
	``` 
2. #### PASO 2: CONFIGURANDO ILM EN LOS NODOS
	Aquí se aplicarán las políticas de ILM del sistema.
	Si todo sale bien en este paso, debería obtener una respuesta como esta
	```
       {
           "acknowledged" : true
       }
	``` 
3. #### PASO 3: CREANDO LA PLANTILLA
	Se aplica la configuración para la definición del Index-Template, que va a permitir decirle al sistema como configurar un índice cuando sea creado.
	Si todo sale bien, debería ver una respuesta como esta
	```
       {
           "acknowledged" : true
       }
	``` 
4. #### PASO 4: DEFINIENDO EL INDICE INICIAL
	Para que el sistema pueda gestionar correctamente el posterior tránsito de índices es necesario definir un índice de escritura.
	Si todo sale bien, debería ver una respuesta como esta
	```
       {
           "acknowledged" : true,
           "shards_acknowledged" : true,
           "index" : "webseries-000001"
       }
	```

5. #### PASO 5: DEFINIENDO EL INDEX PATTERN
    Un patrón permite que ciertas políticas sean aplicadas únicamente a los índices que cumplen con tal patrón.
    Si todo sale bien, debería ver una respuesta como esta
    ```
       {
           "_index" : ".kibana_7.15.0_001",
           "_type" : "_doc",
           "_id" : "index-pattern:webseries",
           "_version" : 1,
           "result" : "created",
           "_shards" : {
             "total" : 1,
             "successful" : 1,
             "failed" : 0
           },
           "_seq_no" : 9,
           "_primary_term" : 1
      }
    ```
    Antes de que pueda continuar al paso 6, aparecerá la siguiente advertencia
    ```
       ************************** IMPORTANTE **************************
       Para poder definir la configuración de backup de snapshots, es
       necesario que elasticsearch tenga permisos para hacerlo.
       vuelva acá cuando haya configurado los permisos necesarios.

       Oprima enter para continuar si ya configuró los permisos:

       ****************************************************************
    ``` 
    Así que realice lo siguiente.
    En una nueva terminal ejecute este comando
    ```sh
       docker exec -it elastic01 bash
    ```
    Dentro de la nueva consola de bash, escriba este comando para cambiar los permisos de la carpeta requerida
    ```sh
       chown -R elasticsearch /usr/share/elasticsearch
    ```
    Salga de la terminal y vuelva a realizar este mismo proceso para los otros 2 contenedores, ``` elastic02 ``` y ``` elastic03 ```.
    Ahora puede continuar con el proceso.

6. #### PASO 6: DEFINIENDO REPOSITORIO DE SNAPSHOTS
    Se define el espacio para que los snapshots puedan guardarse.
    Si todo sale bien, debería ver una respuesta como esta
    ```
       {
           "acknowledged" : true
       }
    ```

7. #### PASO 7: CONFIGURANDO EL SLM DE LOS SNAPSHOTS
    Para hacer que los snapshots se realicen de manera automática y cumpliendo ciertas condiciones, se aplican la política SML.
    Si todo sale bien, debería ver una respuesta como esta
    ```
       {
           "acknowledged" : true
       }
    ```

8. #### PASO 8: INYECCION DE DATOS
	Este es el último paso y en este punto el sistema ya está listo, así que solo queda realizar el envió de datos. Aquí se ejecuta el tercer script, o sea ``` pc_stats.sh ```. Este script va a estar enviando constantemente datos al sistema, de manera que, a partir de aquí, va a poder gestionar y revisar todo desde el servicio web de ElasticSearch.
    Cuando llegue a este punto, los datos van a estar siendo enviados al Cluster. Puede verificar los datos en el servidor: ``` localhost:5601 ```.
    Si desea detener el envío de datos, puede hacerlo oprimiendo ``` CTRL + C ```. Tenga en cuenta que la anterior no va a detener el servidor/CLUSTER.
    Si desea detener el CLUSTER, ejecute:
    ```sh
       docker-compose -f docker-HWC.yml down
    ```
    Si desea volver a reanudar el envio de datos, ejecute:
    ```sh
      ./pc_stats.sh
    ```

### &nbsp;
## POLÍTICAS
### ILM
```JSON
{
    "policy": {
        "phases": {
            "hot": {
                "min_age": "0ms",
                "actions": {
                    "rollover": {
                        "max_primary_shard_size": "10kb",
                        "max_age": "3m"
                    },
                    "set_priority": {
                        "priority": 100
                    }
                }
            },
            "warm": {
                "min_age": "3m",
                "actions": {
                    "set_priority": {
                        "priority": 50
                    }
                }
            },
            "cold": {
                "min_age": "9m",
                "actions": {
                    "set_priority": {
                        "priority": 0
                    }
                }
            },
            "delete": {
                "min_age": "12m",
                "actions": {
                    "delete": {
                        "delete_searchable_snapshot": true
                    }
                }
            }
        }
    }
}
```
### SLM
```JSON
{
    "schedule": "0 10 * * * ?",
    "name": "<quick-snap-{now/d}>",
    "repository": "backup",
    "config": {
        "indices": ["*"]
    },
    "retention": {
        "expire_after": "1h",
        "min_count": 1,
        "max_count": 10
    }
}
```


### &nbsp;
## EVIDENCIAS

### Generación y recepción de datos. Se reciben las estadísticas del sistema.
  ![Datos Generados](https://github.com/TCON-FINAL-PROJECT/HOT-WARM-COLD-System/blob/main/Img/1.jpg)

### Gestión de los índices y cambio de fase
  ![Cambio de Fase](https://github.com/TCON-FINAL-PROJECT/HOT-WARM-COLD-System/blob/main/Img/2.jpg)

### Snapshots
+ Repositorio
  ![Repositorio de Snapshots](https://github.com/TCON-FINAL-PROJECT/HOT-WARM-COLD-System/blob/main/Img/Repo.jpg)
+ Política
  ![Política - SLM](https://github.com/TCON-FINAL-PROJECT/HOT-WARM-COLD-System/blob/main/Img/Poli.jpg)
+ Snapshot
  ![Snapshot Autogenerado](https://github.com/TCON-FINAL-PROJECT/HOT-WARM-COLD-System/blob/main/Img/Snap.jpg)
  ![Detalle del Snapshot](https://github.com/TCON-FINAL-PROJECT/HOT-WARM-COLD-System/blob/main/Img/SnapDetail.jpg)
