# The search bar is at the bottom of the page and just takes you to algolia.com
# I've never found it useful, especially when Google is avaliable, so remove it
searchBar = document.querySelector('form[action="//hn.algolia.com/"]')
if searchBar
  searchBar.remove()
