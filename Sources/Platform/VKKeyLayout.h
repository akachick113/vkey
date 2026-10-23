#pragma once

#include "DataType.h"

struct VKKey {
    Uint16 keycode;
    bool shift;
};

enum VKLanguageKeyAction {
    VKLanguageKeyNotHandled = 0,
    VKLanguageKeyPassToSystem,
    VKLanguageKeyToggleLanguage,
    VKLanguageKeyEndWord, // Chỉ kết thúc từ, phím đi tiếp như cũ.
};
VKLanguageKeyAction VKLanguageKeyActionFor(Uint16 physicalKeycode, bool optionEnabled, bool appExcluded,
                                          bool hasCommandControlOption, bool inputSourceIsLatin);

VKKey VKJISToLogicalKey(Uint16 physicalKeycode, bool shift);
Uint16 VKLogicalToJISKeycode(Uint16 logicalKeycode);
Uint16 VKCurrentKeyCharacter(bool isJIS, Uint16 logicalKeycode, bool caps, Uint16 eventCharacter);
// Printable logical word data on JIS; zero keeps control/encoded data on its existing path.
Uint16 VKJISWordCharacter(Uint32 data);

enum VKKeyboardMode { VKKeyboardModeAuto = 0, VKKeyboardModeJIS = 1, VKKeyboardModeANSI = 2 };
bool VKTreatAsJIS(int keyboardMode, bool hardwareIsJIS);
VKLanguageKeyAction VKLanguageKeyActionForMode(int keyboardMode, Uint16 physicalKeycode, bool optionEnabled,
                                              bool appExcluded, bool hasCommandControlOption, bool inputSourceIsLatin);
