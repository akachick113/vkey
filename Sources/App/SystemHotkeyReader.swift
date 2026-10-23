import Carbon

enum SystemHotkeyReader {
    static func enabledHotkeys() -> [SystemHotkey] {
        var hotkeys: Unmanaged<CFArray>?
        guard CopySymbolicHotKeys(&hotkeys) == noErr,
              let entries = hotkeys?.takeRetainedValue() as? [[String: Any]] else { return [] }
        return entries.compactMap { entry in
            guard let enabled = entry[kHISymbolicHotKeyEnabled as String] as? NSNumber, enabled.boolValue,
                  let code = entry[kHISymbolicHotKeyCode as String] as? NSNumber,
                  let modifiers = entry[kHISymbolicHotKeyModifiers as String] as? NSNumber else { return nil }
            return SystemHotkey(keyCode: code.intValue, carbonModifiers: modifiers.intValue)
        }
    }
}
