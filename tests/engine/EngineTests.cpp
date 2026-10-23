#include "EngineHarness.h"
#include "VKKeyLayout.h"
#include <iostream>
#include <stdexcept>

using engine_test::ansiKeys;
using engine_test::type;
using engine_test::jisKeys;
using engine_test::typeJIS;
using engine_test::typeJISWithLanguageKeys;

static std::string utf8(const std::u16string& text) {
    // The harness emits BMP characters (ASCII and Vietnamese Unicode).
    return wideStringToUtf8(std::wstring(text.begin(), text.end()));
}

static void expect(const std::u16string& actual, const std::u16string& expected) {
    if (actual != expected) {
        throw std::runtime_error("actual: [" + utf8(actual) + "]; expected: [" + utf8(expected) + "]");
    }
}

static void case01_telexVietnameseSentence() {
    expect(type(ansiKeys("Tieengs Vieetj")), u"Tiếng Việt");
}

static void case02_telexDdang() {
    expect(type(ansiKeys("ddawng")), u"đăng");
}

static void case03_telexDday() {
    expect(type(ansiKeys("ddaay")), u"đây");
}

static void case04_traditionalOrthography() {
    expect(type(ansiKeys("hoaf")), u"hòa");
}

static void case05_modernOrthography() {
    vUseModernOrthography = 1;
    expect(type(ansiKeys("hoaf")), u"hoà");
}

static void case06_leftBracketAfterConsonant() {
    expect(type({{KEY_T, 0, u't'}, {33, 0, u'['}}), u"tơ");
}

static void case07_rightBracketAfterConsonant() {
    expect(type({{KEY_T, 0, u't'}, {30, 0, u']'}}), u"tư");
}

static void case08_standaloneBrackets() {
    expect(type({{33, 0, u'['}}), u"ơ");
    expect(type({{30, 0, u']'}}), u"ư");
}

static void case09_repeatedToneRestoresLetter() {
    expect(type(ansiKeys("tesst")), u"test");
}

static void case10_vniAcute() {
    vInputType = vVNI;
    expect(type(ansiKeys("a1")), u"á");
}

static void case11_vniTieng() {
    vInputType = vVNI;
    expect(type(ansiKeys("tie6ng1")), u"tiếng");
}

static void case12_vniDday() {
    vInputType = vVNI;
    expect(type(ansiKeys("d9a6y")), u"đây");
}

static void case13_vniShiftTwoIsAtSign() {
    vInputType = vVNI;
    expect(type({{KEY_A, 0, u'a'}, {19, 1, u'@'}}), u"a@");
}

static void case14_vniShiftSixIsCaret() {
    vInputType = vVNI;
    expect(type({{KEY_A, 0, u'a'}, {22, 1, u'^'}}), u"a^");
}

static void case15_englishBypassesEngine() {
    vLanguage = 0;
    expect(type(ansiKeys("ddaay")), u"ddaay");
}

static void case16_shiftUppercaseD() {
    expect(type(ansiKeys("DDaay")), u"Đây");
}

static void expectKey(Uint16 physical, bool shift, Uint16 expected, bool expectedShift) {
    const auto key = VKJISToLogicalKey(physical, shift);
    if (key.keycode != expected || key.shift != expectedShift) {
        throw std::runtime_error("Unexpected JIS mapping for key " + std::to_string(physical));
    }
}

static void expectCode(Uint16 actual, Uint16 expected) {
    if (actual != expected) throw std::runtime_error("Unexpected keycode or character");
}

static void case17_jisBracketPermutation() {
    for (bool shift : {false, true}) {
        expectKey(30, shift, 33, shift);
        expectKey(42, shift, 30, shift);
        expectKey(33, shift, 42, shift);
    }
}

static void case18_jisOnlyKeys() {
    for (bool shift : {false, true}) {
        expectKey(93, shift, 42, shift);
        expectKey(95, shift, 43, shift);
        expectKey(94, shift, 27, true);
    }
}

