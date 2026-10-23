#include "EngineHarness.h"
#include "VKKeyLayout.h"
#include "../../Sources/Platform/VKGlobals.h"
#include <stdexcept>

// The app defines these in VKBridge.mm; the standalone tests own their copy.
int vLanguage = 1;
int vInputType = 0;
int vFreeMark = 0;
int vCodeTable = 0;
int vCheckSpelling = 1;
int vUseModernOrthography = 0;
int vQuickTelex = 0;
int vSwitchKeyStatus = VKEY_DEFAULT_SWITCH_STATUS;
int vRestoreIfWrongSpelling = 0;
int vFixRecommendBrowser = 1;
int vUseMacro = 1;
int vUseMacroInEnglishMode = 0;
int vAutoCapsMacro = 0;
int vSendKeyStepByStep = 0;
int vUseSmartSwitchKey = 1;
int vUpperCaseFirstChar = 0;
int vTempOffSpelling = 0;
int vAllowConsonantZFWJ = 0;
int vQuickStartConsonant = 0;
int vQuickEndConsonant = 0;
int vRememberCode = 1;
int vOtherLanguage = 1;
int vUseJISLanguageKeys = 1;
int vTempOffOpenKey = 0;
int vFixChromiumBrowser = 0;
int vPerformLayoutCompat = 0;
int vFixSpotlight = 1;
int vUseAXReplacement = 1;

