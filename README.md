# THIS IS A FORK OF SOFT KEYBOARD

## Things I added:

- Support for quill
- Cursor doesn't jump to the end of the text anymore
- Longpress backspace
- You can now also disable *-., on numeric_keyboard with bool onlyNumbers

**CREDITS TO ASHIR14 (orignal creator)**
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>

# Soft Keyboard

[![license](https://img.shields.io/github/license/Ashir14/widget_switcher)](https://github.com/Ashir14/soft_keyboard/blob/master/LICENSE)

A customizable soft keyboard to use instead of the built in non-customizable keyboard of any phone.

(This package is still in development)

![Alphanumeric Keyboard 1](screenshots/alphanumeric1.png) ![Alphanumeric Keyboard 1](screenshots/alphanumeric2.png)  
![Numeric Keyboard](screenshots/numeric.png)

## Features

- Customize the background color
- Choose colors of the keys
- Provide IconData for action keys
- Style the keyboard text as per your preference
- Adjust the keyboard height
- Choose between Alphanumeric or Numeric keyboard

## Getting started

In your flutter project add the dependency:

```yaml  
dependencies:  
 soft_keyboard: any  
```  

Import the package:

```dart  
import 'package:soft_keyboard/soft_keyboard.dart';  
```  

## Usage

```dart  
AlphanumericKeyboard(    
  controller: _controller,
  onEnterTapped: () {  
	log("hide keyboard");  
  }, 
  height: 260,    
  backgroundColor: Colors.black,    
  actionKeyColor: Colors.blueGrey,    
  alphanumericKeyColor: Colors.indigo,    
  backspaceKeyIcon: Icons.backspace,
  enterKeyIcon: Icons.keyboard_return,
),
```
```dart  
NumericKeyboard(  
  controller: _controller,  
  onEnterTapped: () {  
    log("hide keyboard");  
  },  
  backgroundColor: Colors.black,  
  actionKeyColor: Colors.blueGrey,  
  backspaceKeyIcon: Icons.backspace,  
  enterKeyIcon: Icons.keyboard_return,  
),
```  
Check the example project for a full example
