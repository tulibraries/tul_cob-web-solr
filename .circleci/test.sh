#!/usr/bin/env bash
STATUS=curl http://localhost:8090/solr/tul_cob-web/admin/ping | jq .status

if [ $STATUS != "OK" ]; then
  echo "Failing because status is not okay"
  echo $STATUS
  exit -1
fi
