#!/bin/bash
set -e

GITHUB_RESP=$(curl -s https://api.github.com/repos/tulibraries/tul_cob-web-solr/releases/latest)
echo "Checking GitHub API Response."
echo $GITHUB_RESP

echo "Setting release tag variables based on above."
LATEST_TAG=$(echo $GITHUB_RESP | jq -r .tag_name)
NEW_TAG=$(($LATEST_TAG + 1))
echo "Latest tag: $LATEST_TAG"
echo "New tag: $NEW_TAG"

echo "Sending release candidate configs to SolrCloud."
curl -v -X POST --header "Content-Type:application/octet-stream" --data-binary @/home/travis/build/tulibraries/ansible-playbook-solrcloud/data/tmp/collections/tul_cob-web.zip "https://$SOLR_USER:$SOLR_PASSWORD@solrcloud.tul-infra.page/solr/admin/configs?action=UPLOAD&name=tul_cob-web-$NEW_TAG-rc"
curl -v "https://$SOLR_USER:$SOLR_PASSWORD@solrcloud.tul-infra.page/solr/admin/collections?action=CREATE&name=tul_cob-web-$NEW_TAG-rc&numShards=1&replicationFactor=2&maxShardsPerNode=1&collection.configName=tul_cob-web-$NEW_TAG-rc"
curl -v "https://$SOLR_USER:$SOLR_PASSWORD@solrcloud.tul-infra.page/solr/admin/collections?action=CREATEALIAS&name=tul_cob-web-$NEW_TAG-rc&collections=tul_cob-web-$NEW_TAG-rc"
