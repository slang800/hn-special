# Contributing

## Building the extension

If you haven't installed [Node.js](http://nodejs.org/) do so. Then you can install all the deps by cloning down this repo, `cd`ing into the directory, and using:

```bash
npm install
```

Then you can build the addon using:

```bash
make all
```

From here you have two options for testing. One, you can run the addon in Firefox test mode. To do this, run:

```bash
node_modules/.bin/jpm run
```

Or you can use [Extension Auto-Installer](https://addons.mozilla.org/en-US/firefox/addon/autoinstaller/) to run and update the addon in a normal Firefox window. From a command line, you can simplify this process by running:

```bash
make all && wget --post-file *.xpi http://localhost:8888/
```
