#!/usr/bin/env bash
curl http://localhost:8090/solr/tul_cob-web/admin/ping | jq .status
