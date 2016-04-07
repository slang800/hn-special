# The code in this module is ugly. It could use a rewrite.
disabled = false
labels = ['Pause infinite scrolling', 'Resume infinite scrolling']
loading = false
loads = 0
nextLoads = undefined
notice = false

getThreshold = ->
  # getBoundingClientRect returns coordinates relative to the viewport
  window.scrollY + button.getBoundingClientRect().bottom + 50

getButton = (context) ->
  _.$('td.title > a[href^=\'news?p=\']', context)[0]

replaceButton = (message) ->
  button.textContent = message
  button.nextSibling.remove()
  # Remove the pause button
  _.replaceTag button, 'span'
  disabled = true
  return

pauseLoading = (e) ->
  if e then e.preventDefault()
  disabled = not disabled
  pause.textContent = labels[if disabled then 1 else 0]
  checkScroll()
  return

checkScroll = ->
  if !disabled and window.scrollY + window.innerHeight > threshold
    loadLinks()
    nextLoads = loads - 3
    if loads is 1
      if not notice
        elem = _.createElement('div',
          classes: [ 'hnspecial-infinite-search-notice' ]
          content: 'Please keep scrolling if you want to access the footer.
          <span>(click to close)</span>'
        )

        elem.addEventListener 'click', ->
          @classList.add 'hnspecial-infinite-search-notice-hidden'
          return

        document.body.addEventListener 'click', (e) ->
          if not elem.classList.contains('hnspecial-infinite-search-notice-hidden') and
             e.target isnt elem
            elem.classList.add 'hnspecial-infinite-search-notice-hidden'
          return

        document.body.appendChild elem
        notice = true
    else if loads is 3 or nextLoads > 0 and nextLoads % 5 is 0
      pauseLoading()
      setTimeout (->
        # Remove the notice
        elem = document.getElementsByClassName(
          'hnspecial-infinite-search-notice'
        )[0]
        if elem
          elem.classList.add 'hnspecial-infinite-search-notice-hidden'
        return
      ), 1000
  return

loadLinks = ->
  if loading then return
  loading = true
  loads++
  label = button.textContent
  button.textContent = 'Loading more items...'
  last = button.parentElement.parentElement.previousSibling
  container = last.parentElement
  url = button.getAttribute('href')
  _.request url, 'GET', (page) ->
    dummy = _.createElement('div')
    dummy.innerHTML = page
    if dummy.getElementsByClassName('title').length
      # Create a separator
      separator = _.createElement('tr'
        classes: ['hnspecial-infinite-scroll-separator']
      )
      cell = _.createElement('td', attributes: colspan: 3)
      cell.appendChild _.createElement('span', content: 'Page ' + (loads + 1))
      separator.appendChild cell
      container.insertBefore separator, last
      # Add in the rows
      additions = []
      _.toArray(dummy.getElementsByTagName('a')).forEach (link) ->
        if _.isTitleLink(link)
          row = link.parentElement.parentElement
          sub = row.nextSibling
          empty = sub.nextSibling
          container.insertBefore row, last
          container.insertBefore sub, last
          container.insertBefore empty, last
          additions.push row, sub, empty
        return
      newButton = getButton(dummy)
      if newButton
        button.textContent = label
        button.setAttribute 'href', newButton.getAttribute('href')
        threshold = getThreshold()
      else
        replaceButton 'No more links to load.'

      loading = false

      # Notify other modules about the presence of new links
      HNSpecial.emit 'new links', additions
    else
      replaceButton 'Couldn\'t load the page. Please try refreshing.'
    return
  return

# Set up the thing
button = getButton()

if _.isListingPage() and button
  threshold = getThreshold()
  pause = _.createElement('a',
    content: labels[0]
    classes: ['hnspecial-infinite-pause']
    attributes: 'href': '#'
  )
  pause.addEventListener 'click', pauseLoading
  button.parentElement.appendChild pause
  button.addEventListener 'click', (e) ->
    e.preventDefault()
    loadLinks()
    return
  document.addEventListener 'scroll', checkScroll
