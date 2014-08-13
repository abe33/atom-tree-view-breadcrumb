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
    pollTreeView = =>
      {@treeView} = require(atom.packages.getLoadedPackage('tree-view').path)
      if @treeView?
        @treeViewScroller = @treeView.find('.tree-view-scroller')
        @treeViewScroller.on 'scroll', @treeViewScrolled
        @rootItem = @treeViewScroller.find('.header.list-item').first()[0]
        @treeViewScrolled()
      else
        setTimeout pollTreeView, 100

    pollTreeView()

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

    currentFirstVisibleTreeItem = @firstVisibleTreeItem(scrollTop)
    currentParent = null
    if currentFirstVisibleTreeItem? and currentFirstVisibleTreeItem isnt @lastFirstVisibleTreeItem
      # @lastFirstVisibleTreeItem?.classList.remove('debug-item')
      # currentFirstVisibleTreeItem.classList.add('debug-item')
      @lastFirstVisibleTreeItem = currentFirstVisibleTreeItem
      currentParent = $(currentFirstVisibleTreeItem).parents('ol').first().parent().children('.header')[0]
      if currentParent isnt @lastParent
        @updateBreadcrumb(currentParent)
        @lastParent = currentParent
    # else unless currentFirstVisibleTreeItem?
    #   @lastFirstVisibleTreeItem?.classList.remove('debug-item')

    if !@attached and scrollTop > 0 and currentParent isnt @rootItem
      @show()
    else if @attached and (scrollTop is 0 or currentParent is @rootItem)
      @lastFirstVisibleTreeItem = null
      @lastParent = null
      @hide()

  updateBreadcrumb: (node) ->
    node = $(node)
    html = []
    parents = []
    parents.unshift n for n in node.parents('.directory')
    parents.shift()

    parents.forEach (node, i) ->
      cls = 'btn'
      cls += ' btn-primary' if i is parents.length - 1
      html.push "<div class='#{cls}'>#{$(node).children('.header').text()}</div>"

    @breadcrumb.html html.join('')

    if atom.config.get('tree-view-breadcrumb.scrollToLastItem')
      @scrollLeft(@element.scrollWidth)

  getItemHeight: ->
    @treeView.find('.list-item.header').first().height()

  firstVisibleTreeItem: (scrollTop) ->
    itemHeight = @getItemHeight()
    index = Math.ceil(scrollTop / itemHeight)
    self = this
    found = null
    @treeView.find('.list-item.header, .list-item.file')[index]
