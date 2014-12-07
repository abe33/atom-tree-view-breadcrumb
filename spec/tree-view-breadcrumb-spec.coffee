{$, $$} = require 'space-pen'

waitsForFileToOpen = (causeFileToOpen) ->
  waitsFor (done) ->
    disposable = atom.workspace.onDidOpen ->
      disposable.dispose()
      done()
    causeFileToOpen()

describe "TreeViewBreadcrumb", ->
  [treeView, root, sampleJs, sampleTxt, workspaceElement, treeViewPackage, breadcrumb] = []

  beforeEach ->
    atom.config.set 'tree-view-breadcrumb.keepBreadcrumbVisible', false

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

        describe 'clicking on the breadcrumb buttons', ->
          beforeEach ->
            waitsFor ->
              breadcrumb =  workspaceElement.querySelector('.tree-view-breadcrumb')

            runs ->
              $(breadcrumb).find('.btn:first-child').click()

          it 'scrolls back the tree-view to the top', ->
            expect(treeView.scrollTop()).toBeLessThan(100)

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

  describe 'when keep breadcrumb visible option is enabled', ->
    describe 'before the view creation', ->
      beforeEach ->
        atom.config.set 'tree-view-breadcrumb.keepBreadcrumbVisible', true

        waitsForPromise -> atom.packages.activatePackage('tree-view-breadcrumb')

      it 'attaches the breadcrumb even without a scroll', ->
        waitsFor -> workspaceElement.querySelector('.tree-view-breadcrumb')

      describe 'scrolling back and forth', ->
        beforeEach ->
          treeView.moveDown()
          treeView.expandDirectory()
          treeView.scrollTop(100)
          treeView.scrollTop(0)

        it 'leaves the breadcrumb even when there is no more content', ->
          waitsFor -> workspaceElement.querySelector('.tree-view-breadcrumb')

    describe 'after the view creation', ->
      beforeEach ->
        waitsForPromise -> atom.packages.activatePackage('tree-view-breadcrumb')

        runs ->
          atom.config.set 'tree-view-breadcrumb.keepBreadcrumbVisible', true

      it 'attaches the breadcrumb even without a scroll', ->
        waitsFor -> workspaceElement.querySelector('.tree-view-breadcrumb')

      # FIXME Test failing on travis and not locally, why?
      xdescribe 'then disabling it', ->
        beforeEach ->
          atom.config.set 'tree-view-breadcrumb.keepBreadcrumbVisible', false

        it 'detaches the breadcrumb even without a scroll', ->
          waitsFor -> not workspaceElement.querySelector('.tree-view-breadcrumb')
