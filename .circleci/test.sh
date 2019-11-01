#!/usr/bin/env bash
STATUS=$(docker exec solr1 curl http://solr1:8983/solr/funcake/admin/ping?wt=json | jq .status)
if [ "$STATUS" != '"OK"' ]; then
  echo "Faling because status is not OK"
  echo "status: $STATUS"
  exit -1
fi
