(->
  container = undefined
  timeout = undefined
  request = undefined
  tooltip = undefined
  cache = {}

  remove = ->
    clearTimeout timeout
    if request
      request.abort()
      request = null
    if container
      container.remove()
      container = null
      tooltip = null
    return

  window.addEventListener 'scroll', remove
  _.$('a[href^="user?id="]').forEach (link) ->
    href = link.href

    offset = (key) ->
      # Walk up link parent tree and increment offset
      elem = link
      num = 0
      loop
        if !isNaN(elem[key])
          num += elem[key]
        unless elem = elem.offsetParent
          break
      num

    display = (page) ->
      # Create dummy element so we can query it
      dummy = _.createElement('div')
      dummy.innerHTML = page
      tooltip.innerHTML = ''
      container.classList.add 'hn-special-tooltip-loaded'
      _.$('td[valign=top]', dummy).forEach (td) ->
        key = td.textContent.slice(0, -1)
        # Remove trailing colon
        valField = td.parentNode.children[1]
        # Sanitize contents of the about section or similar
        _.$('font', valField).forEach (elem) ->
          # Clear out unwanted elements
          elem.remove()
          return
        val = ''
        # Gather the text from the children elements in the <td>, adding
        # newlines as needed
        _.toArray(valField.childNodes).forEach (node) ->
          if node.nodeType == 1
            nodeName = node.nodeName.toLowerCase()
            if nodeName == 'p'
              val += node.textContent + '\n'
            else
              if nodeName != 'select'
                val += node.textContent
          else if node.nodeType == 3
            # Text node
            val += node.nodeValue + '\n'
          return
        val = val.trim()
        if !val
          return
        # Cut the value if it's too long
        if val.length >= 100
          val = val.slice(0, 100).trim() + '...'
        # Replace newlines with <br>
        val = val.replace('\n', '<br>')
        row = _.createElement('div', classes: [ 'hn-special-tooltip-row' ])
        tooltip.appendChild row
        keyElem = _.createElement('div',
          classes: [ 'hn-special-tooltip-key' ]
          content: _.naturalWords(key))
        row.appendChild keyElem
        valElem = _.createElement('div',
          classes: [ 'hn-special-tooltip-value' ]
          content: val)
        row.appendChild valElem
        clear = _.createElement('div', classes: [ 'hn-special-tooltip-clear' ])
        tooltip.appendChild clear
        return
      # Check if the tooltip is too big to fit on the screen and invert if it
      # is
      lowestPoint = offset('offsetTop') + container.offsetHeight
      if lowestPoint > window.innerHeight
        container.style.top = offset('offsetTop') - container.offsetHeight
        container.classList.add 'hn-special-tooltip-inverted'
      return

    link.onmouseover = ->
      remove()
      timeout = setTimeout((->
        # Create the container here so the user has feedback that it's loading
        container = _.createElement('div', classes: [ 'hn-special-tooltip-container' ])
        document.body.appendChild container
        # Position the tooltip container right underneath the user link
        container.style.top = offset('offsetTop') + link.offsetHeight
        container.style.left = offset('offsetLeft')
        tooltip = _.createElement('div',
          classes: [ 'hn-special-tooltip' ]
          content: 'Loading...')
        container.appendChild tooltip
        cached = cache[href]
        if cached
          display cached
        else
          request = _.request(link.href, 'GET', (page) ->
            cache[href] = page
            display page
            return
          )
        return
      ), 500)
      return

    link.onmouseout = remove
    return
  return
).call this
