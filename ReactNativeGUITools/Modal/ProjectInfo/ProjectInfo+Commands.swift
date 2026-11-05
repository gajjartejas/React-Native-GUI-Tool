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
        case customFile(String)
    }

    func terminalCommand(_ command: TerminalCommand) -> String {
        switch command {
        case .runScript(let scriptName):
            return "cd \(shellQuoted(path)) && npm run \(shellQuoted(scriptName))"
        case .npmStart:
            return "cd \(shellQuoted(path)) && npm start"
        case .npmInstall:
            return "cd \(shellQuoted(path)) && npm install"
        case .npmStartResetCache:
            return "cd \(shellQuoted(path)) && start -- --reset-cache"
        case .npmRestart:
            return "cd \(shellQuoted(path)) && npm restart"
        case .npmStop:
            return "cd \(shellQuoted(path)) && npm stop"
        case .npmCacheClean:
            return "cd \(shellQuoted(path)) && npm cache clean"
        case .npmCacheVerify:
            return "cd \(shellQuoted(path)) && npm cache verify"
        case .watchmanWatchDelAll:
            return "cd \(shellQuoted(path)) && watchman watch-del-all"
        case .watchmanShutdownServer:
            return "cd \(shellQuoted(path)) && watchman shutdown-server"
        case .watchmanWatch:
            return "cd \(shellQuoted(path)) && watchman watch ."
        case .podInstall:
            return "cd \(shellQuoted(URL(fileURLWithPath: path).appendingPathComponent("ios").path)) && pod install"
        case .podUpdate:
            return "cd \(shellQuoted(URL(fileURLWithPath: path).appendingPathComponent("ios").path)) && pod update"
        case .podOutdated:
            return "cd \(shellQuoted(URL(fileURLWithPath: path).appendingPathComponent("ios").path)) && pod outdated"
        case .podDeintegrate:
            return "cd \(shellQuoted(URL(fileURLWithPath: path).appendingPathComponent("ios").path)) && pod deintegrate"
        case .podEnv:
            return "cd \(shellQuoted(URL(fileURLWithPath: path).appendingPathComponent("ios").path)) && pod env"
        case .podCacheList:
            return "cd \(shellQuoted(URL(fileURLWithPath: path).appendingPathComponent("ios").path)) && pod cache list"
        case .podCacheCleanAll:
            return "cd \(shellQuoted(URL(fileURLWithPath: path).appendingPathComponent("ios").path)) && pod cache clean --all"
        case .custom(let script):
            return "export PROJECT_ROOT=\(shellQuoted(path)); cd \(shellQuoted(path)) && \(script)"
        case .customFile(let script):
            let resolved = script.replacingOccurrences(of: "$PROJECT_ROOT", with: path)
            return "cd \(shellQuoted(path)) && \(shellQuoted(resolved))"
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
        case cleanAndroidAppBuildFolder
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
        case .cleanAndroidAppBuildFolder:
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

/// Quote shell data while leaving deliberately authored commands intact.
func shellQuoted(_ value: String) -> String {
    "'" + value.replacingOccurrences(of: "'", with: "'\\''") + "'"
}
