DOCKER := docker compose
BUNDLE_ENV := -e BUNDLE_USER_HOME=/app/.bundle -e TMPDIR=/app/tmp -e HOME=/app

up:
	$(DOCKER) up -d
	$(DOCKER) exec app mkdir -p /app/.bundle /app/tmp /app/.cache
	$(DOCKER) exec $(BUNDLE_ENV) app bundle install
down:
	$(DOCKER) down
tty-app:
	$(DOCKER) exec app bash
tty-solr:
	$(DOCKER) exec solr bash
lint: up
	$(DOCKER) exec $(BUNDLE_ENV) app bundle exec rubocop
test: up
	$(DOCKER) exec $(BUNDLE_ENV) app bundle exec rspec 
load-data:
	$(DOCKER) exec app load-data
reload-config:
	$(DOCKER) exec solr solr-configs-reset
ps:
	$(DOCKER) ps
zip:
	bash ./.github/scripts/build.sh
deploy:
	bash ./.github/scripts/deploy.sh
