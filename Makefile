data/css/%.css: style/%.styl style/_theme.styl
	./node_modules/.bin/stylus -I ./style < "$<" > "$@"

icon.png: logo.svg
	node_modules/.bin/svgexport "$<" "$@" 48:48 "svg {background: #ff8937; width: 25px; height: 25px; padding: 2.5px}"

all: icon.png $(patsubst style/%.styl, data/css/%.css, $(wildcard style/hn-*.styl))
	./node_modules/.bin/jpm xpi