static void case19_jisUnchangedKeys() {
    for (Uint16 key : {KEY_A, KEY_Z, KEY_Q, KEY_1, KEY_2, KEY_0, 24, 27, 39, 41,
                       KEY_SPACE, KEY_RETURN, 102, 104}) {
        for (bool shift : {false, true}) expectKey(key, shift, key, shift);
    }
}

static void case20_logicalToJIS() {
    expectCode(VKLogicalToJISKeycode(33), 30);
    expectCode(VKLogicalToJISKeycode(30), 42);
    for (Uint16 key : {KEY_A, 42, 27}) expectCode(VKLogicalToJISKeycode(key), key);
}

static void case21_currentEventCharacter() {
    expectCode(VKCurrentKeyCharacter(true, 42, false, u'¥'), u'¥');
    for (bool caps : {false, true}) {
        expectCode(VKCurrentKeyCharacter(true, KEY_A, caps, 0),
                   keyCodeToCharacter(KEY_A | (caps ? CAPS_MASK : 0)));
    }
    expectCode(VKCurrentKeyCharacter(false, 42, false, u'@'), u'\\');
}

static void case22_jisLeftBracket() {
    expect(typeJIS(jisKeys(u"t[")), u"tơ");
}

static void case23_jisRightBracket() {
    expect(typeJIS(jisKeys(u"t]")), u"tư");
}

static void case24_jisShiftBracket() {
    expect(typeJIS(jisKeys(u"t{")), u"tƠ");
}

static void case25_jisAtBetweenLetters() {
    expect(typeJIS(jisKeys(u"a@b")), u"a@b");
}

static void case26_jisRepeatedAt() {
    expect(typeJIS(jisKeys(u"@@")), u"@@");
}

static void case27_jisRepeatedLeftBracket() {
    expect(typeJIS(jisKeys(u"t[[")), u"t[");
}

static void case28_jisRepeatedRightBracket() {
    expect(typeJIS(jisKeys(u"t]]")), u"t]");
}

static void case29_jisYenBreaksWord() {
    expect(typeJIS(jisKeys(u"tooi¥as")), u"tôi¥á");
}

static void case30_jisUnderscoreBreaksWord() {
    expect(typeJIS(jisKeys(u"tooi_as")), u"tôi_á");
}

static void case31_jisVniCaret() {
    vInputType = vVNI;
    expect(typeJIS(jisKeys(u"a^")), u"a^");
}

static void case32_jisVniAt() {
    vInputType = vVNI;
    expect(typeJIS(jisKeys(u"a@")), u"a@");
}

static void case33_jisVniCaretInWord() {
    vInputType = vVNI;
    expect(typeJIS(jisKeys(u"tie^ng1")), u"tie^ng1");
}

static void case34_jisVietnameseSentence() {
    expect(typeJIS(jisKeys(u"Tieengs Vieetj")), u"Tiếng Việt");
}

static void case35_jisRestoreAt() {
    vRestoreIfWrongSpelling = 1;
    expect(typeJIS(jisKeys(u"windows@")), u"windows@");
}

static void case36_jisRestoreYen() {
    vRestoreIfWrongSpelling = 1;
    expect(typeJIS(jisKeys(u"windows¥")), u"windows¥");
}

static void case37_jisControlKeysRemainKeyEvents() {
    for (bool caps : {false, true}) {
        expectCode(VKCurrentKeyCharacter(true, KEY_RETURN, caps, u'\r'), 0);
        expectCode(VKCurrentKeyCharacter(true, KEY_TAB, caps, u'\t'), 0);
        expectCode(VKCurrentKeyCharacter(true, KEY_LEFT, caps, 0xF702), 0);
        expectCode(VKCurrentKeyCharacter(true, KEY_RIGHT, caps, 0xF703), 0);
    }
    expectCode(VKCurrentKeyCharacter(true, KEY_SPACE, false, u' '), u' ');
}

static void case38_jisRestoreReturnMatchesANSI() {
    vRestoreIfWrongSpelling = 1;
    const auto jis = typeJIS(jisKeys(u"windows\n"));
    expect(jis, u"windows\n");
    expect(jis, type(ansiKeys("windows\n")));
}

