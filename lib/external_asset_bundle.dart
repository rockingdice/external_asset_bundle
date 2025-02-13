library external_asset_bundle;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;

class ExternalAssetBundle implements AssetBundle {
  late String _path;
  Map<String, dynamic> _cache = {};
  late bool _enableBinaryCache;

  ExternalAssetBundle(String path, {bool enableBinaryCache = false}) {
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
    } catch (err) {
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
    } catch (err) {
      throw err;
    }
  }

  @override
  Future<T> loadStructuredData<T>(String key, Future<T> Function(String value) parser) async {
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
    } catch (err) {
      throw err;
    }
  }

  @override
  Future<ImmutableBuffer> loadBuffer(String key) async {
    if (_enableBinaryCache && _cache.containsKey(key)) {
      return _cache[key];
    }

    try {
      File file = File(_path + key);
      var value = await file.readAsBytes();
      var data = ImmutableBuffer.fromUint8List(Uint8List.sublistView(value));
      if (_enableBinaryCache) {
        _cache[key] = data;
      }
      return data;
    } catch (err) {
      throw err;
    }
  }

  @override
  Future<T> loadStructuredBinaryData<T>(String key, FutureOr<T> Function(ByteData data) parser) async {
    if (key == 'AssetManifest.bin') {
      //generate this file based on folder structure
      Directory dir = Directory(_path);
      var manifest = <String, List<Map<String, dynamic>>>{};
      void addJsonEntry(String key, String path, {double? dpr}) {
        var arr = <Map<String, dynamic>>[];
        if (!manifest.containsKey(key)) {
          manifest[key] = arr;
        } else {
          arr = manifest[key]!;
        }
        var obj = <String, dynamic>{'asset': path};

        if (dpr != null) {
          obj['dpr'] = dpr;
        }
        arr.add(obj);
      }

      // var bundle_root_path = _path;
      dir.listSync(recursive: true).forEach((f) {
        if (f is Directory) {
        } else if (f is File) {
          var p = f.path;
          // var key = path.basename(p);
          var value = path.relative(p, from: _path);

          var p_dir = path.dirname(p);
          if (p_dir.endsWith('x')) {
            var dirname = path.basename(p_dir);
            var parsed_dpi = double.tryParse(dirname.substring(0, dirname.length - 1));
            if (parsed_dpi != null) {
              //可能是个dpi，查找对应文件是否存在
              var base_filepath = path.normalize(path.dirname(p_dir) + '/' + path.basename(p));
              if (File(base_filepath).existsSync()) {
                //dpi. 记录到对应条目上
                var base_key = path.relative(base_filepath, from: _path);
                addJsonEntry(base_key, value, dpr: parsed_dpi);
                return;
              }
            }
          }

          addJsonEntry(value, value);
        }
      });
      var out = await const StandardMessageCodec().encodeMessage(manifest);
      // const StandardMessageCodec().encodeMessage(message)
      // final decoded = const StandardMessageCodec()
      // .decodeMessage(ByteData.sublistView(manifest));
      // final assets = decoded.keys.cast<String>().toList();

      // final jsonString = json.encode(manifest);
      // var bytes = utf8.encode(jsonString);

      // final byteData = utf8.encode(o);
      // return parser(Uint8List.fromList(bytes).buffer.asByteData(0, bytes.length));
      return parser(out!);
    }
    if (_enableBinaryCache && _cache.containsKey(key)) {
      return _cache[key];
    }

    try {
      File file = File(_path + key);
      var value = await file.readAsBytes();
      var parsed = await parser(ByteData.view(value.buffer));
      if (_enableBinaryCache) {
        _cache[key] = parsed;
      }
      return parsed;
    } catch (err) {
      throw err;
    }
  }

  @override
  void clear() {
    _cache.clear();
  }
}
