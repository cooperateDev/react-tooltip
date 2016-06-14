NODE_BIN 		 = node_modules/.bin
EXAMPLE_DIST = example/dist
EXAMPLE_SRC  = example/src
STANDALONE   = standalone
SRC          = src
DIST         = dist

lint:
	@echo linting...
	@$(NODE_BIN)/standard --verbose | $(NODE_BIN)/snazzy src/index.js

convertCss:
	@echo Converting css...
	@node bin/transferSass.js

genStand:
	@echo Generating standard...
	@rm -rf $(STANDALONE) && mkdir $(STANDALONE)
	@$(NODE_BIN)/browserify -t babelify -t browserify-shim $(SRC)/index.js --standalone ReactTooltip -o $(STANDALONE)/react-tooltip.js
	@$(NODE_BIN)/browserify -t babelify -t browserify-shim $(SRC)/index.js --standalone ReactTooltip | $(NODE_BIN)/uglifyjs > $(STANDALONE)/react-tooltip.min.js
	@cp $(DIST)/style.js $(STANDALONE)/style.js

dev:
	@echo starting dev server...
	@rm -rf $(EXAMPLE_DIST)
	@mkdir -p $(EXAMPLE_DIST)
	@make convertCss
	@$(NODE_BIN)/watchify -t babelify $(EXAMPLE_SRC)/index.js -o $(EXAMPLE_DIST)/index.js -dv
	@$(NODE_BIN)/node-sass $(EXAMPLE_SRC)/index.scss $(EXAMPLE_DIST)/index.css
	@$(NODE_BIN)/node-sass -w $(EXAMPLE_SRC)/index.scss $(EXAMPLE_DIST)/index.css
	@$(NODE_BIN)/http-server example -p 8888 -s -o

deployJS:
	@echo Generating deploy JS files...
	@$(NODE_BIN)/babel $(SRC)/index.js -o $(DIST)/react-tooltip.js
	@$(NODE_BIN)/babel $(SRC)/style.js -o $(DIST)/style.js
	@$(NODE_BIN)/babel $(SRC)/index.js | $(NODE_BIN)/uglifyjs > $(DIST)/react-tooltip.min.js

deployCSS:
	@echo Generating deploy CSS files...
	@cp $(SRC)/index.scss $(DIST)/react-tooltip.scss
	@$(NODE_BIN)/node-sass --output-style compressed $(SRC)/index.scss $(DIST)/react-tooltip.min.css

deploy: lint
	@echo Deploy...
	@rm -rf dist && mkdir dist
	@make convertCss
	@make deployCSS
	@make deployJS
	@make genStand
	@echo success!

.PHONY: lint convertCss genStand dev deployJS deployCSS deploy
