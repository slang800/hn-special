editLinks = ->
  titles = _.toArray(document.getElementsByClassName('title'))
  titles.forEach (title) ->
    if not title.getAttribute('data-hnspecial-accurate') and
       title.childElementCount is 2 and
       title.children[1].classList.contains('comhead')
      # Removes http/https, matches the domain name excluding www
      url = title.children[0].host.replace('www.', '')
      domain = title.children[1]
      domain.textContent = ' (' + url + ') '
      title.setAttribute 'data-hnspecial-accurate', 'true'
    return
  return

# Run it
editLinks()

# Subscribe to the event emitted when new links are present
HNSpecial.subscribe 'new links', editLinks
