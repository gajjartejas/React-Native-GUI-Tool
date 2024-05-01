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
        projectInfoCollection.searchBy(searchString)
        projectListTableView.reloadData()
    }

    func searchFieldDidEndSearching(_ sender: NSSearchField) {
        projectInfoCollection.clearSearch()
        projectListTableView.reloadData()
    }

    func controlTextDidChange(_ obj: Notification) {
        guard let searchField = obj.object as? NSSearchField else { return }
        let searchString = searchField.stringValue
        projectInfoCollection.searchBy(searchString)
        projectListTableView.reloadData()
    }
}
