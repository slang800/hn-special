data/css/%.css: style/%.styl style/_theme.styl
	./node_modules/.bin/stylus -I ./style < "$<" > "$@"

all: $(patsubst style/%.styl, data/css/%.css, $(wildcard style/hn-*.styl))
	./node_modules/.bin/jpm xpi
