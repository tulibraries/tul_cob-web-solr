DOCKER := docker compose

up:
	$(DOCKER) up -d
	$(DOCKER) exec app bundle install
down:
	$(DOCKER) down
tty-app:
	$(DOCKER) exec app bash
tty-solr:
	$(DOCKER) exec solr bash
lint:
	$(DOCKER) exec app bundle exec rubocop
test:
	$(DOCKER) exec app bundle exec rspec 
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
