part of http;

class HeaderInterceptor extends InterceptorsWrapper {
  @override
  Future<dynamic> onRequest(RequestOptions options) async {
    options.connectTimeout = 1000 * 15;
    options.receiveTimeout = 10000 * 15;
    // options.headers['API-Key'] = Config.apiKey;
    // if (Global.instance?.userInfo?.token != null) {
    //   print('添加头');
    //   options.headers['Authorization'] =
    //       'Bearer ' + Global.instance.userInfo.token;
    // } else {}
    return super.onRequest(options);
  }

  @override
  Future<dynamic> onResponse(Response<dynamic> response) {
    DioUtils.cancelToken = null;
    return super.onResponse(response);
  }
}

class ErrorInterceptor extends InterceptorsWrapper {
  @override
  Future onError(DioError err) {
    switch (err.type) {
      case DioErrorType.RESPONSE:
        String message = '';
        final String content = err.response.data.toString();
        // Log.d(err.response.data.runtimeType);
        // Log.d('$this ------>content---->$content');
        if (content != '') {
          // Log.d('content不为空');
          try {
            // Log.d(err.response.data.toString());
            final Map<String, dynamic> decode =
                err.response.data as Map<String, dynamic>;
            // Log.d('$this-------error---->$decode');
            //TODO
            message = decode['error'] as String;
          } catch (error) {
            message = error.toString();
          }
        }

        // Log.d('$this ---->$message');
        final int status = err.response.statusCode;

        switch (status) {
          case HttpStatus.badRequest:
            throw AuthorizationException(status: status, message: message);
            break;
          case HttpStatus.unauthorized:
            throw AuthorizationException(status: status, message: message);
            break;
          case HttpStatus.forbidden:
            throw AuthorizationException(status: status, message: message);
            break;
          case HttpStatus.networkConnectTimeoutError:
            throw NetworkException(status: status, message: '连接超时');
            break;
          case HttpStatus.unprocessableEntity:
            throw ValidationException(status: status, message: message);
            break;
          default:
            throw StatusException(status: status, message: message);
        }
        break;
      case DioErrorType.CANCEL:
        DioUtils.cancelToken = null;
        throw CancelRequestException(
            status: HttpStatus.clientClosedRequest, message: err.toString());
        break;
      default:
        throw NetworkException(
            status: HttpStatus.networkConnectTimeoutError,
            message: err.message);
    }
  }
}
