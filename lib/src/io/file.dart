import 'file_entity.dart';

class NiFile extends FileEntity {
  NiFile(this._path,this._fullInfo);
  final String _path;
  @override
  String get path=>_path;
  final String _fullInfo;
  @override
  String get fullInfo=>_fullInfo;
}
