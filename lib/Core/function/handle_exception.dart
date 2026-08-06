import 'package:live_chat/Core/class/status_request.dart';

import 'custom_exception.dart';

handleException(dynamic e) {
  if (e is BadRequestException) {
    return StatuesRequest.badRequestException;
  } else if (e is UnauthorizedException) {
    return StatuesRequest.unauthorizedException;
  } else if (e is ForbiddenException) {
    return StatuesRequest.forbiddenException;
  } else if (e is ConflictException) {
    return StatuesRequest.conflictException;
  } else if (e is FormatException) {
    return StatuesRequest.formatException;
  } else {
    return StatuesRequest.unExpectedException;
  }
}
