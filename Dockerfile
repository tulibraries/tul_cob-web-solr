FROM solr:9.8.1

# Install the ICU Analysis plugin (analysis-extras)
RUN solr-plugin install analysis-extras
