#!/bin/bash
set -e

GITHUB_RESP=$(curl -s https://api.github.com/repos/tulibraries/tul_cob-web-solr/releases/latest)
echo "Checking GitHub API Response."
echo $GITHUB_RESP

echo "Setting release tag variables based on above."
LATEST_TAG=$(echo $GITHUB_RESP| jq -r .tag_name)
LATEST_RELEASE_ID=$(echo $GITHUB_RESP | jq -r .id)
echo "Latest tag: $LATEST_TAG"
echo "Latest release id: $LATEST_RELEASE_ID"

echo "Sending release configs to SolrCloud."
curl -v -X POST --header "Content-Type:application/octet-stream" --data-binary @/home/travis/build/tulibraries/ansible-playbook-solrcloud/data/tmp/collections/tul_cob-web.zip "https://$SOLR_USER:$SOLR_PASSWORD@solrcloud.tul-infra.page/solr/admin/configs?action=UPLOAD&name=tul_cob-web-$LATEST_TAG"
curl -v "https://$SOLR_USER:$SOLR_PASSWORD@solrcloud.tul-infra.page/solr/admin/collections?action=CREATE&name=tul_cob-web-$LATEST_TAG&numShards=1&replicationFactor=2&maxShardsPerNode=1&collection.configName=tul_cob-web-$LATEST_TAG"
curl -v "https://$SOLR_USER:$SOLR_PASSWORD@solrcloud.tul-infra.page/solr/admin/collections?action=CREATEALIAS&name=tul_cob-web-$LATEST_TAG&collections=tul_cob-web-$LATEST_TAG"
curl -v -X POST -H "Authorization: token $GITHUB_TOKEN" --data-binary @"/home/travis/build/tulibraries/ansible-playbook-solrcloud/data/tmp/collections/tul_cob-web.zip" -H "Content-Type: application/octet-stream" "https://uploads.github.com/repos/tulibraries/tul_cob-web-solr/releases/$LATEST_RELEASE_ID/assets?name=tul_cob-web-$LATEST_TAG.zip"
