import Foundation

@main
struct UpdateRuntimePolicyTests {
    static func main() {
        var count = 0
        func check(_ condition: Bool, _ name: String) {
            precondition(condition, name)
            count += 1
        }
        check(UpdateRuntimePolicy(isDebugBuild: false, environment: [:]).enabled, "Release enables updates")
        check(!UpdateRuntimePolicy(isDebugBuild: true, environment: [:]).enabled, "Debug disables updates")
        check(UpdateRuntimePolicy(isDebugBuild: true, environment: ["VKEY_ENABLE_UPDATES": "1"]).enabled, "Debug explicit opt-in")
        for environment in [
            ["XCTestConfigurationFilePath": "/tmp/tests.xctestconfiguration"],
            ["XCTestBundlePath": "/tmp/tests.xctest"],
            ["XCODE_RUNNING_FOR_PREVIEWS": "1"]
        ] {
            check(!UpdateRuntimePolicy(isDebugBuild: false, environment: environment).enabled, "Test and preview isolation")
        }
        let paths: [(String, Bool, Bool)] = [
            ("/Applications/VKey.app", true, true),
            ("/Applications/VKey.app", false, false),
            ("/Applications/VKey.zip", true, false),
            ("/Applications/Nested/VKey.app", true, false),
            ("/Users/test/Downloads/VKey.app", true, false),
            ("/Volumes/VKey/VKey.app", true, false),
            ("/private/var/folders/AppTranslocation/random/d/VKey.app", true, false),
            ("/Applications/../tmp/VKey.app", true, false)
        ]
        for (path, writable, expected) in paths {
            check(UpdateRuntimePolicy.installationIsEligible(bundleURL: URL(fileURLWithPath: path), isWritable: writable) == expected, path)
        }
        print("PASS: \(count) update runtime policy checks")
    }
}
