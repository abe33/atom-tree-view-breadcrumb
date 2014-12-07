{$, $$} = require 'space-pen'
fs = require 'fs-plus'
path = require 'path'
temp = require('temp').track()
wrench = require 'wrench'
os = require 'os'
{WorkspaceView} = require 'atom'

waitsForFileToOpen = (causeFileToOpen) ->
  waitsFor (done) ->
    disposable = atom.workspace.onDidOpen ->
      disposable.dispose()
      done()
    causeFileToOpen()

describe "TreeViewBreadcrumb", ->
  [treeView, root, sampleJs, sampleTxt, workspaceElement, treeViewPackage] = []

  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace)
    atom.workspaceView = workspaceElement.__spacePenView
    jasmine.attachToDOM(workspaceElement)
    workspaceElement.style.height = '100px'

    waitsForPromise ->
      atom.packages.activatePackage("tree-view")

    runs ->
      treeView = $(workspaceElement.querySelector('.tree-view')).view()

      root = $(treeView.root)
      # sampleJs = treeView.find('.file:contains(tree-view-breadcrumb.js)')

      expect(treeView.root.directory.watchSubscription).toBeTruthy()

  describe "with the tree-view hidden", ->
    beforeEach ->
      atom.commands.dispatch(workspaceElement, 'tree-view:toggle')

      waitsForPromise -> atom.packages.activatePackage('tree-view-breadcrumb')

    it "does not attach the breadcrumb", ->
      expect(workspaceElement.querySelector('.tree-view-breadcrumb')).not.toExist()

    describe 'when tree-view:toggle is triggered', ->
      describe 'and the view is scrolled', ->
        beforeEach ->
          atom.commands.dispatch workspaceElement, 'tree-view:toggle'
          treeView.moveDown()
          treeView.expandDirectory()
          treeView.scrollTop(100)

        it 'attaches the breadcrumb', ->
          waitsFor -> workspaceElement.querySelector('.tree-view-breadcrumb')

  describe "when the tree view is visible", ->
    beforeEach ->
      waitsForPromise -> atom.packages.activatePackage('tree-view-breadcrumb')

    describe 'with no possible scroll', ->
      it "does not attach the breadcrumb", ->
        expect(workspaceElement.querySelector('.tree-view-breadcrumb')).not.toExist()

    describe 'when the tree view is scrolled', ->
      beforeEach ->
        treeView.moveDown()
        treeView.expandDirectory()
        treeView.scrollTop(100)

      it 'attaches the breadcrumb', ->
        waitsFor -> workspaceElement.querySelector('.tree-view-breadcrumb')

      describe 'then scrolling back up', ->
        beforeEach ->
          treeView.scrollTop(0)

        it 'detaches the breadcrumb', ->
          expect(workspaceElement.querySelector('.tree-view-breadcrumb')).not.toExist()

  describe "when the project has no path", ->
    beforeEach ->
      atom.project.setPaths([])
      atom.packages.deactivatePackage("tree-view")

      waitsForPromise -> atom.packages.activatePackage("tree-view")
      waitsForPromise -> atom.packages.activatePackage('tree-view-breadcrumb')

    describe 'and the tree-view is toggled', ->
      beforeEach ->
        atom.commands.dispatch workspaceElement, 'tree-view:toggle'

      it 'does not add the breadcrumb', ->
        expect(workspaceElement.querySelector('.tree-view-breadcrumb')).not.toExist()
