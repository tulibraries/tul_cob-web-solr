# TUL COB Web Content Solr Configurations
[![Test](https://github.com/tulibraries/tul_cob-web-solr/actions/workflows/test.yml/badge.svg)](https://github.com/tulibraries/tul_cob-web-solr/actions/workflows/test.yml)
[![Deploy](https://github.com/tulibraries/tul_cob-web-solr/actions/workflows/deploy.yml/badge.svg)](https://github.com/tulibraries/tul_cob-web-solr/actions/workflows/deploy.yml)

These are the Solr configuration files for the TUL Cob (LibrarySearch) web content search & faceting Solr collection.

## Prerequisites

- These configurations are built for Solr 9.8.1
- The instructions below presume a SolrCloud multi-node setup (using an external Zookeeper)

## Local Testing / Development

To test locally do the following.

* make up: Will spin up a local Solr instance and ruby container for running tests.
* make load-data: Will load required data into Solr instance.
* make test: Will run the search relevancy tests.

### Miscellaneous
#### Starting over
To start over from scratch you can run `make down` followed by `make up`
There is a `make reload-config` which reloads the Solr config, but this will not delete the documents that were already present.

#### Beyond the basics
Anything more interesting than a simple local test should probably happen inside the respective container.

Use `make tty-app` to bash into the ruby container.
Use `make tty-solr` to bash into the solr container.

#### Gem updates
Gemfile.lock MUST NOT be updated from outside the container; doing so may cause conflicts with bundler version that is used inside the container vs whatever the local version of bundler that you have installed.

To that end, if you need to update a gem do the following:

* `make tty-app`
* Once inside the container run bundle update [gem-name]

## SolrCloud Deployment

All PRs merged into the `main` branch are _not_ deployed anywhere. Only releases are deployed.

### Production

Once the main branch has been adequately tested and reviewed, a release is cut. Upon creating the release tag (generally just an integer), the following occurs:
1. new ConfigSet of `tul_cob-web-{release-tag}` is created in [Production SolrCloud](https://solrcloud.tul-infra.page);
2. new Collection of `tul_cob-web-{release-tag}-init` is created in [Production SolrCloud](https://solrcloud.tul-infra.page) w/the requisite ConfigSet (this Collection is largely ignored);
3. a new QA alias of `tul_cob-web-{release-tag}-qa` is created in [Production SolrCloud](https://solrcloud.tul-infra.page), pointing to the init Collection;
3. a new Stage alias of `tul_cob-web-{release-tag}-stage` is created in [Production SolrCloud](https://solrcloud.tul-infra.page), pointing to the init Collection;
3. a new Production alias of `tul_cob-web-{release-tag}-prod` is created in [Production SolrCloud](https://solrcloud.tul-infra.page), pointing to the init Collection;
4. and, manually, a full reindex DAG is kicked off from Airflow Production to this new tul_cob-web alias. Upon completion of the reindex, relevant clients are redeployed pointing at their new alias, and *then QA & UAT review occur*.

See the process outlined here: https://github.com/tulibraries/docs/blob/main/services/solrcloud.md
