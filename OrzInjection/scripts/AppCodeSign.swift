import Foundation

extension AppCodeSign {
    /// 重签名主流程
    static func main() {
        replaceApp()
        removeExtensionAndWatchApp()
        modifyProductAppInfoPlist()
        injectDylibAndFramework()
        codeSignModifiedApp()
        distributeApp()
    }
}

/// 编译脚本并运行命令如下
///
/// ```
/// $ xcrun -sdk macosx swiftc -parse-as-library AppCodeSign.swift -o AppCodeSign
/// $ ./AppCodeSign
/// ```
@main
struct AppCodeSign {
    
    /// 环境变量
    static private let env = ProcessInfo.processInfo.environment
    
    /// 工程源文件所在目录
    static private let srcRootDir = env["SRCROOT"]!
    
    /// 三方APP砸壳后的ipa包所在目录
    static private let assetsDir = "\(srcRootDir)/APP-decrypted"
    
    /// App的BundleID
    static private let productBundleId = env["PRODUCT_BUNDLE_IDENTIFIER"]!
    
    /// 构建产物目录
    static private let buildProductDir = env["BUILT_PRODUCTS_DIR"]!
    
    /// 临时目录，用来暂时存放中间产物
    static private var tempDir = { () -> String in
        let path = "\(srcRootDir)/Temp"
        makeEmptyDir(path)
        return path
    }()
    
    /// 工程产物app目录
    static private var productAppDir = { () -> String in
        let path = "\(buildProductDir)/\(env["TARGET_NAME"]!).app"
        makeEmptyDir(path)
        return path
    }()
    
    static private let productPluginDir = "\(productAppDir)/PlugIns"
    
    static private let productWatchAppDir = "\(productAppDir)/Watch"
    
    static private var productExtensionDirs = { () -> [String]? in
        
        guard let names = try? FileManager.default.contentsOfDirectory(atPath:productAppDir) else {
            return nil
        }
        
        let reg = try! NSRegularExpression(pattern: "com.*", options: .caseInsensitive)
        return names.filter { name in
            let isMatch = reg.matches(in: name, options: .anchored, range: NSRange(location: 0, length: name.count)).count != 0
            let path = "\(productAppDir)/\(name)"
            return isMatch && path.isDirectory()
        }.map { file in
            return "\(productAppDir)/\(file)"
        }
    }()
    
    /// InfoPlist路径
    static private let productInfoPlistPath = "\(productAppDir)/Info.plist"
    
    
    /// 代码签名实体
    static private let productExpandedCodeSignIdentity = env["EXPANDED_CODE_SIGN_IDENTITY"]!
    
    /// 产物Frameworks目录
    static private let productFrameworksDir = "\(productAppDir)/Frameworks"
    
    static private var firstIPA = { () -> String? in
        guard let files = try? FileManager.default.contentsOfDirectory(atPath: assetsDir) else {
            return nil
        }
        
        guard let file = files.filter({ file in
            file.components(separatedBy: ".").last?.lowercased() == "ipa"
        }).sorted().first else {
            return nil
        }
        return "\(assetsDir)/\(file)"
    }()
    
    /// 注入动态库及Frameworkds目录
    static private let injectFrameworksDir = "\(srcRootDir)/Frameworks-inject"
}

// MARK: 重签名逻辑
extension AppCodeSign {
    
    /// 用脱壳ipa中的内容替换工程编译生成的应用内容
    static private func replaceApp() {
        
        // 确保能找到脱壳的ipa包
        guard let ipaPath = firstIPA else {
            print("没有找到IPA包")
            return
        }
        
        // 解压脱壳ipa到临时目录下
        Shell.bashExec("unzip -oqq \(ipaPath.bashPath()) -d \(tempDir.bashPath())")
        
        // 从临时目录拷贝脱壳应用的app/目录到已经生成的工程产物app/目录下
        let tempAppDir = tempDir + "/Payload/*.app/"
        Shell.bashExec("cp -rf \(tempAppDir.bashPath()) \(productAppDir.bashPath())")
        
        // 删除临时目录
        delDir(tempDir)
    }
    
    /// 为了是重签过程简化，移走extension和watchAPP. 此外个人免费的证书没办法签extension
    static private func removeExtensionAndWatchApp() {
        var deleteDirs = [productPluginDir, productWatchAppDir]
        if let extensionDirs = productExtensionDirs {
            deleteDirs += extensionDirs
        }
        deleteDirs.forEach({ dir in
            delDir(dir)
        })
    }
    
