{View} = require 'atom'
$ = View.__super__.constructor

module.exports =
class BreadcrumbView extends View
  @content: ->
    @div class: 'tree-view-breadcrumb tool-panel', =>
      @div outlet: 'breadcrumb', class: 'btn-group', =>
        @div class: 'btn', atom.project.getPath().split('/').pop()

  lastFirstVisibleTreeItem: null
  lastParent: null

  initialize: (state) ->
    {@treeView} = require(atom.packages.getLoadedPackage('tree-view').path)
    @treeViewScroller = @treeView.find('.tree-view-scroller')

    @treeViewScroller.on 'scroll', @treeViewScrolled

  show: ->
    @attach()
    @treeView.addClass('with-breadcrumb')
    @addClass('visible')

  hide: ->
    @removeClass('visible')
    @treeView.removeClass('with-breadcrumb')
    setTimeout((=> @detach()), 300)

  attach: ->
    atom.workspaceView.find('.tree-view-resizer').prepend(this)
    @attached = true

  detach: ->
    super
    @attached = false

  destroy: ->
    @detach()

  treeViewScrolled: =>
    scrollTop = @treeView.scrollTop()

    if scrollTop > 0 and !@attached
      @show()
    else if @attached and scrollTop is 0
      @hide()

    currentFirstVisibleTreeItem = @firstVisibleTreeItem(scrollTop)
    if currentFirstVisibleTreeItem? and currentFirstVisibleTreeItem isnt @lastFirstVisibleTreeItem
      @lastFirstVisibleTreeItem = currentFirstVisibleTreeItem
      currentParent = $(currentFirstVisibleTreeItem).parents('ol').first().parent().children('.header')[0]
      if currentParent isnt @lastParent
        @updateBreadcrumb(currentParent)
        @lastParent = currentParent

  updateBreadcrumb: (node) ->
    node = $(node)
    html = []
    parents = []
    parents.unshift n for n in node.parents('.directory')
    parents.shift()

    parents.forEach (node) ->
      html.push "<div class='btn'>#{$(node).children('.header').text()}</div>"

    @breadcrumb.html html.join('')


  getItemHeight: ->
    @treeView.find('.list-item.header').first().height()

  firstVisibleTreeItem: (scrollTop) ->
    itemHeight = @getItemHeight()
    self = this
    found = null
    @treeView.find('.list-item.header, .list-item.file').each ->
      if @offsetTop < scrollTop + itemHeight / 2 and @offsetTop + itemHeight > scrollTop + itemHeight / 2
        found = this

    found
