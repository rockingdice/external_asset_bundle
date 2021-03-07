library external_asset_bundle;

import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;

class ExternalAssetBundle implements AssetBundle {
  String _path;
  Map<String, dynamic> _cache = {};
  bool _enableBinaryCache;

  ExternalAssetBundle(String path,
      {bool enableBinaryCache = false}) {
    if (!path.endsWith('/')) {
      path += '/';
    }
    _path = path;
    _enableBinaryCache = enableBinaryCache;
  }

  @override
  void evict(String key) {
    _cache.remove(key);
  }

  @override
  Future<ByteData> load(String key) async {
    if (_enableBinaryCache && _cache.containsKey(key)) {
      return _cache[key];
    }
    try {
      File file = File(_path + key);
      var value = await file.readAsBytes();
      var bd = value.buffer.asByteData();
      if (_enableBinaryCache) {
        _cache[key] = bd;
      }
      return bd;
    } catch (err, stack) {
      throw err;
    }
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    if (cache && _cache.containsKey(key)) {
      return _cache[key];
    }

    try {
      File file = File(_path + key);
      var value = await file.readAsString();
      if (cache) {
        _cache[key] = value;
      }
      return value;
    } catch (err, stack) {
      throw err;
    }
  }

  @override
  Future<T> loadStructuredData<T>(
      String key, Future<T> Function(String value) parser) async {
    if (key == 'AssetManifest.json') {
      //generate this file based on folder structure
      Directory dir = Directory(_path);
      var manifest = <String, dynamic>{};
      void addJsonEntry(String key, String value) {
        var arr = <String>[];
        if (!manifest.containsKey(key)) {
          manifest[key] = arr;
        }
        arr.add(value);
      }

      dir.listSync(recursive: true).forEach((f) {
        if (f is Directory) {
        } else if (f is File) {
          var p = f.path;
          var key = path.basename(p);
          var value = path.relative(path.dirname(p), from: _path) + '/$key';
          addJsonEntry(key, value);
        }
      });
      return parser(json.encode(manifest));
    }
    if (_enableBinaryCache && _cache.containsKey(key)) {
      return _cache[key];
    }

    try {
      File file = File(_path + key);
      var value = await file.readAsString();
      var parsed = await parser(value);
      if (_enableBinaryCache) {
        _cache[key] = parsed;
      }
      return parsed;
    } catch (err, stack) {
      throw err;
    }
  }
}
