// Function used to handle status request from API responses.

import '../class/status_request.dart';

StatuesRequest handlingData(dynamic response) {
  if (response is StatuesRequest) {
    return response;
  } else if (response is String) {
    return StatuesRequest.serverError;
  } else {
    return StatuesRequest.success;
  }
}
