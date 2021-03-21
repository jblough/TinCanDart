class LRSResponse<T> {
  final bool? success;
  final String? errMsg;
  final T? data;

  LRSResponse({this.success, this.errMsg, this.data});
}
