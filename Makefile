data/css/%.css: style/%.styl style/_theme.styl
	./node_modules/.bin/stylus -I ./style < "$<" > "$@"

data/modules/%.js: modules/%.coffee
	cat "$<" | ./node_modules/.bin/coffee -b -c -s | ./node_modules/.bin/standard-format - > "$@"

icon.png: logo.svg
	node_modules/.bin/svgexport "$<" "$@" 48:48 "svg {background: #ff8937; width: 25px; height: 25px; padding: 2.5px}"

all: $(patsubst style/%.styl, data/css/%.css, $(wildcard style/hn-*.styl)) \
     $(patsubst modules/%.coffee, data/modules/%.js, $(wildcard modules/*.coffee)) \
     icon.png
	./node_modules/.bin/jpm xpi
