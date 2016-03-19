function editLinks () {
  _.toArray(document.getElementsByTagName('a')).forEach(function (link) {
    if (_.isTitleLink(link) || _.isCommentLink(link)) {
      link.setAttribute('target', '_blank')
    }
  })
}

// Run it
editLinks()

// Subscribe to the event emitted when new links are present
HNSpecial.subscribe('new links', editLinks)
