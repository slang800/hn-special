var pageMod = require('sdk/page-mod')
var self = require('sdk/self')
var simplePrefs = require('sdk/simple-prefs')

function notDataUrl (name) {
  return self.data.url(name).replace('/data/', '/')
}

getModule = function (name) {
  return self.data.url('modules/' + name + '.js')
}

var currentPageMod
reloadPageMod = function () {
  const {prefs} = simplePrefs
  var contentStyles = []
  var contentScripts = [
    self.data.url('utility.js'),
    self.data.url('settings.js')
  ]

  if (typeof currentPageMod !== 'undefined') {
    currentPageMod.destroy('preferences changed')
  }

  if (prefs.theme !== 'none') {
    contentScripts.push(getModule('visual-theme'))
  }
  if (prefs.accurateDomainNames) {
    contentScripts.push(getModule('accurate-domain-names'))
  }
  if (prefs.foldComments) {
    contentScripts.push(getModule('fold-comments'))
    contentStyles.push('./css/hn-theme-fold-comments.css')
  }
  if (prefs.infiniteScrolling) {
    contentScripts.push(getModule('infinite-scrolling'))
  }
  if (prefs.openLinksInNewTabs) {
    contentScripts.push(getModule('open-links-in-new-tabs'))
  }
  if (prefs.removeSearchBar) {
    contentScripts.push(getModule('remove-search-bar'))
  }
  if (prefs.userTooltips) {
    contentScripts.push(getModule('user-tooltips'))
    contentStyles.push('./css/hn-theme-user-tooltips.css')
  }

  if (prefs.theme === 'light') {
    contentStyles.push('./css/hn-theme-light.css')
  } else if (prefs.theme === 'dark') {
    contentStyles.push('./css/hn-theme-dark.css')
  } else if (prefs.theme === 'high-contrast') {
    contentStyles.push('./css/hn-theme-light-contrast.css')
  }

  if (prefs.grayVisitedLinks) {
    contentStyles.push('./css/hn-theme-gray-visited-links.css')
  }
  if (prefs.stickyHeader) {
    contentStyles.push('./css/hn-theme-sticky-header.css')
  }

  currentPageMod = pageMod.PageMod({
    include: 'https://news.ycombinator.com/*',
    attachTo: ['top', 'existing'],
    contentScriptFile: contentScripts,
    contentStyleFile: contentStyles
  })
}

simplePrefs.on('', reloadPageMod)
reloadPageMod()
