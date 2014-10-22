{View} = require 'atom'
$ = View.__super__.constructor

requirePackages = (packages...) ->
  new Promise (resolve, reject) ->
    required = []
    promises = []
    failures = []
    remains = packages.length

    solved = ->
      remains--
      return unless remains is 0
      return reject(failures) if failures.length > 0
      resolve(required)

    packages.forEach (pkg, i) ->
      promises.push(atom.packages.activatePackage(pkg)
      .then (activatedPackage) ->
        required[i] = activatedPackage.mainModule
        solved()
      .fail (reason) ->
        failures[i] = reason
        solved()
      )

module.exports =
class BreadcrumbView extends View
  @content: ->
    @div class: 'tree-view-breadcrumb tool-panel', =>
      @div outlet: 'breadcrumb', class: 'btn-group', =>
        @div class: 'btn', atom.project.getPath().split('/').pop()

  lastFirstVisibleTreeItem: null
  lastParent: null

  initialize: (state) ->
    requirePackages('tree-view').then ([@treeView]) ->
      @treeViewScroller = @treeView.find('.tree-view-scroller')
      @treeViewScroller.on 'scroll', @treeViewScrolled
      @treeViewScrolled()
      @breadcrumb.on 'click', '.btn', (e) =>
        target = $(e.target).data('target')
        item = @treeView.find("[data-path='#{target}']")
        @scrollToItem(@treeView.find("[data-path='#{target}']"))

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

  updateBreadcrumb: (node) ->
    node = $(node)
    html = []
    parents = []
    parents.unshift n for n in node.parents('.directory')
    parents.shift()

    path = []

    parents.forEach (node, i) ->
      label = $(node).children('.header').text()
      path.push label
      cls = 'btn'
      cls += ' btn-primary' if i is parents.length - 1

      html.push """
        <div class='#{cls}' data-target='#{path.join('/')}'>
          #{label}
        </div>
      """

    @breadcrumb.html html.join('')

    if atom.config.get('tree-view-breadcrumb.scrollToLastItem')
      @scrollLeft(@element.scrollWidth)

  scrollToItem: (item) ->
    oldScroll = @treeView.scrollTop()
    newScroll = item.offset().top + oldScroll - @breadcrumb.height()
    console.log newScroll
    @treeView.scrollTop(newScroll)

  treeViewScrolled: =>
    scrollTop = @treeView.scrollTop()

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
