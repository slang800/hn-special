# Tweaks the content of the pages to allow for better styling
ignore = [
  '/rss'
  '/bigrss'
]
# Utility functions

stripAttributes = (data) ->
  matchElements = 'body, table, tr, td, span, p, div, input'
  set = undefined
  if data
    data = data.map((element) ->
      _.$ matchElements, element
    )
    set = Array::concat.apply([], data)
  else
    set = _.$(matchElements)
  # Removes all styling attributes
  set.forEach (elem) ->
    attrs = elem.attributes
    names = []
    # This is contrived because .length changes, messing up the loop
    i = 0
    while i < attrs.length
      attr = attrs[i].name
      if [
          'colspan'
          'class'
          'id'
          'type'
          'name'
          'value'
          'title'
        ].indexOf(attr) != -1
        i++
        continue
      names.push attr
      i++
    names.forEach (attr) ->
      if attr.match(/^data-hnspecial/i)
        return
      # Skip attributes added by HN Special
      elem.removeAttribute attr
      return
    return
  return

if ignore.indexOf(location.pathname) == -1
  # Removes the original HN CSS to avoid conflicts with the CSS added by the
  # extension
  _.$('link[rel=stylesheet], style').forEach (elem) ->
    elem.remove()
    return
  # Store the topcolor so we can use it later
  topcolor = _.$('table > tbody > tr td')[0].bgColor
  # Get rid of styling attributes embedded in code
  stripAttributes()
  document.documentElement.classList.add 'hnspecial-theme'
  body = document.body
  # Main container (contains header and content)
  container = _.$('body > center > table > tbody')[0]
  if typeof container != 'undefined'
    container.children[0].children[0].style.backgroundColor = topcolor
  logo = _.$('img[src=\'y18.gif\']')[0]
  if logo
    # Make the logo go to the home of hacker news
    logo.parentElement.setAttribute 'href', location.origin
    logo.removeAttribute 'style'
    logo.removeAttribute 'width'
    logo.removeAttribute 'height'
    logo.setAttribute 'src', 'resource://hn-special/logo.svg'
  # Apply to pages with a container
  if container
    # Check for the presence of a maintenance warning or other things in the
    # way and remove them (issue #42)
    messageContainer = container.children[1]
    message = messageContainer.getElementsByClassName('pagetop')
    if message.length
      message = message[0].innerHTML
      messageContainer.remove()
      # Restore the message as a separate div
      header = container.firstChild.firstChild
      messageContainer = _.createElement('div',
        classes: [ 'hnspecial-message-container' ]
        content: message)
      header.appendChild messageContainer
    # TD with content (after the header)
    content = container.children[2].children[0]
    # If the content TD is empty, add all of the following TDs into it (happens
    # in threads page)
    if !content.textContent.trim().length
      # Empty the element completely
      content.innerHTML = ''
      # New table to hold comments (mimics comment page structure)
      table = _.createElement('table')
      tbody = _.createElement('tbody')
      i = 3
      # First stray row is at index 3
      while !container.children[i].getElementsByClassName('yclinks').length
        # Stop at the footer
        tbody.appendChild container.children[i]
      table.appendChild tbody
      content.appendChild table
    # Add a class to the body if it's a form page
    # Get the form in the content td
    form = content.getElementsByTagName('form')[0]
    title = document.getElementsByClassName('title')[0]
    isCommentPage = _.isCommentPage()
    if form and !isCommentPage
      document.documentElement.classList.add 'hnspecial-form-page'
      form = document.getElementsByTagName('form')[0]
      _.toArray(form.getElementsByTagName('textarea')).forEach (textarea) ->
        textarea.parentElement.parentElement.children[0].classList.add 'hnspecial-textarea-label'
        return
      # Fix up stray text near P tags in form pages
      _.toArray(form.getElementsByTagName('p')).forEach (paragraph) ->
        `var container`
        container = paragraph.parentElement
        unwrapped = container.childNodes[0]
        text = unwrapped.nodeValue
        unwrapped.remove()
        paragraph = _.createElement('p')
        paragraph.textContent = text
        container.insertBefore paragraph, container.children[0]
        return
      # Add indication of original HN Special color next to topcolor for
      # topcolor users
      topcolorInput = _.$('input[name=topcolor]')[0]
      if topcolorInput
        topcolorInput.parentElement.appendChild _.createElement('p', content: 'Default HN color: <pre>#ff6700</pre> — HN Special color: <pre>#ff8937</pre>.')
    # Remove some of the vertical bars
    _.$('.pagetop, span.yclinks').forEach (elem) ->
      _.toArray(elem.childNodes).forEach (node) ->
        if node.nodeType == Node.TEXT_NODE
          node.nodeValue = node.nodeValue.replace(/\|/g, '')
        return
      return
    # Applied to comment pages
    if isCommentPage
      tableContainer = title.parentElement.parentElement
      if tableContainer.childElementCount >= 4
        textContainer = title.parentElement.parentElement.children[3].children[1]
        # If the post has textual content, wrap stray text in a paragraph
        if textContainer.textContent.trim().length
          nodes = _.toArray(textContainer.childNodes).filter((node) ->
            node.nodeType == Node.TEXT_NODE
          )
          # Replaced each stray text node with a paragraph
          nodes.forEach (node) ->
            paragraph = _.createElement('p')
            paragraph.textContent = node.nodeValue
            textContainer.insertBefore paragraph, node
            node.remove()
            return
    # Wrap the stray pieces of text in comments into their own <p> and add a
    # class to the upvote td
    _.$('span.comment').forEach (elem) ->
      # Make sure each stray piece (stuff that is not in a paragraph) gets
      # grouped in paragraphs
      stops = [
        'p'
        'pre'
      ]
      # Elements that should not be joined in the same paragraph
      current = elem.childNodes[0]
      # Start from the first node
      while current
        if stops.indexOf(current.nodeName.toLowerCase()) != -1
          # Jump to the next stray node
          current = current.nextSibling
          i++
          continue
        group = [ current ]
        # Elements to be grouped in the same paragraph
        sibling = current.nextSibling
        while sibling and stops.indexOf(sibling.nodeName.toLowerCase()) == -1
          group.push sibling
          sibling = sibling.nextSibling
        paragraph = _.createElement('p')
        elem.insertBefore paragraph, current
        group.forEach (element) ->
          `var container`
          paragraph.appendChild element
          return
        current = paragraph
      # Add a class to the upvote button
      container = elem.parentElement.parentElement
      index = 1
      if container.childElementCount == 2
        index = 0
      # page /newcomments has two tds instead of three
      container.children[index].classList.add 'hnspecial-upvote-button'
      # Replace the s.gif spacer image
      cell = container.children[0]
      img = container.getElementsByTagName('img')[0]
      if typeof img != 'undefined' and img.tagName.toLowerCase() == 'img'
        div = _.createElement('div',
          classes: [ 'hnspecial-theme-spacer-container' ]
          attributes: style: 'width: ' + img.getAttribute('width') + 'px')
        div.appendChild _.createElement('div', classes: [ 'hnspecial-theme-spacer' ])
        cell.classList.add 'hnspecial-theme-spacer-cell'
        cell.appendChild div
        # Hide the spacer image but don't remove it
        img.setAttribute 'style', 'display: none'
      return
    # Add a class to the upvote buttons on poll items
    _.$('td.comment').forEach (elem) ->
      row = elem.parentElement
      row.classList.add 'hnspecial-poll-row'
      arrow = row.children[0]
      arrow.classList.add 'hnspecial-upvote-button', 'poll'
      return
    if location.pathname.match(/^\/topcolors/)
      # Somehow match the topcolor container
      topcolorContainer = _.$('img[src=\'s.gif\']')[0].parentElement.parentElement.parentElement
      topcolorContainer.parentElement.parentElement.style.position = 'relative'
      # I'm so sorry
      _.toArray(topcolorContainer.children).forEach (row) ->
        colorContainer = row.children[0]
        color = '#' + colorContainer.textContent.trim()
        colorContainer.appendChild _.createElement('div',
          classes: [ 'hnspecial-theme-topcolor-preview' ]
          attributes: style: 'background-color: ' + color)
        return
  else
    # The page has no container. It's either the login page or an error page
    # Style error pages (ignoring the rss page)
    if !body.childElementCount or body.children[0].nodeName.toLowerCase() == 'pre'
      document.documentElement.classList.add 'error'
      # Set the page title
      document.title = body.textContent.trim()
      # Dirty hack to remove the <pre> element shown on 404 pages
      body.innerHTML = body.textContent
      # Back link
      link = _.createElement('a')
      link.setAttribute 'href', location.origin
      link.textContent = 'Back home'
      body.appendChild link
    # Select log in form
    if _.$('body > form')[0]
      document.documentElement.classList.add 'hnspecial-form-page', 'login'
      # Wrap everything in the body in a div
      loginContainer = _.createElement('div')
      loginContainer.classList.add 'hnspecial-form-container'
      while body.firstChild
        loginContainer.appendChild body.firstChild
      body.appendChild loginContainer
# Subscribe to new links
HNSpecial.subscribe 'new links', (data) ->
  stripAttributes data
  return