static void case39_jisWordCharactersPreserveANSIPunctuation() {
    expectCode(VKJISWordCharacter(KEY_2 | CAPS_MASK), u'@');
    expectCode(VKJISWordCharacter(KEY_SEMICOLON | CAPS_MASK), u':');
    expectCode(VKJISWordCharacter(KEY_MINUS | CAPS_MASK), u'_');
    expectCode(VKJISWordCharacter(KEY_A), u'a');
    expectCode(VKJISWordCharacter(33), u'[');
    expectCode(VKJISWordCharacter(KEY_RETURN), 0);
    expectCode(VKJISWordCharacter(KEY_A | CHAR_CODE_MASK), 0);
    expectCode(VKJISWordCharacter(KEY_A | PURE_CHARACTER_MASK), 0);
}

static void expectAction(Uint16 key, bool enabled, bool excluded, bool modified, bool latin,
                         VKLanguageKeyAction expected) {
    expectCode(VKLanguageKeyActionFor(key, enabled, excluded, modified, latin), expected);
}

static void case40_kanaPassesToSystem() {
    for (bool latin : {false, true}) {
        expectAction(104, true, false, false, latin, VKLanguageKeyPassToSystem);
    }
}

static void case41_eisuFromJapanesePassesToSystem() {
    expectAction(102, true, false, false, false, VKLanguageKeyPassToSystem);
}

static void case42_eisuFromLatinTogglesLanguage() {
    expectAction(102, true, false, false, true, VKLanguageKeyToggleLanguage);
}

static void case43_disabledLanguageKeysEndWord() {
    for (Uint16 key : {102, 104}) {
        for (bool latin : {false, true}) {
            expectAction(key, false, false, false, latin, VKLanguageKeyEndWord);
        }
    }
}

static void case44_excludedAppsUseOldPath() {
    for (Uint16 key : {102, 104}) {
        for (bool latin : {false, true}) {
            expectAction(key, true, true, false, latin, VKLanguageKeyNotHandled);
        }
    }
}

static void case45_commandControlOptionUseOldPath() {
    // Each of Command, Control and Option is represented by the same pure input.
    for (Uint16 key : {102, 104}) {
        for (bool latin : {false, true}) {
            expectAction(key, true, false, true, latin, VKLanguageKeyNotHandled);
        }
    }
}

static void case46_otherKeysUseOldPath() {
    for (Uint16 key : {KEY_A, KEY_Z, KEY_RETURN, KEY_SPACE, KEY_ESC, 93, 94, 95}) {
        for (bool latin : {false, true}) {
            expectAction(key, true, false, false, latin, VKLanguageKeyNotHandled);
        }
    }
}

static void case47_japaneseVietnameseEnglishSequence() {
    bool latin = true;
    auto press = [&latin](Uint16 key, VKLanguageKeyAction expected) {
        const auto action = VKLanguageKeyActionFor(key, true, false, false, latin);
        expectCode(action, expected);
        if (action == VKLanguageKeyPassToSystem) {
            latin = key == 102;
            startNewSession();
        } else if (action == VKLanguageKeyToggleLanguage) {
            vLanguage = 1 - vLanguage;
            startNewSession();
        }
    };
    press(104, VKLanguageKeyPassToSystem);
    expectCode(latin, false);
    expectCode(vLanguage, 1);
    press(102, VKLanguageKeyPassToSystem);
    expectCode(latin, true);
    expectCode(vLanguage, 1);
    expect(typeJIS(jisKeys(u"ddaay")), u"đây");
    press(102, VKLanguageKeyToggleLanguage);
    expectCode(vLanguage, 0);
    expect(typeJIS(jisKeys(u"ddaay")), u"ddaay");
    press(102, VKLanguageKeyToggleLanguage);
    expectCode(vLanguage, 1);
    expect(typeJIS(jisKeys(u"ddaay")), u"đây");

    vLanguage = 0;
    press(104, VKLanguageKeyPassToSystem);
    expectCode(latin, false);
    expectCode(vLanguage, 0);
    press(102, VKLanguageKeyPassToSystem);
    expectCode(latin, true);
    expectCode(vLanguage, 0);
    expect(typeJIS(jisKeys(u"ddaay")), u"ddaay");
}

