#!/bin/bash

echo '******************************************************************'
echo '****                                                          ****'
echo '****          CLUSTER DE ARQUITECTURA HOT-WARM-COLD           ****'
echo '****                                                          ****'
echo '******************************************************************'
echo ' '
echo '------------------------------------------------------------------'
echo '                     PASO 1: CREANDO EL CLUSTER'
echo '------------------------------------------------------------------'

docker-compose -f docker-HWC.yml up -d
./verify_cluster_status.sh

echo ' '
echo '------------------------------------------------------------------'
echo '               PASO 2: CONFIGURANDO ILM EN LOS NODOS'
echo '------------------------------------------------------------------'

curl -X PUT "localhost:9200/_ilm/policy/timeseries_policy?pretty" -H 'Content-Type: application/json' -d'
{
    "policy": {
        "phases": {
            "hot": {
                "min_age": "0ms",
                "actions": {
                    "rollover": {
                        "max_primary_shard_size": "10kb",
                        "max_age": "9m"
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
}'


echo ' '
echo '------------------------------------------------------------------'
echo '                  PASO 3: CREANDO LA PLANTILLA'
echo '------------------------------------------------------------------'

curl -X PUT "localhost:9200/_index_template/timeseries_template?pretty" -H 'Content-Type: application/json' -d'
{
    "index_patterns": ["webseries-*"],
    "template": {
        "settings": {
            "index": {
                "lifecycle": {
                    "name": "timeseries_policy",
                    "rollover_alias": "webseries"
                },
                "number_of_shards": "1",
                "number_of_replicas": "0"
            }
        },
        "aliases": {},
        "mappings": {}
    }
}'

echo ' '
echo '------------------------------------------------------------------'
echo '               PASO 4: DEFINIENDO EL INDICE INICIAL'
echo '------------------------------------------------------------------'

curl -X PUT "localhost:9200/webseries-000001?pretty" -H 'Content-Type: application/json' -d'
{
	"aliases": {
		"webseries": {
            "is_write_index": true
        }
	}
}'


echo ' '
echo '------------------------------------------------------------------'
echo '               PASO 5: DEFINIENDO EL INDEX PATTERN'
echo '------------------------------------------------------------------'

curl -X PUT "http://localhost:9200/.kibana/_doc/index-pattern:webseries?pretty" -H 'Content-Type: application/json' -d'
{
  "type" : "index-pattern",
  "index-pattern" : {
    "title": "webseries-*",
    "timeFieldName": "@timestamp"
  }
}'


echo ' '
echo '************************** IMPORTANTE **************************'
echo 'Para poder definir la configuración de backup de snapshots,  es'
echo 'necesario que elasticsearch tenga permisos para hacerlo.'
echo 'vuelva acá y oprima enter cuando haya configurado los permisos'
echo 'necesarios.'

echo 'Oprima enter para continuar si ya configuró los permisos:'
read res
echo '****************************************************************'


echo ' '
echo '------------------------------------------------------------------'
echo '           PASO 6: DEFINIENDO REPOSITORIO DE SNAPSHOTS'
echo '------------------------------------------------------------------'

curl -X PUT "localhost:9200/_snapshot/backup?pretty" -H 'Content-Type: application/json' -d'
{
  "type": "fs",
  "settings": {
    "location": "backup_library"
  }
}'


echo ' '
echo '------------------------------------------------------------------'
echo '           PASO 7: CONFIGURANDO EL SLM DE LOS SNAPSHOTS'
echo '------------------------------------------------------------------'

curl -X PUT "localhost:9200/_slm/policy/xpress-snapshots?pretty" -H 'Content-Type: application/json' -d'
{
  "schedule": "0 37 * * * ?", 
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
}'


echo ' '
echo '------------------------------------------------------------------'
echo '                   PASO 8: INYECCION DE DATOS'
echo '------------------------------------------------------------------'

echo '# Los datos estan siendo enviados hacia el CLUSTER'
echo '# Ya se pueden verificar los datos en el servidor: localhost:5601'

echo '# Presione CTRL + C si desea detener el envio de datos'
echo '# IMPORTANTE: Esto no va a detener el servidor/CLUSTER.'
echo '# Si desea detener el CLUSTER, ejecute:'
echo '#     docker-compose -f docker-HWC.yml down'
echo '# Si desea volver a reanudar el envio de datos, ejecute:'
echo '#     ./pc_stats.sh'

./pc_stats.sh
