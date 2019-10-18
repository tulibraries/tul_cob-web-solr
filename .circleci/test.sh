#!/usr/bin/env bash

set -e

STATUS=$(curl http://localhost:8090/solr/tul_cob-web/admin/ping | jq .status)

if [ "$STATUS" != '"OK"' ]; then
  echo "Failing because status is not okay"
  echo "Status: $STATUS"
  exit -1
fi