static void case52_disabledLanguageKeyExceptions() {
    for (Uint16 key : {102, 104}) {
        for (bool latin : {false, true}) {
            expectAction(key, false, true, false, latin, VKLanguageKeyNotHandled);
            expectAction(key, false, false, true, latin, VKLanguageKeyNotHandled);
        }
    }
    for (Uint16 key : {KEY_A, KEY_RETURN, KEY_SPACE, 93, 94, 95}) {
        for (bool latin : {false, true}) {
            expectAction(key, false, false, false, latin, VKLanguageKeyNotHandled);
        }
    }
}

static void case53_disabledLanguageKeysSeparateWords() {
    const engine_test::Key eisu = {102, 0, u' '};
    const engine_test::Key kana = {104, 0, u' '};
    auto keys = jisKeys(u"ddaay");
    keys.insert(keys.begin(), {{36, 0, u'\r'}, eisu});
    expect(typeJISWithLanguageKeys(keys, false), u"\rđây");
    auto repeated = jisKeys(u"ddaay");
    repeated.push_back(eisu);
    const auto word = jisKeys(u"ddaay");
    repeated.insert(repeated.end(), word.begin(), word.end());
    expect(typeJISWithLanguageKeys(repeated, false), u"đâyđây");
    expect(typeJISWithLanguageKeys({{KEY_A, 0, u'a'}, eisu, {KEY_A, 0, u'a'}}, false), u"aa");
    auto split = jisKeys(u"tie");
    split.push_back(kana);
    const auto suffix = jisKeys(u"es");
    split.insert(split.end(), suffix.begin(), suffix.end());
    expect(typeJISWithLanguageKeys(split, false), u"tieé");
    expectCode(vLanguage, 1);
    vLanguage = 0;
    expect(typeJISWithLanguageKeys(keys, false), u"\rddaay");
    expectCode(vLanguage, 0);
}

static void case54_enabledLanguageKeysToggleBetweenWords() {
    auto keys = jisKeys(u"ddaay");
    const auto word = keys;
    for (int i = 0; i < 2; ++i) {
        keys.push_back({102, 0, u' '});
        keys.insert(keys.end(), word.begin(), word.end());
    }
    expect(typeJISWithLanguageKeys(keys, true), u"đâyddaayđây");
    expectCode(vLanguage, 1);
}

static void case71_treatAsJISByMode() {
    for (const bool hardware : {false, true}) {
        for (const int mode : {0, 7, -1}) expectCode(VKTreatAsJIS(mode, hardware), hardware);
        expectCode(VKTreatAsJIS(1, hardware), true);
        expectCode(VKTreatAsJIS(2, hardware), false);
    }
}

static void case72_languageKeysByMode() {
    for (const Uint16 key : {102, 104}) {
        for (const bool enabled : {false, true}) {
            for (const bool latin : {false, true}) {
                for (const bool excluded : {false, true}) {
                    for (const bool modified : {false, true}) {
                        const auto original = VKLanguageKeyActionFor(key, enabled, excluded, modified, latin);
                        expectCode(VKLanguageKeyActionForMode(2, key, enabled, excluded, modified, latin), VKLanguageKeyNotHandled);
                        for (const int mode : {0, 1, 7, -1}) {
                            expectCode(VKLanguageKeyActionForMode(mode, key, enabled, excluded, modified, latin), original);
                        }
                    }
                }
            }
        }
    }
}

