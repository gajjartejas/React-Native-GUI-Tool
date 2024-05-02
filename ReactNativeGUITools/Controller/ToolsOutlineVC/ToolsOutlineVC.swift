//
//  ToolsOutlineVC.swift
//  ReactNativeGUITools
//
//  Created by Tejas on 22/03/24.
//

import Cocoa

class ToolsOutlineVC: NSViewController {
    // MARK: - Properties

    @IBOutlet weak var contentOutlet: NSWindow!

    @IBOutlet var outlineView: NSOutlineView!
    var outlineNodes = [MenuNode]()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        initializeOutlineView()
    }

    override func viewWillAppear() {
        super.viewWillAppear()
    }

    // MARK: - Actions

    @IBAction func doubleClickedItem(_ sender: NSOutlineView) {
        guard let node = sender.item(atRow: sender.clickedRow) as? MenuNode,
              node.hasChildren else {
            return
        }

        if sender.isItemExpanded(node) {
            sender.animator().collapseItem(node)
        } else {
            sender.animator().expandItem(node)
        }
    }

    // MARK: - Helpers

    private func initializeOutlineView() {

        outlineView.register(ToolsOutlineCellView.nib(inBundle: .main),
                             forIdentifier: NSUserInterfaceItemIdentifier(rawValue: String(describing: ToolsOutlineCellView.self)))
        outlineView.delegate = self
        outlineView.dataSource = self
        outlineView.autosaveExpandedItems = true

        outlineView.selectionHighlightStyle = .regular
        outlineView.floatsGroupRows = false

        outlineNodes.append(contentsOf: Self.getDefaultOutlineMenu())
        outlineView.reloadData()

        // Expand rows
        outlineView.expandItem(nil, expandChildren: true)

        // Select first index
        let indexSet = IndexSet(integer: 1)
        outlineView.selectRowIndexes(indexSet, byExtendingSelection: false)
    }
}
