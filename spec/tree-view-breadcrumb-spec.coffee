{$, $$} = require 'space-pen'

{click, scroll} = require './helpers/events'

fakeEvent =
  stopImmediatePropagation: ->
  stopPropagation: ->
  preventDefault: ->

describe "TreeViewBreadcrumb", ->
  [treeView, root, sampleJs, sampleTxt, workspaceElement, treeViewPackage, breadcrumb, breadcrumbElement, nextAnimationFrame] = []

  beforeEach ->
    spyOn(window, "setInterval").andCallFake window.fakeSetInterval
    spyOn(window, "clearInterval").andCallFake window.fakeClearInterval

    noAnimationFrame = -> throw new Error('No animation frame requested')
    nextAnimationFrame = noAnimationFrame

    requestAnimationFrameSafe = window.requestAnimationFrame
    spyOn(window, 'requestAnimationFrame').andCallFake (fn) ->
      nextAnimationFrame = ->
        nextAnimationFrame = noAnimationFrame
        fn()

    atom.config.set 'tree-view-breadcrumb.keepBreadcrumbVisible', false

    workspaceElement = atom.views.getView(atom.workspace)
    jasmine.attachToDOM(workspaceElement)
    workspaceElement.style.height = '100px'

    waitsForPromise -> atom.packages.activatePackage("tree-view").then (pkg) ->
      treeView = pkg.mainModule.treeView

    runs ->
      root = $(treeView.roots[0])

      expect(treeView.roots[0].directory.watchSubscription).toBeTruthy()

    waitsForPromise ->
      atom.packages.activatePackage('tree-view-breadcrumb')
      .then (pkg) ->
        breadcrumb = pkg.mainModule

    waitsFor -> nextAnimationFrame isnt noAnimationFrame

    runs -> nextAnimationFrame()

    waitsFor -> breadcrumbElement = breadcrumb.breadcrumbElement

  describe "when the tree-view is hidden", ->
    it "does not attach the breadcrumb", ->
      expect(workspaceElement.querySelector('tree-view-breadcrumb')).not.toExist()

    describe 'and the view is scrolled', ->
      beforeEach ->
        treeView.moveDown(fakeEvent)
        treeView.expandDirectory()
        treeView.scrollTop(100)
        scroll(treeView[0])

        waitsFor -> breadcrumbElement.frameRequested
        runs -> nextAnimationFrame()

      it 'attaches the breadcrumb', ->
        expect(workspaceElement.querySelector('tree-view-breadcrumb')).toExist()

      describe 'clicking on the breadcrumb buttons', ->
        beforeEach ->
          click(breadcrumbElement.querySelector('.btn:first-child'))

        it 'scrolls back the tree-view to the top', ->
          expect(treeView.scrollTop()).toBeLessThan(100)

  describe "when the tree view is visible", ->
    describe 'with no possible scroll', ->
      it "does not attach the breadcrumb", ->
        expect(workspaceElement.querySelector('tree-view-breadcrumb')).not.toExist()

    describe 'when the tree view is scrolled', ->
      beforeEach ->
        treeView.moveDown(fakeEvent)
        treeView.expandDirectory()
        treeView.scrollTop(100)
        scroll(treeView[0])

        waitsFor -> breadcrumbElement.frameRequested
        runs -> nextAnimationFrame()

      it 'attaches the breadcrumb', ->
        expect(workspaceElement.querySelector('tree-view-breadcrumb')).toExist()
        expect(breadcrumbElement.classList.contains('visible')).toBeTruthy()

      describe 'then scrolling back up', ->
        beforeEach ->
          treeView.scrollTop(0)

          waitsFor -> breadcrumbElement.frameRequested
          runs -> nextAnimationFrame()

        it 'hides the breadcrumb', ->
          expect(breadcrumbElement.classList.contains('visible')).toBeFalsy()

          advanceClock(350)
          expect(workspaceElement.querySelector('tree-view-breadcrumb')).not.toExist()

    xdescribe 'when the tree view is toggled', ->
      beforeEach ->
        atom.commands.dispatch(workspaceElement, 'tree-view:toggle')
        nextAnimationFrame()

      it 'hides the breadcrumb', ->
        expect(breadcrumbElement.classList.contains('visible')).toBeFalsy()
        expect(workspaceElement.querySelector('tree-view-breadcrumb')).not.toExist()

      describe 'several times', ->
        beforeEach ->
          atom.commands.dispatch(workspaceElement, 'tree-view:toggle')
          nextAnimationFrame()

          waitsFor -> workspaceElement.querySelector('tree-view-breadcrumb')

        it 'attaches the breadcrumb again', ->
          expect(workspaceElement.querySelector('tree-view-breadcrumb')).toExist()
          expect(breadcrumbElement.classList.contains('visible')).toBeTruthy()

  describe "when the project has no path", ->
    beforeEach ->
      atom.project.setPaths([])
      atom.packages.deactivatePackage("tree-view")
      atom.packages.deactivatePackage("tree-view-breadcrumb")

      waitsForPromise -> atom.packages.activatePackage("tree-view")
      waitsForPromise -> atom.packages.activatePackage('tree-view-breadcrumb')

    it 'does not add the breadcrumb', ->
      expect(workspaceElement.querySelector('tree-view-breadcrumb')).not.toExist()

  describe 'when keep breadcrumb visible option is enabled', ->
    describe 'before the view creation', ->
      beforeEach ->
        atom.config.set 'tree-view-breadcrumb.keepBreadcrumbVisible', true

      it 'attaches the breadcrumb even without a scroll', ->
        waitsFor -> workspaceElement.querySelector('tree-view-breadcrumb')
        runs ->
          expect(workspaceElement.querySelector('tree-view-breadcrumb')).toExist()

      describe 'scrolling back and forth', ->
        beforeEach ->
          treeView.moveDown(fakeEvent)
          treeView.expandDirectory()
          treeView.scrollTop(100)
          treeView.scrollTop(0)
          scroll(treeView[0])

          waitsFor -> breadcrumbElement.frameRequested
          runs -> nextAnimationFrame()

        it 'leaves the breadcrumb even when there is no more content', ->
          waitsFor -> workspaceElement.querySelector('tree-view-breadcrumb')

    describe 'after the view creation', ->
      beforeEach ->
        atom.config.set 'tree-view-breadcrumb.keepBreadcrumbVisible', true

      it 'attaches the breadcrumb even without a scroll', ->
        expect(workspaceElement.querySelector('tree-view-breadcrumb')).toExist()

      describe 'then disabling it', ->
        beforeEach ->
          treeView.scrollTop(0)
          scroll(treeView[0])

          waitsFor -> breadcrumbElement.frameRequested
          runs ->
            nextAnimationFrame()
            atom.config.set 'tree-view-breadcrumb.keepBreadcrumbVisible', false

        it 'detaches the breadcrumb even without a scroll', ->
          advanceClock(300)
          expect(workspaceElement.querySelector('tree-view-breadcrumb')).not.toExist()

  describe 'when display project root option is enabled', ->
    beforeEach ->
      atom.config.set 'tree-view-breadcrumb.displayProjectRoot', true
      treeView.moveDown(fakeEvent)
      treeView.expandDirectory()
      treeView.scrollTop(100)
      scroll(treeView[0])

      waitsFor -> breadcrumbElement.frameRequested
      runs -> nextAnimationFrame()

    it 'adds a button for the root in the breadcrumb', ->
      breadcrumb = workspaceElement.querySelector('tree-view-breadcrumb')
      expect(breadcrumb.querySelector('.btn.root')).toExist()

  describe 'when display project root name option is enabled', ->
    beforeEach ->
      atom.config.set 'tree-view-breadcrumb.displayProjectRoot', true
      atom.config.set 'tree-view-breadcrumb.displayProjectRootName', true
      treeView.moveDown(fakeEvent)
      treeView.expandDirectory()
      treeView.scrollTop(100)
      scroll(treeView[0])

      waitsFor -> breadcrumbElement.frameRequested
      runs -> nextAnimationFrame()

    it 'adds a button for the root in the breadcrumb', ->
      breadcrumb = workspaceElement.querySelector('tree-view-breadcrumb')
      expect(breadcrumb.querySelector('.btn.root')).toExist()
      expect(breadcrumb.querySelector('.btn.root').textContent).toEqual('fixtures')
