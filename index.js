var self = require('sdk/self');
var pageMod = require('sdk/page-mod');
var {prefs} = require("sdk/simple-prefs");
let {Cc, Ci} = require('chrome');

function notDataUrl(name) {
  return self.data.url(name).replace("/data/", "/");
}

function notDataRead(name) {
  return self.data.load("../" + name);
}

var modules = {
  mark_as_read: {
    toggle: function (params) {
      var self = this;
      let { search } = require("sdk/places/history");

      search(params).on("end", function (results) {
        if (results.length > 0) {
          self.delete(params);
        } else {
          self.add(params);
        }
      });
    },
    delete: function (params) {
      console.error("Removing: ", params.url);
      Cc["@mozilla.org/browser/nav-history-service;1"]
        .getService(Ci.nsIBrowserHistory).removePage(params);

    },
    add: function (params) {
      console.error("Adding: ", params.url);
      Cc["@mozilla.org/browser/history;1"]
        .getService(Ci.mozIAsyncHistory).updatePlaces({
          uri: params.url,
          visitDate: new Date().toJSON().slice(0, 10)
        });
    }
  }
};

getModule = function (name) {
  return self.data.url("modules/" + name + ".js")
}

var contentStyles;
var contentScripts = [
  self.data.url("utility.js"),
  self.data.url("settings.js")
]

if (prefs.visualTheme) {
  contentScripts.push(getModule("visual-theme"))
  if (prefs.darkTheme) {
    contentStyles = ['./css/hn-theme-dark.css'];
  } else if (prefs.highContrast) {
    contentStyles = ['./css/hn-theme-light-contrast.css'];
  } else {
    contentStyles = ['./css/hn-theme-light.css'];
  }
}
if (prefs.accurateDomainNames) {
  contentScripts.push(getModule("accurate-domain-names"))
}
if (prefs.foldComments) {
  contentScripts.push(getModule("fold-comments"))
}
if (prefs.highlightLinksWhenReturning) {
  contentScripts.push(getModule("highlight-links-when-returning"))
}
if (prefs.infiniteScrolling) {
  contentScripts.push(getModule("infinite-scrolling"))
}
if (prefs.markAsRead) {
  contentScripts.push(getModule("mark-as-read"))
}
if (prefs.openLinksInNewTabs) {
  contentScripts.push(getModule("open-links-in-new-tabs"))
}
if (prefs.userTooltips) {
  contentScripts.push(getModule("user-tooltips"))
}

if (prefs.grayVisitedLinks) {
  contentStyles.push("./css/hn-theme-gray-visited-links.css")
}
if (prefs.stickyHeader) {
  contentStyles.push("./css/hn-theme-sticky-header.css")
}

pageMod.PageMod({
  include: "https://news.ycombinator.com/*",
  attachTo: ["top", "existing"],
  contentScriptFile: contentScripts,
  contentScriptOptions: {
    urlBase: notDataUrl(""),
    defaultOptions: JSON.stringify(prefs)
  },
  contentStyleFile: contentStyles,
  onAttach: function(worker) {
    for(var moduleName in modules) {
      var module = modules[moduleName];

      for(var actionName in modules[moduleName]) {
        worker.port.on(moduleName + "#" + actionName, function(params) {
          module[actionName].call(module, params);
        });
      }
    }
  }
});
