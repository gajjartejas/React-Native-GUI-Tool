//
//  CustomActionsVC+DataSource.swift
//  ReactNativeGUITools
//
//  Created by Tejas on 03/07/24.
//

import Cocoa

extension CustomActionsVC: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return projectInfo?.customMenuScripts?.count ?? 0
    }
}