namespace engine_test {

void resetConfiguration() {
    // AppState.registerDefaultSettings + zero for unregistered preferences
    // loaded by VKEngineInit (not VKBridge's pre-preference initial values).
    vLanguage = 1;
    vInputType = vTelex;
    vFreeMark = 0;
    vCodeTable = 0;
    vCheckSpelling = 1;
    vUseModernOrthography = 0;
    vQuickTelex = 0;
    vSwitchKeyStatus = VKEY_DEFAULT_SWITCH_STATUS;
    vRestoreIfWrongSpelling = 0;
    vFixRecommendBrowser = 1;
    vUseMacro = 1;
    vUseMacroInEnglishMode = 0;
    vAutoCapsMacro = 0;
    vSendKeyStepByStep = 0;
    vUseSmartSwitchKey = 1;
    vUpperCaseFirstChar = 0;
    vTempOffSpelling = 0;
    vAllowConsonantZFWJ = 0;
    vQuickStartConsonant = 0;
    vQuickEndConsonant = 0;
    vRememberCode = 1;
    vOtherLanguage = 1;
    vUseJISLanguageKeys = 1;
    vTempOffOpenKey = 0;
    vFixChromiumBrowser = 0;
    vPerformLayoutCompat = 0;
    vFixSpotlight = 1;
    vUseAXReplacement = 1;
    initMacroMap(nullptr, 0);
    vKeyInit();
    startNewSession();
}

std::vector<Key> ansiKeys(const std::string& ascii) {
    struct Position {
        Uint16 code;
        char plain;
        char shifted;
    };
    // Sources/Engine/platforms/mac.h describes physical ANSI positions.
    static const Position positions[] = {
        {KEY_A, 'a', 'A'}, {KEY_B, 'b', 'B'}, {KEY_C, 'c', 'C'},
        {KEY_D, 'd', 'D'}, {KEY_E, 'e', 'E'}, {KEY_F, 'f', 'F'},
        {KEY_G, 'g', 'G'}, {KEY_H, 'h', 'H'}, {KEY_I, 'i', 'I'},
        {KEY_J, 'j', 'J'}, {KEY_K, 'k', 'K'}, {KEY_L, 'l', 'L'},
        {KEY_M, 'm', 'M'}, {KEY_N, 'n', 'N'}, {KEY_O, 'o', 'O'},
        {KEY_P, 'p', 'P'}, {KEY_Q, 'q', 'Q'}, {KEY_R, 'r', 'R'},
        {KEY_S, 's', 'S'}, {KEY_T, 't', 'T'}, {KEY_U, 'u', 'U'},
        {KEY_V, 'v', 'V'}, {KEY_W, 'w', 'W'}, {KEY_X, 'x', 'X'},
        {KEY_Y, 'y', 'Y'}, {KEY_Z, 'z', 'Z'},
        {KEY_1, '1', '!'}, {KEY_2, '2', '@'}, {KEY_3, '3', '#'},
        {KEY_4, '4', '$'}, {KEY_5, '5', '%'}, {KEY_6, '6', '^'},
        {KEY_7, '7', '&'}, {KEY_8, '8', '*'}, {KEY_9, '9', '('},
        {KEY_0, '0', ')'}, {KEY_LEFT_BRACKET, '[', '{'},
        {KEY_RIGHT_BRACKET, ']', '}'}, {KEY_BACKQUOTE, '`', '~'},
        {KEY_MINUS, '-', '_'}, {KEY_EQUALS, '=', '+'},
        {KEY_BACK_SLASH, '\\', '|'}, {KEY_SEMICOLON, ';', ':'},
        {KEY_QUOTE, '\'', '"'}, {KEY_COMMA, ',', '<'},
        {KEY_DOT, '.', '>'}, {KEY_SLASH, '/', '?'},
        {KEY_SPACE, ' ', ' '}, {KEY_TAB, '\t', '\t'},
        {KEY_RETURN, '\n', '\n'}, {KEY_DELETE, '\b', '\b'},
    };
    std::vector<Key> keys;
    for (char ch : ascii) {
        bool found = false;
        for (const auto& position : positions) {
            if (ch == position.plain || ch == position.shifted) {
                keys.push_back({position.code,
                                static_cast<Uint8>(ch != position.plain),
                                static_cast<char16_t>(ch)});
                found = true;
                break;
            }
        }
        if (!found) {
            throw std::invalid_argument("ansiKeys requires printable ASCII, tab, newline or backspace");
        }
    }
    return keys;
}

std::vector<Key> jisKeys(const std::u16string& text) {
    struct Position {
        Uint16 code;
        char16_t plain;
        char16_t shifted;
    };
    static const Position positions[] = {
        {19, u'2', u'"'}, {22, u'6', u'&'}, {24, u'^', u'~'},
        {25, u'9', u')'}, {26, u'7', u'\''}, {27, u'-', u'='},
        {28, u'8', u'('}, {29, u'0', 0}, {30, u'[', u'{'},
        {33, u'@', u'`'}, {39, u':', u'*'}, {41, u';', u'+'},
        {42, u']', u'}'}, {93, u'¥', u'|'}, {94, u'_', u'_'},
    };
    std::vector<Key> keys;
    for (char16_t ch : text) {
        bool found = false;
        for (const auto& position : positions) {
            if (ch != 0 && (ch == position.plain || ch == position.shifted)) {
                keys.push_back({position.code, static_cast<Uint8>(ch != position.plain), ch});
                found = true;
                break;
            }
        }
        if (!found) {
            // Remaining letters, digits, punctuation and controls share ANSI positions.
            if (ch > 127 || ch == u'\\') throw std::invalid_argument("Unsupported JIS character");
            const auto key = ansiKeys(std::string(1, static_cast<char>(ch))).front();
            keys.push_back(key);
        }
    }
    return keys;
}

static std::u16string typeKeys(const std::vector<Key>& keys, bool isJIS,
                               bool handleLanguageKeys = false, bool optionEnabled = false) {
    if (vCodeTable != 0) {
        throw std::invalid_argument("EngineHarness supports Unicode code table 0 only");
    }
    auto* state = static_cast<vKeyHookState*>(vKeyInit());
    startNewSession();
    std::u16string text;
    auto appendRaw = [&text](const Key& key) {
        if (key.keycode == KEY_DELETE) {
            if (!text.empty()) text.pop_back();
        } else {
            text.push_back(key.raw);
        }
    };
    for (const auto& key : keys) {
        if (handleLanguageKeys) {
            const auto action = VKLanguageKeyActionFor(key.keycode, optionEnabled, false, false, true);
            if (action != VKLanguageKeyNotHandled) {
                if (action == VKLanguageKeyToggleLanguage) vLanguage = 1 - vLanguage;
                vKeyHandleEvent(vKeyEvent::Mouse, vKeyEventState::MouseDown, 0);
                continue;
            }
        }
        // VKEngineCallback bypasses Vietnamese processing in English mode.
        // No user macros are loaded in this harness.
        if (vLanguage == 0) {
            appendRaw(key);
            continue;
        }
        const VKKey logical = isJIS ? VKJISToLogicalKey(key.keycode, key.caps != 0)
                                    : VKKey{key.keycode, key.caps != 0};
        vKeyHandleEvent(vKeyEvent::Keyboard, vKeyEventState::KeyDown,
                        logical.keycode, isJIS ? logical.shift : key.caps, false);
        if (state->code == vDoNothing) {
            appendRaw(key);
            continue;
        }
        if (state->code != vWillProcess && state->code != vRestore &&
            state->code != vRestoreAndStartNewSession) {
            throw std::runtime_error("Unexpected engine action: " + std::to_string(state->code));
        }
        if (state->backspaceCount > text.size() || state->newCharCount > MAX_BUFF) {
            throw std::runtime_error("Invalid engine replacement bounds");
        }
        text.resize(text.size() - state->backspaceCount);
        // charData is reversed, matching SendNewCharString in the event tap.
        for (int i = state->newCharCount - 1; i >= 0; --i) {
            const Uint32 data = state->charData[i];
            const char16_t ch = (data & (CHAR_CODE_MASK | PURE_CHARACTER_MASK))
                ? static_cast<char16_t>(data & CHAR_MASK)
                : static_cast<char16_t>(keyCodeToCharacter(data));
            if (ch == 0) throw std::runtime_error("Unmapped engine output keycode");
            text.push_back(ch);
        }
        if (state->code == vRestore || state->code == vRestoreAndStartNewSession) {
            if (isJIS) {
                const auto ch = VKCurrentKeyCharacter(true, logical.keycode, logical.shift, key.raw);
                if (ch != 0) {
                    text.push_back(ch);
                } else {
                    appendRaw(key);
                }
            } else {
                appendRaw(key);
            }
        }
        if (state->code == vRestoreAndStartNewSession) startNewSession();
    }
    return text;
}

std::u16string type(const std::vector<Key>& keys) {
    return typeKeys(keys, false);
}

std::u16string typeJIS(const std::vector<Key>& keys) {
    return typeKeys(keys, true);
}

std::u16string typeJISWithLanguageKeys(const std::vector<Key>& keys, bool optionEnabled) {
    return typeKeys(keys, true, true, optionEnabled);
}

std::u16string typeWithKeyboardMode(int mode, bool hardwareIsJIS, const std::vector<Key>& keys) {
    return VKTreatAsJIS(mode, hardwareIsJIS) ? typeJIS(keys) : type(keys);
}

} // namespace engine_test