static void case73_typingByKeyboardMode() {
    using engine_test::typeWithKeyboardMode;
    for (const int mode : {0, 1, 2}) {
        expect(typeWithKeyboardMode(mode, true, jisKeys(u"@")), mode == 2 ? u"ơ" : u"@");
        expect(typeWithKeyboardMode(mode, true, jisKeys(u"[")), mode == 2 ? u"ư" : u"ơ");
        expect(typeWithKeyboardMode(mode, true, jisKeys(u"]")), mode == 2 ? u"]" : u"ư");
        expect(typeWithKeyboardMode(mode, true, jisKeys(u"tooi@as")), mode == 2 ? u"tôi@as" : u"tôi@á");
        expect(typeWithKeyboardMode(mode, true, jisKeys(u"ddaay")), u"đây");
    }
    for (const int mode : {0, 2}) expect(typeWithKeyboardMode(mode, false, ansiKeys("ddaay")), u"đây");
}

int main() {
    struct Test {
        const char* name;
        void (*run)();
    };
#define TEST(name) {#name, name}
    const Test tests[] = {
        TEST(case01_telexVietnameseSentence),
        TEST(case02_telexDdang),
        TEST(case03_telexDday),
        TEST(case04_traditionalOrthography),
        TEST(case05_modernOrthography),
        TEST(case06_leftBracketAfterConsonant),
        TEST(case07_rightBracketAfterConsonant),
        TEST(case08_standaloneBrackets),
        TEST(case09_repeatedToneRestoresLetter),
        TEST(case10_vniAcute),
        TEST(case11_vniTieng),
        TEST(case12_vniDday),
        TEST(case13_vniShiftTwoIsAtSign),
        TEST(case14_vniShiftSixIsCaret),
        TEST(case15_englishBypassesEngine),
        TEST(case16_shiftUppercaseD),
        TEST(case17_jisBracketPermutation),
        TEST(case18_jisOnlyKeys),
        TEST(case19_jisUnchangedKeys),
        TEST(case20_logicalToJIS),
        TEST(case21_currentEventCharacter),
        TEST(case22_jisLeftBracket),
        TEST(case23_jisRightBracket),
        TEST(case24_jisShiftBracket),
        TEST(case25_jisAtBetweenLetters),
        TEST(case26_jisRepeatedAt),
        TEST(case27_jisRepeatedLeftBracket),
        TEST(case28_jisRepeatedRightBracket),
        TEST(case29_jisYenBreaksWord),
        TEST(case30_jisUnderscoreBreaksWord),
        TEST(case31_jisVniCaret),
        TEST(case32_jisVniAt),
        TEST(case33_jisVniCaretInWord),
        TEST(case34_jisVietnameseSentence),
        TEST(case35_jisRestoreAt),
        TEST(case36_jisRestoreYen),
        TEST(case37_jisControlKeysRemainKeyEvents),
        TEST(case38_jisRestoreReturnMatchesANSI),
        TEST(case39_jisWordCharactersPreserveANSIPunctuation),
        TEST(case40_kanaPassesToSystem),
        TEST(case41_eisuFromJapanesePassesToSystem),
        TEST(case42_eisuFromLatinTogglesLanguage),
        TEST(case43_disabledLanguageKeysEndWord),
        TEST(case44_excludedAppsUseOldPath),
        TEST(case45_commandControlOptionUseOldPath),
        TEST(case46_otherKeysUseOldPath),
        TEST(case47_japaneseVietnameseEnglishSequence),
        TEST(case52_disabledLanguageKeyExceptions),
        TEST(case53_disabledLanguageKeysSeparateWords),
        TEST(case54_enabledLanguageKeysToggleBetweenWords),
        TEST(case71_treatAsJISByMode),
        TEST(case72_languageKeysByMode),
        TEST(case73_typingByKeyboardMode),
    };
#undef TEST
    int passed = 0;
    int failed = 0;
    for (const auto& test : tests) {
        try {
            engine_test::resetConfiguration();
            test.run();
            ++passed;
        } catch (const std::exception& error) {
            std::cerr << "FAIL: " << test.name << ": " << error.what() << '\n';
            ++failed;
        }
    }
    if (failed != 0) {
        std::cerr << "FAIL: " << failed << " engine tests; " << passed << " passed\n";
        return 1;
    }
    std::cout << "PASS: " << passed << " engine tests\n";
    return 0;
}
