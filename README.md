# External Asset Bundle

The External Asset Bundle package works exactly like a `rootBundle` or `DefaultAssetBundle`, but loads resources from an external location like the application or library path. It also implements caching for resource loading.

It's very useful if you want to use resources from a folder that is temporary or located on external storage.

You can use `Image.asset` to create an `Image` instance as the default bundle does:
```dart
var externalAssetBundle = ExternalAssetBundle("download/folder/assets");
var image = Image.asset(
      "sample.png",
      bundle: externalAssetBundle,	//Don't forget to use your own AssetBundle!
    );
```

Or load a string file from the path very easily:
```dart
var stringContent = externalAssetBundle.loadString("some-text-file.txt");
```

The `ExternalAssetBundle` implements the abstract class of `AssetBundle`, so it should work every place that needs an `AssetBundle`.

Additionaly, you won't need to predefine your folder structure in the `pubspec.yaml` file. The folder structure is obtained dynamically. But you still need to follow the rules for constructing the default assets folder. 

Read more: [Assets and Images](https://flutter.dev/docs/development/ui/assets-and-images)

## Installation

Add external_asset_bundle as dependency to your pubspec file.

```
external_asset_bundle: 1.0.0
```

## Usage

### Initialization
The only thing you need to do is to create an `ExternalAssetBundle` instance:
```dart
import 'package:external_asset_bundle/external_asset_bundle.dart';

var externalAssetBundle = ExternalAssetBundle("path/to/any/folder");
```

### Use it!
You can use it as any AssetBundle:
```dart
var image = Image.asset(
      "sample.png",
      bundle: externalAssetBundle,
    );
var stringContent = externalAssetBundle.loadString("some-text-file.txt");
```

If you manage your folder structure like this:
```
asset-folder/sample.png
asset-folder/2.0x/sample.png
asset-folder/3.0x/sample.png
```
The variant could be correctly found by `Image.asset`.

### Caching
The resources could be cached by initializing the `ExternalAssetBundle` with the `enableBinaryCache`  parameter on:
```dart
var externalAssetBundle = ExternalAssetBundle("path", enableBinaryCache:true);
```

But `loadString` will use its own `cache` paramter to determine whether to use the caching.

## Contribution

Please report issues on my Github page! 