import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

import '../utils/enums.dart';
import '../utils/key_rows.dart';

class AlphanumericKeyboard extends StatefulWidget {
  const AlphanumericKeyboard({
    this.controller,
    this.quillController,
    this.height = 260,
    this.backgroundColor = const Color(0xff0a0a0a),
    this.actionKeyColor = const Color(0xff171717),
    this.alphanumericKeyColor = const Color(0xff2d2d2d),
    this.showSpaceKeyIcon = false,
    this.numericKeyTextStyle,
    this.alphaNumericKeyTextStyle,
    this.spaceKeyIcon,
    this.enterKeyIcon,
    this.backspaceKeyIcon,
    this.symbolsKeyIcon,
    this.alphabetKeyIcon,
    this.capsLockKeyIcon,
    this.capsUnlockKeyIcon,
    this.firstLetterCapitalizationColor = Colors.blue,
    this.keyBorderRadius = 10,
    this.actionKeyIconColor = Colors.white,
    this.onEnterTapped,
    this.autoUpperCase = false,
    super.key,
  });

  /// The optional controller for text fields
  final TextEditingController? controller;

  /// The optional Quill controller
  final quill.QuillController? quillController;

  /// The height of the keyboard
  final double height;

  /// The color for the keyboard background
  final Color backgroundColor;

  /// The color for the action keys
  final Color actionKeyColor;

  /// The color for the alphanumeric keys
  final Color alphanumericKeyColor;

  /// Whether to show the space key icon or not, default is false
  final bool showSpaceKeyIcon;

  /// The text style for the numeric keys
  final TextStyle? numericKeyTextStyle;

  /// The text style for the alphabets and symbols keys
  final TextStyle? alphaNumericKeyTextStyle;

  /// The icon to show on space key
  final IconData? spaceKeyIcon;

  /// The icon to show on enter key
  final IconData? enterKeyIcon;

  /// The icon to show on backspace key
  final IconData? backspaceKeyIcon;

  /// The icon to show when alphabets tab is opened
  final IconData? symbolsKeyIcon;

  /// The icon to show when symbols tab is opened
  final IconData? alphabetKeyIcon;

  /// The icon to show when all caps is enabled
  final IconData? capsLockKeyIcon;

  /// The icon to show when all caps is disabled [lowerCase, onlyFirstLetter]
  final IconData? capsUnlockKeyIcon;

  /// The icon color when firstLetterCapitalization is enabled
  final Color firstLetterCapitalizationColor;

  /// The border radius for the keys
  final double keyBorderRadius;

  /// Action key icon color
  final Color actionKeyIconColor;

  /// Callback Function for Enter Key
  final Function()? onEnterTapped;

  final bool autoUpperCase;

  @override
  State<AlphanumericKeyboard> createState() => _AlphanumericKeyboardState();
}

class _AlphanumericKeyboardState extends State<AlphanumericKeyboard> {
  Capitalization capitalization = Capitalization.onlyFirstLetter;

  KeyBoardType keyboardType = KeyBoardType.alphanumeric;
  Timer? backspaceTimer;

  @override
  void dispose() {
    // Annuleer de timer
    backspaceTimer?.cancel();
    backspaceTimer = null;
    super.dispose();
  }

