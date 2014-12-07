{$, View} = require 'space-pen'

module.exports =
class BreadcrumbView extends View
  @content: ->
    path = atom.project?.getPath()
    path = path.split('/').pop() if path?

    @div class: 'tree-view-breadcrumb tool-panel', =>
      @div outlet: 'breadcrumb', class: 'btn-group', =>
        @div class: 'btn', path

  lastFirstVisibleTreeItem: null
  lastParent: null

  initialize: (treeViewPackage) ->
    @breadcrumb.on 'click', '.btn', (e) =>
      target = $(e.target).data('target')
      item = @$treeView.find("[data-path='#{target}']")
      @scrollToItem(@$treeView.find("[data-path='#{target}']"))

    workspaceElement = atom.views.getView(atom.workspace)
    if treeViewPackage.treeView
      @subscribeToTreeView(treeViewPackage.treeView)

    atom.commands.add workspaceElement, 'tree-view:toggle', =>
      treeView = workspaceElement.querySelector('.tree-view')
      if treeView?
        @subscribeToTreeView($(treeView).view())
      else
        @unsubscribeFromTreeView()

  subscribeToTreeView: (@treeView) ->
    workspaceElement = atom.views.getView(atom.workspace)
    @treeViewScroller = $(workspaceElement.querySelector('.tree-view-scroller'))
    @treeViewScroller.on 'scroll', @treeViewScrolled
    @treeViewScrolled()

  unsubscribeFromTreeView: ->
    @treeViewScroller?.off()
    @treeViewScroller = null
    @treeView = null

  show: ->
    @attach()
    @treeViewScroller.addClass('with-breadcrumb')
    @addClass('visible')

  hide: ->
    @removeClass('visible')
    @treeViewScroller.removeClass('with-breadcrumb')
    setTimeout((=> @detach()), 300)

  attach: ->
    @treeViewScroller.prepend(this)
    @attached = true

  detach: ->
    super
    @attached = false

  destroy: ->
    @detach()

  updateBreadcrumb: (node) ->
    node = $(node)
    html = []
    parents = []
    parents.unshift n for n in node.parents('.directory')
    parents.shift()

    parents.forEach (node, i) ->
      name = $(node).find('> .header > .name')
      label = name.text()

      cls = 'btn'
      cls += ' btn-primary' if i is parents.length - 1

      html.push """
        <div class='#{cls}' data-target='#{name[0].dataset.path}'>
          #{label}
        </div>
      """

    @breadcrumb.html html.join('')

    if atom.config.get('tree-view-breadcrumb.scrollToLastItem')
      @scrollLeft(@element.scrollWidth)

  scrollToItem: (item) ->
    oldScroll = @treeViewScroller.scrollTop()
    offset = item.offset()
    if offset?
      newScroll = offset.top + oldScroll - @breadcrumb.height()
      @treeViewScroller.scrollTop(newScroll - @treeViewScroller.offset().top)

  treeViewScrolled: =>
    scrollTop = @treeViewScroller.scrollTop()

    currentFirstVisibleTreeItem = @firstVisibleTreeItem(scrollTop)
    currentParent = null
    if currentFirstVisibleTreeItem? and currentFirstVisibleTreeItem isnt @lastFirstVisibleTreeItem
      @lastFirstVisibleTreeItem = currentFirstVisibleTreeItem
      currentParent = @parentHeader(currentFirstVisibleTreeItem)

      if currentParent isnt @lastParent
        @updateBreadcrumb(currentParent)
        @lastParent = currentParent

    if !@attached and scrollTop > 0 and !@breadcrumb.is(':empty')
      @show()
    else if @attached and (scrollTop is 0 or @breadcrumb.is(':empty'))
      @lastFirstVisibleTreeItem = null
      @lastParent = null
      @hide()

  getItemHeight: ->
    @treeView.find('.list-item.header').first().height()

  firstVisibleTreeItem: (scrollTop) ->
    itemHeight = @getItemHeight()
    index = Math.ceil(scrollTop / itemHeight)
    self = this
    found = null
    @treeView.find('.list-item.header, .list-item.file')[index]

  parentHeader: (node) ->
    $(node).parents('ol').first().parent().children('.header')[0]
