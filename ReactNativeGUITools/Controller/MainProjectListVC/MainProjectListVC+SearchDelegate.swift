//
//  MainProjectListVC+SearchDelegate.swift
//  ReactNativeGUITools
//
//  Created by Tejas on 01/05/24.
//

import Cocoa

extension MainProjectListVC: NSSearchFieldDelegate {
    func searchFieldDidStartSearching(_ sender: NSSearchField) {
        let searchString = sender.stringValue
        ProjectInfoCollection.shared.searchBy(searchString)
        projectListTableView.reloadData()
    }

    func searchFieldDidEndSearching(_ sender: NSSearchField) {
        ProjectInfoCollection.shared.clearSearch()
        projectListTableView.reloadData()
    }

    func controlTextDidChange(_ obj: Notification) {
        guard let searchField = obj.object as? NSSearchField else { return }
        let searchString = searchField.stringValue
        ProjectInfoCollection.shared.searchBy(searchString)
        projectListTableView.reloadData()
    }
}
