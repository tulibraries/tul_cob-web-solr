#!/bin/bash
set -e

LATEST_TAG=$(curl -s https://api.github.com/repos/tulibraries/tul_cob-web-solr/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')
echo $LATEST_TAG
curl -X POST --header "Content-Type:application/octet-stream" --data-binary @/home/travis/build/tulibraries/ansible-playbook-solrcloud/data/tmp/collections/tul_cob-web.zip "https://$SOLR_PROD_USER:$SOLR_PROD_PASSWORD@solrcloud.tul-infra.page/solr/admin/configs?action=UPLOAD&name=tul_cob-web-$LATEST_TAG"
curl "https://$SOLR_PROD_USER:$SOLR_PROD_PASSWORD@solrcloud.tul-infra.page/solr/admin/collections?action=CREATE&name=tul_cob-web-$LATEST_TAG&numShards=1&replicationFactor=3&maxShardsPerNode=1&collection.configName=tul_cob-web-$LATEST_TAG"
curl "https://$SOLR_PROD_USER:$SOLR_PROD_PASSWORD@solrcloud.tul-infra.page/solr/admin/collections?action=CREATEALIAS&name=tul_cob-web-$LATEST_TAG-qa&collections=tul_cob-web-$LATEST_TAG"
