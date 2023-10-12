# External Asset Bundle

The External Asset Bundle package works exactly like a `rootBundle` or `DefaultAssetBundle`, 
but loads resources from an external location, like the application or library path. It also 
implements caching for resource loading.

It's useful when you want to use resources from a folder, that is temporary or located on external
storage.

Use `Image.asset` to create an `Image` instance as the default bundle does:
```dart
final externalAssetBundle = ExternalAssetBundle("download/folder/assets");
final image = Image.asset(
      "sample.png",
      bundle: externalAssetBundle,	//Don't forget to use your own AssetBundle!
    );
```

Or load a string file from bundle:
```dart
final stringContent = externalAssetBundle.loadString("some-text-file.txt");
```

Since `ExternalAssetBundle` implements `AssetBundle`, it can be used whenever `AssetBundle` is 
needed.

There is no need to predefine your folder structure in the `pubspec.yaml` file. But you still need
to follow the rules for constructing the default assets folder. 

Read more: [Assets and Images](https://flutter.dev/docs/development/ui/assets-and-images)

## Usage

Before using asset bundle initialize it with selected path:

```dart
import 'package:external_asset_bundle/external_asset_bundle.dart';

final externalAssetBundle = ExternalAssetBundle("path/to/any/folder");
```

From this moment ```externalAssetBundle``` can be used as any ```AssetBundle```:

```dart
final image = Image.asset(
      "sample.png",
      bundle: externalAssetBundle,
    );
final stringContent = externalAssetBundle.loadString("some-text-file.txt");
```

If you manage your folder structure like this:
```
asset-folder/sample.png
asset-folder/2.0x/sample.png
asset-folder/3.0x/sample.png
```
The variant could be correctly found by `Image.asset`.

### Caching

The resources could be cached by initializing the `ExternalAssetBundle` with the `enableBinaryCache`
parameter on:
```dart
final externalAssetBundle = ExternalAssetBundle("path", enableBinaryCache: true);
```

Keep in mind that `loadString` will check cache only if ```cache``` argument is set to true while 
calling method. Otherwise it will always load file.

## Contributors
Owner [RockingDice](https://github.com/rockingdice)
[Toster](https://github.com/thetoster)

## Bug reports

Please report issues on my Github page! 