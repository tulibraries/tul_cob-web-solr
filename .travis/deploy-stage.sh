#!/bin/bash
set -e

LATEST_TAG=$(curl -s https://api.github.com/repos/tulibraries/tul_cob-web-solr/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')
NEW_TAG=$(($LATEST_TAG + 1))
echo $NEW_TAG
curl -X POST --header "Content-Type:application/octet-stream" --data-binary @/home/travis/build/tulibraries/ansible-playbook-solrcloud/data/tmp/collections/tul_cob-web.zip "https://$SOLR_STAGE_USER:$SOLR_STAGE_PASSWORD@solrcloud.stage.tul-infra.page/solr/admin/configs?action=UPLOAD&name=tul_cob-web-$NEW_TAG"
curl "https://$SOLR_STAGE_USER:$SOLR_STAGE_PASSWORD@solrcloud.stage.tul-infra.page/solr/admin/collections?action=CREATE&name=tul_cob-web-$NEW_TAG&numShards=1&replicationFactor=3&maxShardsPerNode=1&collection.configName=tul_cob-web-$NEW_TAG"
curl "https://$SOLR_STAGE_USER:$SOLR_STAGE_PASSWORD@solrcloud.stage.tul-infra.page/solr/admin/collections?action=CREATEALIAS&name=tul_cob-web-$NEW_TAG&collections=tul_cob-web-$NEW_TAG"
