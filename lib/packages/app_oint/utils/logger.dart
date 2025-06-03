import 'package:logging/logging.dart';

final Logger logger = Logger('APP-OINT');

void logError(String message) {
  logger.severe(message);
}

void logInfo(String message) {
  logger.info(message);
}

void logWarning(String message) {
  logger.warning(message);
}
