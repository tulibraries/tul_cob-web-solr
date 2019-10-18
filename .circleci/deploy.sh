#!/usr/bin/env bash

echo "Sending tul_cob-web-$CIRCLE_TAG configs to SolrCloud."
curl -v -X POST --header "Content-Type:application/octet-stream" --data-binary ~/project/ansible-playbook-solrcloud/data/tmp/collections/tul_cob-web.zip "https://$SOLR_USER:$SOLR_PASSWORD@solrcloud.tul-infra.page/solr/admin/configs?action=UPLOAD&name=tul_cob-web-$CIRCLE_TAG"

echo "Creating new tul_cob-web-$CIRCLE_TAG collection"
curl -v "https://$SOLR_USER:$SOLR_PASSWORD@solrcloud.tul-infra.page/solr/admin/collections?action=CREATE&name=tul_cob-web-$CIRCLE_TAG&numShards=1&replicationFactor=2&maxShardsPerNode=1&collection.configName=tul_cob-web-$CIRCLE_TAG"

ALIAS_SUFFIX=$(ruby -e 'print "#{ENV["TAG"]}".scan(/(-qa|-stage|-rc)$/).flatten.first')

echo "Aliasing tul_cob-web-$CIRCLE_TAG to tul_cob-web$ALIAS_SUFFIX"
curl -v "https://$SOLR_USER:$SOLR_PASSWORD@solrcloud.tul-infra.page/solr/admin/collections?action=CREATEALIAS&name=tul_cob-web$ALIAS_SUFFIX&collections=tul_cob-web-$CIRCLE_TAG"
