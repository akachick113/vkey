#pragma once

#include "Engine.h"
#include <string>
#include <vector>

namespace engine_test {

struct Key {
    Uint16 keycode;
    Uint8 caps;
    char16_t raw;
};

// Fresh-install settings, independent of the user's saved preferences.
void resetConfiguration();

// Physical ANSI positions; uppercase and shifted symbols carry caps = 1.
std::vector<Key> ansiKeys(const std::string& ascii);

// Physical JIS positions in the ABC layout, preserving the event character.
std::vector<Key> jisKeys(const std::u16string& text);
std::u16string typeJIS(const std::vector<Key>& keys);
std::u16string typeWithKeyboardMode(int mode, bool hardwareIsJIS, const std::vector<Key>& keys);
// Latin input source, no excluded app or Command/Control/Option. Language keys
// never insert text; their action ends the word just as RequestNewSession does.
std::u16string typeJISWithLanguageKeys(const std::vector<Key>& keys, bool optionEnabled);

// A new text field / engine session for each call. Unicode (code table 0) only.
std::u16string type(const std::vector<Key>& keys);

} // namespace engine_test