    /// 更新 Info.plist 里的BundleId
    static private func modifyProductAppInfoPlist() {
        
        // 读取Info.plist文件内容
        if let infoPlistDict = NSMutableDictionary(contentsOfFile: productInfoPlistPath) {
            
            infoPlistDict["CFBundleIdentifier"] = productBundleId
            
            let productDisplayName = infoPlistDict["CFBundleDisplayName"]!
            infoPlistDict["CFBundleDisplayName"] = "🦄\(productDisplayName)"
            
            if let supportDevices = infoPlistDict["UISupportedDevices"] as? [String] {
                let otherDevices = [
                    "iPhone12,5",
                    "iPhone12,3",
                    "iPhone12,1",
                    "iPhone11,8",
                    "iPhone11,6",
                    "iPhone11,4",
                    "iPhone11,2",
                    "iPhone10,6",
                    "iPhone10,5",
                    "iPhone10,4",
                    "iPhone10,3",
                    "iPhone10,1",
                    "iPhone10,4",
                    "iPhone6,1",
                    "iPhone6,2",
                    "iPhone7,2",
                    "iPhone8,1",
                    "iPhone8,4",
                    "iPhone9,1",
                    "iPhone9,3",
                    "iPod7,1"
                ]
                infoPlistDict["UISupportedDevices"] = Array(Set(supportDevices + otherDevices))
            }
            
            
            let appBinaryName = infoPlistDict["CFBundleExecutable"]!
            let appBinaryPath = productAppDir + "/\(appBinaryName)"
            Shell.bashExec("chmod +x \(appBinaryPath)")
            
            // 把修改后的内容写入Info.plist文件
            infoPlistDict.write(toFile: productInfoPlistPath, atomically: true)
        }
    }
    
    /// 注入动态库和Framework
    static private func injectDylibAndFramework() {
        try? FileManager.default.contentsOfDirectory(atPath: injectFrameworksDir).filter { name in
            if let ext = name.split(separator: ".").last, ext.lowercased() == "framework" {
                return true
            }
            else {
                return false
            }
        }.forEach { framework in
            injectFramework(fromFrameworkDir: injectFrameworksDir, toFrameworkDir: productFrameworksDir, framework: framework)
        }
        
        injectFramework(fromFrameworkDir: buildProductDir, toFrameworkDir: productFrameworksDir, framework: "OrzHook.framework")
    }
    
    /// 对修改后的App进行签名
    static private func codeSignModifiedApp() {
        try? FileManager.default.contentsOfDirectory(atPath: productFrameworksDir).forEach { framework in
            let frameworkPath = "\(productFrameworksDir)/\(framework)"
            print(frameworkPath)
            Shell.bashExec("/usr/bin/codesign --force --sign \(productExpandedCodeSignIdentity) \(frameworkPath)")
        }
    }
    
    /// 创建重签名App进行分发
    static private func distributeApp() {
        
    }
}

// MARK: 辅助工具方法
extension AppCodeSign {
    static func makeEmptyDir(_ absolutePath: String) {
        let fileURL = URL(fileURLWithPath: absolutePath)
        guard fileURL.isFileURL else {
            return
        }
        try? FileManager.default.removeItem(at: fileURL)
        try? FileManager.default.createDirectory(at: fileURL, withIntermediateDirectories: true, attributes: nil)
    }
    
    static func delDir(_ absolutePath: String) {
        let fileURL = URL(fileURLWithPath: absolutePath)
        guard fileURL.isFileURL else {
            return
        }
        try? FileManager.default.removeItem(at: fileURL)
    }
    
    @discardableResult
    static func yololibExec(_ args: [String]) -> String {
        return Shell.exec(launchPath: "\(srcRootDir)/Tools/yololib", args: args)
    }
    
    static var productAppBinaryName: String? {
        get {
            // 读取Info.plist文件内容
            let infoPlistDict = NSMutableDictionary(contentsOfFile: productInfoPlistPath)
            return infoPlistDict?["CFBundleExecutable"] as? String
        }
    }
    
    static func injectFramework(fromFrameworkDir: String,  toFrameworkDir:String, framework: String) {
        let originFrameworkPath = "\(fromFrameworkDir)/\(framework)"
        let targetFrameworkPath = "\(toFrameworkDir)/\(framework)"
        Shell.bashExec("cp -rf \(originFrameworkPath.bashPath()) \(targetFrameworkPath.bashPath())")
        if let appBinaryName = productAppBinaryName, let frameworkName = framework.split(separator: ".").first {
            yololibExec(["\(productAppDir)/\(appBinaryName)","Frameworks/\(framework)/\(frameworkName)"])
        }
    }
}

extension String {
    /// 对字符串文件路径中包含的空格进行转义，以在bash命令中当前参数传递
    /// - Returns: 转义后的文件路径
    func bashPath() -> String {
        return self.trimmingCharacters(in: .whitespaces).replacingOccurrences(of: " ", with: "\\ ")
    }
    
    /// 判断是否是文件夹的方法
    func isDirectory() -> Bool {
        var directoryExists = ObjCBool.init(false)
        let fileExists = FileManager.default.fileExists(atPath: self, isDirectory: &directoryExists)
        return fileExists && directoryExists.boolValue
    }
}

struct Shell {
    
    @discardableResult
    static func bashExec(_ commandLine: String) -> String {
        return exec(launchPath: "/usr/bin/env", args: ["bash", "-c", commandLine])
    }
    
    static func exec(launchPath: String, args: [String]) -> String {
        let task = Process()
        task.launchPath = launchPath
        task.arguments = args
        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()
        task.waitUntilExit()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output: String = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String
        return output
    }
}
