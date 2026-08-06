//my all status
enum StatuesRequest {
  success,
  loading,
  socketException,
  timeoutException,
  badRequestException,
  unauthorizedException,
  forbiddenException,
  conflictException,
  serverException,
  serverError,
  defaultException,
  formatException,
  unExpectedException,
  clientException,
  none,
  unprocessableException,
}

//success
//loading
//No internet connection. Please check your connection and try again.
//The request timed out. Please try again later.
//Bad request. Please check your input and try again.
//Unauthorized access. Please check your credentials and try again.
//Access forbidden. You do not have permission to access this resource
//A conflict occurred. Please try again.
//The requested resource was not found.
//The server is currently unavailable. Please try again later
//Failed to complete the operation. Please try again.
//Data format error. Please contact support.
//An unexpected error occurred. Please try again.
//Network error. Please check your connection and try again.
//none