  void _insertText(String text) {
    if (widget.autoUpperCase) {
      text = text.toUpperCase();
    }

    if (widget.controller != null) {
      final currentText = widget.controller!.text;
      final selection = widget.controller!.selection;

      // Validatie van selectie
      if (selection.start < 0 || selection.start > currentText.length) {
        return; // Ongeldige selectie
      }

      // Voeg tekst in
      final newText = currentText.replaceRange(
        selection.start,
        selection.end,
        text,
      );

      // Update cursorpositie
      final newCursorOffset = selection.start + text.length;

      // Update TextEditingController
      widget.controller!.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newCursorOffset),
      );
    } else if (widget.quillController != null) {
      final selection = widget.quillController!.selection;
      widget.quillController!.replaceText(
        selection.start,
        selection.end - selection.start,
        text,
        TextSelection.collapsed(offset: selection.start + text.length),
      );
    }
  }

  void _deleteText() {
    if (widget.quillController != null) {
      final selection = widget.quillController!.selection;
      if (selection.baseOffset > 0 && selection.isCollapsed) {
        widget.quillController!.replaceText(
          selection.baseOffset - 1,
          1,
          '',
          TextSelection.collapsed(offset: selection.baseOffset - 1),
        );
      }
    } else if (widget.controller != null) {
      if (widget.controller!.text.isNotEmpty) {
        final currentText = widget.controller!.text;
        final selection = widget.controller!.selection;

        // Zorg dat de selectie geldig is
        if (selection.start > 0 && selection.start <= currentText.length) {
          // Verwijder één teken links van de cursor
          final newText = currentText.replaceRange(
            selection.start - 1,
            selection.start,
            '',
          );

          // Update de controller met de nieuwe tekst en cursorpositie
          widget.controller!.value = TextEditingValue(
            text: newText,
            selection: TextSelection.collapsed(offset: selection.start - 1),
          );
        }
      }
    }
  }

  Widget keyboardRow(List<String> keys) {
    bool isLastRow = keys == KeyRows.lastRow;

    final double keyWidth = (MediaQuery.of(context).size.width - 20) /
        keys.length; // Dynamische breedte voor niet-spatie toetsen

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: keys.map((e) {
        if (isLastRow && e == SpecialKey.space.name) {
          // Speciale behandeling voor de spatiebalk
          return Expanded(
            flex: 4, // Maak de spatiebalk groter
            child: actionKey(SpecialKey.space),
          );
        } else {
          // Normale breedte voor andere toetsen
          return Flexible(
            flex: 1, // Standaardgrootte voor andere knoppen
            child: SizedBox(
              width: keyWidth,
              child: e.length > 1
                  ? actionKey(SpecialKey.values.firstWhere(
                      (element) => element.name == e,
                    ))
                  : alphabetKey(e),
            ),
          );
        }
      }).toList(),
    );
  }

  Widget numberKey(String kKey) {
    return InkWell(
      onTap: () {
        _insertText(kKey);
      },
      borderRadius: BorderRadius.circular(widget.keyBorderRadius),
      child: Container(
        decoration: BoxDecoration(
          color: widget.alphanumericKeyColor,
          borderRadius: BorderRadius.circular(widget.keyBorderRadius),
        ),
        constraints: const BoxConstraints(
          minWidth: 30,
          minHeight: 35,
        ),
        margin: const EdgeInsets.all(3.5),
        child: Center(
          child: Text(
            kKey,
            style: widget.numericKeyTextStyle ??
                const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
      ),
    );
  }

  Widget alphabetKey(String kKey) {
    return InkWell(
      onTap: () {
        _insertText(
          capitalization == Capitalization.lowerCase
              ? kKey.toLowerCase()
              : kKey.toUpperCase(),
        );
        if (capitalization == Capitalization.onlyFirstLetter) {
          setState(() {
            capitalization = Capitalization.lowerCase; // Reset naar lowercase
          });
        }
      },
      borderRadius: BorderRadius.circular(widget.keyBorderRadius),
      child: Container(
        decoration: BoxDecoration(
          color: widget.alphanumericKeyColor,
          borderRadius: BorderRadius.circular(widget.keyBorderRadius),
        ),
        constraints: const BoxConstraints(
          minWidth: 30,
          minHeight: 40,
        ),
        margin: const EdgeInsets.all(3.5),
        child: Center(
          child: Text(
            capitalization == Capitalization.lowerCase
                ? kKey.toLowerCase()
                : kKey.toUpperCase(),
            style: widget.alphaNumericKeyTextStyle ??
                const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
      ),
    );
  }

  Widget actionKey(SpecialKey kKey) {
    void startBackspaceRepeat() {
      if (backspaceTimer != null) return;
      log("DEBUG: Backspace timer has started");
      backspaceTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
        _deleteText();
      });
    }

    void stopBackspaceRepeat() {
      if (backspaceTimer != null) {
        log("DEBUG: Backspace timer has stopped");
        backspaceTimer!.cancel();
        backspaceTimer = null;
      }
    }

    return GestureDetector(
      onTap: () {
        if (kKey == SpecialKey.backspace) {
          _deleteText();
        } else if (kKey == SpecialKey.space) {
          _insertText(' ');
        } else if (kKey == SpecialKey.enter) {
          if (widget.onEnterTapped != null) {
            widget.onEnterTapped!();
          } else {
            _insertText('\n');
          }
        } else if (kKey == SpecialKey.capsLock) {
          setState(() {
            // Toggle de capitalization-status
            if (capitalization == Capitalization.upperCase) {
              capitalization = Capitalization.lowerCase;
            } else if (capitalization == Capitalization.lowerCase) {
              capitalization = Capitalization.upperCase;
            } else if (capitalization == Capitalization.onlyFirstLetter) {
              capitalization = Capitalization.upperCase;
            }
          });
        }
      },
      onLongPress: () {
        if (kKey == SpecialKey.backspace) {
          startBackspaceRepeat();
        }
      },
      onLongPressUp: () {
        if (kKey == SpecialKey.backspace) {
          stopBackspaceRepeat();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: widget.actionKeyColor,
          borderRadius: BorderRadius.circular(widget.keyBorderRadius),
        ),
        constraints: const BoxConstraints(
          minWidth: 30,
          minHeight: 40,
        ),
        margin: const EdgeInsets.all(3.5),
        child: Center(
          child: getActionKeyIcon(kKey),
        ),
      ),
    );
  }

  Widget? getActionKeyIcon(SpecialKey key) {
    IconData iconData;
    Color iconColor = widget.actionKeyIconColor;
    double iconSize = 24;

    if (key == SpecialKey.capsLock) {
      iconData = capitalization == Capitalization.upperCase
          ? widget.capsLockKeyIcon ?? Icons.arrow_upward
          : widget.capsUnlockKeyIcon ?? Icons.arrow_upward;

      if (capitalization == Capitalization.onlyFirstLetter) {
        iconColor = widget.firstLetterCapitalizationColor;
      } else if (capitalization == Capitalization.upperCase) {
        iconColor = widget.firstLetterCapitalizationColor;
      }
    } else if (key == SpecialKey.backspace) {
      iconData = widget.backspaceKeyIcon ?? Icons.backspace_outlined;
    } else if (key == SpecialKey.space) {
      iconData = widget.spaceKeyIcon ?? Icons.space_bar;
      if (widget.showSpaceKeyIcon == false) {
        iconColor = widget.actionKeyColor;
      }
    } else if (key == SpecialKey.enter) {
      iconData = widget.enterKeyIcon ?? Icons.keyboard_return;
    } else {
      iconData = keyboardType == KeyBoardType.alphanumeric
          ? widget.symbolsKeyIcon ?? Icons.emoji_symbols
          : widget.alphabetKeyIcon ?? Icons.abc;
    }

    return Icon(
      iconData,
      color: iconColor,
      size: iconSize,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: widget.height,
      color: widget.backgroundColor,
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          keyboardRow(KeyRows.numbersRow),
          keyboardRow(keyboardType == KeyBoardType.alphanumeric
              ? KeyRows.alphabetsTopRow
              : KeyRows.symbolsTopRow),
          keyboardRow(keyboardType == KeyBoardType.alphanumeric
              ? KeyRows.alphabetsMiddleRow
              : KeyRows.symbolsMiddleRow),
          keyboardRow(keyboardType == KeyBoardType.alphanumeric
              ? KeyRows.alphabetsBottomRow
              : KeyRows.symbolsBottomRow),
          keyboardRow(KeyRows.lastRow),
        ],
      ),
    );
  }
}
