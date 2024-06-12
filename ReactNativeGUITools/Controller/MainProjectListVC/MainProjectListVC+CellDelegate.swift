//
//  MainProjectListVC+Delegate.swift
//  ReactNativeGUITools
//
//  Created by Tejas on 23/04/24.
//

import Cocoa

extension MainProjectListVC: ProjectListCellViewDelegate {
    func textEdited(text: String, atIndex row: Int) {
        let projectInfo = ProjectInfoManager.shared.projectInfos[row]
        let newName = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if !newName.isEmpty {
            projectInfo.name = newName
            ProjectInfoManager.shared.update(with: projectInfo)
        }
    }

    func showInFolder(atIndex index: Int) {
        let projectInfo = ProjectInfoManager.shared.projectInfos[index]
        NSWorkspace.shared.selectFile(projectInfo.path, inFileViewerRootedAtPath: "")
    }
}
