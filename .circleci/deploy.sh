#!/usr/bin/env bash

validate_status() {
  echo "Response: $RESPONSE"
  STATUS=$(echo $RESPONSE | grep HTTP | awk '{print $2}')
  if [[ "$STATUS" != "200" ]]; then
    echo "Failing because satus was not 200"
    echo "Status: $STATUS"
    exit 1
  fi


}

echo "Sending tul_cob-web-$CIRCLE_TAG configs to SolrCloud."
RESPONSE=$(curl  -i -o - --silent -X POST --header "Content-Type:application/octet-stream" --data-binary ~/project/ansible-playbook-solrcloud/data/tmp/collections/tul_cob-az.zip "https://$SOLR_USER:$SOLR_PASSWORD@solrcloud.tul-infra.page/solr/admin/configs?action=UPLOAD&name=tul_cob-web-$CIRCLE_TAG")
validate_status

echo "Creating new tul_cob-web-$CIRCLE_TAG collection"
RESPONSE=$(curl -i -o - --silent -X GET --header "Accept: application/json" "https://$SOLR_USER:$SOLR_PASSWORD@solrcloud.tul-infra.page/solr/admin/collections?action=CREATE&name=tul_cob-web-$CIRCLE_TAG&numShards=1&replicationFactor=2&maxShardsPerNode=1&collection.configName=tul_cob-web-$CIRCLE_TAG")
validate_status

ALIAS_SUFFIX=$(ruby -e 'print "#{ENV["TAG"]}".scan(/(-qa|-stage|-rc)$/).flatten.first')
echo "Aliasing tul_cob-web-$CIRCLE_TAG to tul_cob-web$ALIAS_SUFFIX"
RESPONSE=$(curl -i -o - --silent -X GET --header "Accept: application/json" "https://$SOLR_USER:$SOLR_PASSWORD@solrcloud.tul-infra.page/solr/admin/collections?action=CREATEALIAS&name=tul_cob-web$ALIAS_SUFFIX&collections=tul_cob-web-$CIRCLE_TAG")
validate_status
