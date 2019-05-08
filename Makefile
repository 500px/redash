lint:
	./bin/flake8_tests.sh

frontend-unit-tests: bundle
	npm install
	npm run bundle
	npm test

test: lint backend-unit-tests frontend-unit-tests

build: bundle
	npm run build

watch: bundle
	npm run watch

start: bundle
	npm run start
