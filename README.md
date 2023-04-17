

This package is endorsed, which means you can simply use shared_preferences normally. 
This package will be automatically included in your app when you do, so you do not need to add it to your pubspec.yaml.

## Features

OnePref offers the same functionality shared_preferences package offers, so in this package you will easily access the
shared_preferences methods everywhere in your app.

## Getting started

```dart
flutter pub add onepref
```

```dart
import 'package:onepref/onepref.dart' 
```

```dart
//This can be your splash screen or Main.dart
 @override
  void initState() {
    super.initState();

    //Call this to activate the OnePref sharedPreference instance
    OnePref.init();
  }

```

## Usage

```dart
To Write

OnePref.setString("key","value here");
```

```dart
Get the Value

const value = OnePref.getString("key");
```

