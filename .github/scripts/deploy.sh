#!/usr/bin/env bash
set -e

validate_status() {
  echo "response: $RESP"
  STATUS=$(echo "$RESP" | grep HTTP | awk '{print $2}')
  if [[  "$STATUS" != "200" ]]; then
    echo "Failing because status was not 200"
    echo "status: $STATUS"
    exit 1
  fi
}

validate_create() {
  echo "response: $RESP"
  STATUS=$(echo "$RESP")
  if [[  "$STATUS" != "201" ]]; then
    echo "Failing because status was not 201"
    echo "status: $STATUS"
    exit 1
  fi
}

# Use GitHub tag or manual input
TAG_NAME=${GITHUB_TAG:-$1}

if [ -z "$TAG_NAME" ]; then
  echo "Error: No tag name provided"
  exit 1
fi

echo
echo "***"
echo "* Sending tul_cob-web-$TAG_NAME configs to solrcloud-rocky9."
echo "***"
RESP=$(curl -u $SOLR_USER:$SOLR_PASSWORD -i -o - --silent -X POST --header "Content-Type:application/octet-stream" --data-binary @$HOME/solrconfig.zip "https://solrcloud-rocky9.tul-infra.page/solr/admin/configs?action=UPLOAD&name=tul_cob-web-$TAG_NAME")
validate_status

echo
echo "***"
echo "* Creating new tul_cob-web-$TAG_NAME collection"
echo "***"
RESP=$(curl -u $SOLR_USER:$SOLR_PASSWORD -i -o - --silent -X GET --header 'Accept: application/json' "https://solrcloud-rocky9.tul-infra.page/solr/admin/collections?action=CREATE&name=tul_cob-web-$TAG_NAME-init&numShards=1&replicationFactor=4&maxShardsPerNode=1&collection.configName=tul_cob-web-$TAG_NAME")
validate_status

echo
echo "***"
echo "* Creating qa alias based on configset name."
echo "***"
RESP=$(curl -u $SOLR_USER:$SOLR_PASSWORD -i -o - --silent -X POST --header "Content-Type:application/octet-stream" "https://solrcloud-rocky9.tul-infra.page/solr/admin/collections?action=CREATEALIAS&name=tul_cob-web-$TAG_NAME-qa&collections=tul_cob-web-$TAG_NAME-init")
validate_status

echo
echo "***"
echo "* Creating stage alias based on configset name."
echo "***"
RESP=$(curl -u $SOLR_USER:$SOLR_PASSWORD -i -o - --silent -X POST --header "Content-Type:application/octet-stream" "https://solrcloud-rocky9.tul-infra.page/solr/admin/collections?action=CREATEALIAS&name=tul_cob-web-$TAG_NAME-stage&collections=tul_cob-web-$TAG_NAME-init")
validate_status

echo
echo "***"
echo "* Creating prod alias based on configset name."
echo "***"
RESP=$(curl -u $SOLR_USER:$SOLR_PASSWORD -i -o - --silent -X POST --header "Content-Type:application/octet-stream" "https://solrcloud-rocky9.tul-infra.page/solr/admin/collections?action=CREATEALIAS&name=tul_cob-web-$TAG_NAME-prod&collections=tul_cob-web-$TAG_NAME-init")
validate_status
