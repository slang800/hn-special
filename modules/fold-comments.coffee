baseWidth = 40

getCommentDepth = (comment) ->
  spacer = comment.getElementsByTagName('img')[0]
  parseInt(spacer.getAttribute('width'), 10) / baseWidth

if _.isCommentPage() or location.pathname.match(/^\/(item|threads)/)
  _.toArray(document.getElementsByClassName('default')).forEach (comment) ->
    # Least horrible way to get to the comment row
    row = comment.parentElement.parentElement.parentElement.parentElement.parentElement

    # Skip this row if we're on a comment permalink page and it's the comment at
    # the top
    if row.nextElementSibling and
       row.nextElementSibling.getElementsByClassName('yclinks').length
      return
    comhead = comment.getElementsByClassName('comhead')[0]
    # if we've already got a fold button then skip (can happen if the plugin is
    # disabled and reenabled)
    existingFoldButtons = comment.getElementsByClassName(
      'hnspecial-fold-comment-button'
    )
    if existingFoldButtons.length > 0
      return
    comhead.appendChild document.createTextNode(' | ')
    button = _.createElement('button',
      content: '[ - ]'
      classes: [ 'hnspecial-fold-comment-button' ])
    comhead.appendChild button
    button.addEventListener 'click', ->
      folded = comment.classList.contains('hnspecial-folded-comment')
      method = if folded then 'remove' else 'add'
      # Fold/unfold the current comment
      comment.classList[method] 'hnspecial-folded-comment'
      button.innerHTML = if folded then '[ - ]' else '[ + ]'
      # Depth of the current comment
      baseDepth = getCommentDepth(row)
      current = row

      # The comments are not organised in a tree so we have to cycle through
      # each row and find the nesting manually, then also skip appropriately if
      # some of the comments below the one we're folding are already folded
      foldedDepth = null

      # Depth of the topmost folded comment in the tree we're folding
      # Fold nested comments (if present)
      while current = current.nextElementSibling
        depth = getCommentDepth(current)
        if depth <= baseDepth
          break
        # Check if we need to skip the comment because it's under a folded one
        if foldedDepth?
          if depth > foldedDepth
            continue
          else
            # We're out of the comments nested under the hidden one so we can
            # stop skipping
            foldedDepth = null

        # If the current comment is folded, set foldedDepth to avoid touching
        # the nested ones
        if current.getElementsByClassName('hnspecial-folded-comment').length
          foldedDepth = depth

        # Fold/unfold the current comment
        current.classList[method] 'hnspecial-folded-row'
      return
    return
