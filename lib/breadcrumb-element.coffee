{CompositeDisposable, Disposable} = require 'event-kit'
{SpacePenDSL, EventsDelegation} = require 'atom-utils'

class BreadcrumbElement extends HTMLElement
  SpacePenDSL.includeInto(this)
  EventsDelegation.includeInto(this)

  @content: ->
    path = atom.project?.getPaths()[0]
    path = path.split('/').pop() if path?

    @tag 'atom-panel', class: 'tree-view-breadcrumb tool-panel', =>
      @div outlet: 'breadcrumb', class: 'btn-group', =>
        @div class: 'btn', path

  lastFirstVisibleTreeItem: null
  lastParent: null
  displayProjectRoot: false

  initialize: (treeViewPackage) ->
    @subscriptions = new CompositeDisposable

    @subscriptions.add @subscribeTo @breadcrumb, '.btn',
      'click': (e) =>
        target = e.target.dataset.target
        item = @treeView.element.querySelector("[data-path='#{target}']")
        @scrollToItem(@treeView.element.querySelector("[data-path='#{target}']"))

    @subscribeToTreeView(treeViewPackage.treeView) if treeViewPackage.treeView?

    @subscriptions.add atom.commands.add 'atom-workspace', 'tree-view:toggle', =>
      if treeViewPackage.treeView?
        @subscribeToTreeView(treeView)

    @subscriptions.add atom.config.observe 'tree-view-breadcrumb.keepBreadcrumbVisible', (visible) =>
      if visible and not @attached
        @show()
      else if not visible and @attached and @breadcrumb.is(':empty')
        @hide()

    @subscriptions.add atom.config.observe 'tree-view-breadcrumb.displayProjectRoot', (@displayProjectRoot) =>
      @updateBreadcrumb(@lastParent)

  subscribeToTreeView: (@treeView) ->
    workspaceElement = atom.views.getView(atom.workspace)
    @treeViewResizer = workspaceElement.querySelector('.tree-view-resizer')
    @treeViewScroller = workspaceElement.querySelector('.tree-view-scroller')

    @treeSubscription = @subscribeTo @treeViewScroller,
      'scroll': (e) => @treeViewScrolled(e)

    @show() if atom.config.get('tree-view-breadcrumb.keepBreadcrumbVisible')

    @treeViewScrolled()

  unsubscribeFromTreeView: ->
    @treeSubscription.dispose()
    @treeViewResizer = null
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
    @treeViewResizer.prepend(this)
    @attached = true

  detach: ->
    super
    @attached = false

  destroy: ->
    @subscriptions.dispose()
    @detach()

  updateBreadcrumb: (node) ->
    html = []
    parents = []
    parents.unshift n for n in node.parents('.directory')
    parents.shift()

    if @displayProjectRoot
      root = @treeView.find('.header .name').first()
      html.push "<div class='btn root' data-target='#{root.data('path')}'></div>"

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
    scrollerOffset = @treeViewScroller.offset()
    offset = item.offset()
    if offset?
      newScroll = (offset.top - scrollerOffset.top) + oldScroll
      @treeViewScroller.scrollTop(newScroll)

  treeViewScrolled: => @requestUpdate()

  requestUpdate: ->
    return if @frameRequested

    @frameRequested = true

    requestAnimationFrame =>
      @update()
      @frameRequested = false

  update: ->
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
    else if @attached and (scrollTop is 0 or @breadcrumb.is(':empty')) and not atom.config.get('tree-view-breadcrumb.keepBreadcrumbVisible')
      @lastFirstVisibleTreeItem = null
      @lastParent = null
      @hide()

  getItemHeight: ->
    @treeView.find('.list-item.header').first().height()

  firstVisibleTreeItem: (scrollTop) ->
    itemHeight = @getItemHeight()
    index = Math.floor(scrollTop / itemHeight)
    @treeViewScroller.find('.list-item.header, .list-item.file')[index]

  parentHeader: (node) ->
    $(node).parents('ol').first().parent().children('.header')[0]


module.exports = BreadcrumbElement = document.registerElement 'tree-view-breadcrumb', prototype: BreadcrumbElement.prototype
