editLinks = ->
  _.toArray(document.getElementsByTagName('a')).forEach (link) ->
    if _.isTitleLink(link) or _.isCommentLink(link)
      link.setAttribute 'target', '_blank'
    return
  return

# Run it
editLinks()

# Subscribe to the event emitted when new links are present
HNSpecial.subscribe 'new links', editLinks
