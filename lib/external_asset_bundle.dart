library external_asset_bundle;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as pathPkg;

class ExternalAssetBundle implements AssetBundle {
  final String path;
  final Map<String, dynamic> _cache = <String, dynamic>{};
  final bool enableBinaryCache;

  ExternalAssetBundle(this.path, {this.enableBinaryCache = false});

  @override
  void evict(String key) => _cache.remove(key);

  @override
  Future<ByteData> load(String key) async {
    dynamic result = _cache[key];
    if (result == null) {
      final file = File(pathPkg.join(path, key));
      final value = await file.readAsBytes();
      result = value.buffer.asByteData();
      if (enableBinaryCache) {
        _cache[key] = result;
      }
    }
    return result;
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    dynamic result = cache ? _cache[key] : null;

    final file = File(pathPkg.join(path, key));
    result = await file.readAsString();
    if (cache) {
      _cache[key] = result;
    }

    return result;
  }

  void _addJsonEntry(Map<String, List<String>> manifest, String key, String value) {
    final arr = manifest.putIfAbsent(key, () => <String>[]);
    arr.add(value);
  }

  Future<T> _handleAssetManifest<T>(Future<T> Function(String value) parser) async {
    //generate this file based on folder structure
    final dir = Directory(path);
    final manifest = <String, List<String>>{};
    dir.listSync(recursive: true).forEach((f) {
      if (f is Directory) {
        //TODO: Implement?
      } else if (f is File) {
        final key = pathPkg.basename(f.path);
        final value = pathPkg.relative(pathPkg.dirname(f.path), from: path);
        _addJsonEntry(manifest, key, pathPkg.join(value, key));
      }
    });
    return parser(json.encode(manifest));
  }

  @override
  Future<T> loadStructuredData<T>(String key, Future<T> Function(String value) parser) async {
    T? result;
    if (key == 'AssetManifest.json') {
      //generate this file based on folder structure
      result = await _handleAssetManifest(parser);
    } else {
      final file = File(pathPkg.join(path, key));
      final value = await file.readAsString();
      result = await parser(value);
      if (enableBinaryCache) {
        _cache[key] = result;
      }
    }
    return result!;
  }

  @override
  void clear() => _cache.clear();

  @override
  Future<ImmutableBuffer> loadBuffer(String key) {
    // TODO: implement loadBuffer
    throw UnimplementedError();
  }

  @override
  Future<T> loadStructuredBinaryData<T>(String key, FutureOr<T> Function(ByteData data) parser) {
    // TODO: implement loadStructuredBinaryData
    throw UnimplementedError();
  }
}
