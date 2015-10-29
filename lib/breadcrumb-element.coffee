{CompositeDisposable, Disposable} = require 'event-kit'
{AncestorsMethods, SpacePenDSL, EventsDelegation} = require 'atom-utils'

class BreadcrumbElement extends HTMLElement
  EventsDelegation.includeInto(this)
  SpacePenDSL.includeInto(this)

  @content: ->
    path = atom.project?.getPaths()[0]
    path = path.split('/').pop() if path?

    @tag 'atom-panel', class: 'tree-view-breadcrumb tool-panel', =>
      @div outlet: 'breadcrumb', class: 'btn-group', =>
        @div class: 'btn', path

  lastFirstVisibleTreeItem: null
  lastParent: null
  displayProjectRoot: false

  initialize: (@treeViewPackage) ->
    @subscriptions = new CompositeDisposable

    @subscriptions.add @subscribeTo @breadcrumb, '.btn',
      'click': (e) =>
        target = e.target.dataset.target
        item = @treeView.element.querySelector("[data-path='#{target}']")
        @scrollToItem(@treeView.element.querySelector("[data-path='#{target}']"))

    # @subscriptions.add atom.commands.add 'atom-workspace', 'tree-view:toggle', =>
    #   requestAnimationFrame =>
    #     if @hasTreeView()
    #       @subscribeToTreeView(@treeViewPackage.treeView)
    #     else
    #       @unsubscribeFromTreeView()

    @subscriptions.add atom.config.observe 'tree-view-breadcrumb.pathStyle', (pathStyle) =>
      @classList.toggle('path-style', pathStyle)

    @subscriptions.add atom.config.observe 'tree-view-breadcrumb.keepBreadcrumbVisible', (visible) =>
      if visible and not @attached and @treeViewResizer?
        @show()
      else if not visible and @attached and @breadcrumb.querySelectorAll('.btn:not(.root)').length is 0
        @hide()

    @subscriptions.add atom.config.observe 'tree-view-breadcrumb.displayProjectRoot', (@displayProjectRoot) =>
      @updateBreadcrumb(@lastParent)

    @subscriptions.add atom.config.observe 'tree-view-breadcrumb.displayProjectRootName', (@displayProjectRootName) =>
      @updateBreadcrumb(@lastParent)

    @subscriptions.add atom.config.observe 'tree-view-breadcrumb.scrollbarStyle', (style) =>
      @classList.remove('system')
      @classList.remove('thin')
      @classList.add(style)

    @subscriptions.add atom.config.observe 'tree-view-breadcrumb.breadcrumbPosition', (position) =>
      @classList.toggle('bottom', position is 'bottom')

    requestAnimationFrame =>
      @subscribeToTreeView(@treeViewPackage.treeView) if @hasTreeView()

  hasTreeView: ->
    @treeViewPackage.treeView? and document.body.querySelector('.tree-view-resizer')?

  subscribeToTreeView: (@treeView) ->
    return if @treeSubscription?
    workspaceElement = atom.views.getView(atom.workspace)
    @treeViewResizer = workspaceElement.querySelector('.tree-view-resizer')
    @treeViewScroller = workspaceElement.querySelector('.tree-view-scroller')

    @treeSubscription = @subscribeTo @treeViewScroller,
      'scroll': (e) => @treeViewScrolled(e)

    @show() if atom.config.get('tree-view-breadcrumb.keepBreadcrumbVisible')

    @treeViewScrolled()

  unsubscribeFromTreeView: ->
    return unless @treeSubscription?
    @treeSubscription.dispose()
    @treeSubscription = null
    @treeViewResizer = null
    @treeViewScroller = null
    @treeView = null

  show: ->
    @attach()
    @classList.add('visible')

  hide: ->
    @classList.remove('visible')
    setTimeout((=> @detach()), 300)

  attach: ->
    return unless @treeViewResizer?
    @treeViewResizer.insertBefore(this, @treeViewResizer.firstChild)
    @attached = true
    if selectedEntry = @treeViewPackage.treeView.selectedEntry()
      @treeViewPackage.treeView.scrollToEntry(selectedEntry)

  detach: ->
    @treeViewResizer.removeChild(this) if @parentNode? and @parentNode is @treeViewResizer
    @attached = false

  destroy: ->
    @subscriptions.dispose()
    @detach()

  updateBreadcrumb: (node) ->
    return unless node?

    html = []
    parents = []
    parents.unshift n for n in AncestorsMethods.parents(node, '.directory')
    projectRoot = parents.shift()

    if @displayProjectRoot
      root = projectRoot.querySelector('.header .name')
      name = if @displayProjectRootName
        "<span>#{root.textContent}</span>"
      else
        ''
      html.push "<div class='btn root' data-target='#{root.getAttribute('data-path')}'>#{name}</div>"

    parents.forEach (node, i) ->
      name = node.querySelector('.header > .name')
      label = name.textContent

      cls = 'btn'
      cls += ' btn-primary' if i is parents.length - 1

      html.push """
        <div class='#{cls}' data-target='#{name.dataset.path}'>
          #{label}
        </div>
      """

    @breadcrumb.innerHTML = html.join('')

    if atom.config.get('tree-view-breadcrumb.scrollToLastItem')
      @scrollLeft = @scrollWidth

  scrollToItem: (item) ->
    return unless item?
    oldScroll = @treeViewScroller.scrollTop
    scrollerOffset = @treeViewScroller.getBoundingClientRect()
    offset = item.getBoundingClientRect()
    if offset?
      newScroll = (offset.top - scrollerOffset.top) + oldScroll
      @treeViewScroller.scrollTop = newScroll

  treeViewScrolled: => @requestUpdate()

  requestUpdate: ->
    return if @frameRequested

    @frameRequested = true

    requestAnimationFrame =>
      @update()
      @frameRequested = false

  update: ->
    scrollTop = @treeViewScroller.scrollTop

    currentFirstVisibleTreeItem = @firstVisibleTreeItem(scrollTop)
    currentParent = null
    if currentFirstVisibleTreeItem? and currentFirstVisibleTreeItem isnt @lastFirstVisibleTreeItem
      @lastFirstVisibleTreeItem = currentFirstVisibleTreeItem
      currentParent = @parentHeader(currentFirstVisibleTreeItem)
      if currentParent isnt @lastParent
        @updateBreadcrumb(currentParent)
        @lastParent = currentParent

    if !@attached and scrollTop > 0 and !@breadcrumb.matches(':empty')
      @show()
    else if @attached and (scrollTop is 0 or @breadcrumb.matches(':empty')) and not atom.config.get('tree-view-breadcrumb.keepBreadcrumbVisible')
      @lastFirstVisibleTreeItem = null
      @lastParent = null
      @hide()

  getItemHeight: ->
    @treeView.find('.list-item.header').last().height()

  firstVisibleTreeItem: (scrollTop) ->
    itemHeight = @getItemHeight()
    index = Math.floor(scrollTop / itemHeight)
    @treeViewScroller.querySelectorAll('.list-item.header, .list-item.file')[index]

  parentHeader: (node) ->
    AncestorsMethods.parents(node, 'ol')[0].parentNode.querySelector('.header')

module.exports = BreadcrumbElement = document.registerElement 'tree-view-breadcrumb', prototype: BreadcrumbElement.prototype
