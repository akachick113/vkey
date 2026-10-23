#include "VKKeyLayout.h"

// Engine API; keep this adapter independent of the engine's other headers.
extern Uint16 keyCodeToCharacter(const Uint32& keyCode);

VKLanguageKeyAction VKLanguageKeyActionFor(Uint16 physicalKeycode, bool optionEnabled, bool appExcluded,
                                          bool hasCommandControlOption, bool inputSourceIsLatin) {
    if (appExcluded || hasCommandControlOption) return VKLanguageKeyNotHandled;
    if (physicalKeycode != 102 && physicalKeycode != 104) return VKLanguageKeyNotHandled;
    if (!optionEnabled) return VKLanguageKeyEndWord;
    if (physicalKeycode == 104) return VKLanguageKeyPassToSystem;
    if (physicalKeycode == 102) {
        return inputSourceIsLatin ? VKLanguageKeyToggleLanguage : VKLanguageKeyPassToSystem;
    }
    return VKLanguageKeyNotHandled;
}

VKKey VKJISToLogicalKey(Uint16 physicalKeycode, bool shift) {
    switch (physicalKeycode) {
        case 30: return {33, shift};
        case 42: return {30, shift};
        case 33: return {42, shift};
        case 93: return {42, shift};
        case 95: return {43, shift};
        case 94: return {27, true};
        default: return {physicalKeycode, shift};
    }
}

Uint16 VKLogicalToJISKeycode(Uint16 logicalKeycode) {
    switch (logicalKeycode) {
        case 33: return 30;
        case 30: return 42;
        default: return logicalKeycode;
    }
}

Uint16 VKCurrentKeyCharacter(bool isJIS, Uint16 logicalKeycode, bool caps, Uint16 eventCharacter) {
    const Uint16 logicalCharacter = keyCodeToCharacter(logicalKeycode | (caps ? CAPS_MASK : 0));
    if (logicalCharacter == 0) return 0; // Controls must be resent as key events.
    if (isJIS && eventCharacter != 0) return eventCharacter;
    return logicalCharacter;
}

Uint16 VKJISWordCharacter(Uint32 data) {
    if (data & (CHAR_CODE_MASK | PURE_CHARACTER_MASK)) return 0;
    return keyCodeToCharacter(data);
}

bool VKTreatAsJIS(int keyboardMode, bool hardwareIsJIS) {
    if (keyboardMode == VKKeyboardModeJIS) return true;
    if (keyboardMode == VKKeyboardModeANSI) return false;
    return hardwareIsJIS;
}

VKLanguageKeyAction VKLanguageKeyActionForMode(int keyboardMode, Uint16 physicalKeycode, bool optionEnabled,
                                              bool appExcluded, bool hasCommandControlOption, bool inputSourceIsLatin) {
    if (keyboardMode == VKKeyboardModeANSI) return VKLanguageKeyNotHandled;
    return VKLanguageKeyActionFor(physicalKeycode, optionEnabled, appExcluded,
                                  hasCommandControlOption, inputSourceIsLatin);
}
