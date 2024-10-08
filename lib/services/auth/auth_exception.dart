//login exception
class InvaliCredentialAuthException implements Exception {}
class UserNotFoundAuthException implements Exception {}

//register exception
class EmailExistAuthException implements Exception {}

class WeakPasswordAuthException implements Exception {}

class InvalidEmailAuthException implements Exception {}
//generic exeptionns
class GenericAuthException implements Exception {}


class UseNotLoggedINAuthException implements Exception {}