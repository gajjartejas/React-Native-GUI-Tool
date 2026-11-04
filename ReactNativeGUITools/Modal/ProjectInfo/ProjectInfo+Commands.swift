import Foundation

extension ProjectInfo {
    var orderedPackageJsonScripts: [PackageJsonScript]? {
        packageJsonScripts?.sorted { lhs, rhs in
            let order = ["start", "test", "lint", "android", "ios"]
            let lhsIndex = order.firstIndex(of: lhs.name) ?? Int.max
            let rhsIndex = order.firstIndex(of: rhs.name) ?? Int.max
            return lhsIndex == rhsIndex ? lhs.name > rhs.name : lhsIndex < rhsIndex
        }
    }

    enum TerminalCommand {
        case runScript(String)
        case npmStart
        case npmInstall
        case npmStartResetCache
        case npmRestart
        case npmStop
        case npmCacheClean
        case npmCacheVerify
        case watchmanWatchDelAll
        case watchmanShutdownServer
        case watchmanWatch
        case podInstall
        case podUpdate
        case podOutdated
        case podDeintegrate
        case podEnv
        case podCacheList
        case podCacheCleanAll
        case custom(String)
    }

    func terminalCommand(_ command: TerminalCommand) -> String {
        switch command {
        case .runScript(let scriptName):
            return "cd \(path) && npm run \(scriptName)"
        case .npmStart:
            return "cd \(path) && npm start"
        case .npmInstall:
            return "cd \(path) && npm install"
        case .npmStartResetCache:
            return "cd \(path) && start -- --reset-cache"
        case .npmRestart:
            return "cd \(path) && npm restart"
        case .npmStop:
            return "cd \(path) && npm stop"
        case .npmCacheClean:
            return "cd \(path) && npm cache clean"
        case .npmCacheVerify:
            return "cd \(path) && npm cache verify"
        case .watchmanWatchDelAll:
            return "cd \(path) && watchman watch-del-all"
        case .watchmanShutdownServer:
            return "cd \(path) && watchman shutdown-server"
        case .watchmanWatch:
            return "cd \(path) && watchman watch ."
        case .podInstall:
            return "cd \(path)/ios && pod install"
        case .podUpdate:
            return "cd \(path)/ios && pod update"
        case .podOutdated:
            return "cd \(path)/ios && pod outdated"
        case .podDeintegrate:
            return "cd \(path)/ios && pod deintegrate"
        case .podEnv:
            return "cd \(path)/ios && pod env"
        case .podCacheList:
            return "cd \(path)/ios && pod cache list"
        case .podCacheCleanAll:
            return "cd \(path)/ios && pod cache clean --all"
        case .custom(let script):
            let resolved = script.replacingOccurrences(of: "$PROJECT_ROOT", with: path)
            return "cd \(path) && \(resolved)"
        }
    }
}

extension ProjectInfo {
    enum CleanupTarget {
        case cleaniOSAllFolders
        case cleaniOSBuildFolder
        case cleaniOSPodsFolder
        case cleanAndroidAllFolders
        case cleanAndroidBuildFolder
        case cleaniAndroidAppBuildFolder
        case cleanAndroidAppReleaseFolder
        case cleanAlliOSAllAndroid
        case cleanNodeModules
    }

    func cleanupPaths(for target: CleanupTarget) -> [String] {
        let relativePaths: [String]
        switch target {
        case .cleaniOSAllFolders:
            relativePaths = ["/ios/build", "/ios/Pods"]
        case .cleaniOSBuildFolder:
            relativePaths = ["/ios/build"]
        case .cleaniOSPodsFolder:
            relativePaths = ["/ios/Pods"]
        case .cleanAndroidAllFolders:
            relativePaths = ["/android/build", "/android/app/build", "/android/app/release"]
        case .cleanAndroidBuildFolder:
            relativePaths = ["/android/build"]
        case .cleaniAndroidAppBuildFolder:
            relativePaths = ["/android/app/build"]
        case .cleanAndroidAppReleaseFolder:
            relativePaths = ["/android/app/release"]
        case .cleanAlliOSAllAndroid:
            relativePaths = ["/ios/build", "/ios/Pods", "/android/build", "/android/app/build", "/android/app/release"]
        case .cleanNodeModules:
            relativePaths = ["/node_modules"]
        }
        return relativePaths.map { path + $0 }
    }
}
