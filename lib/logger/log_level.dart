class LogLevel {
  static const LOG_LEVEL_DEBUG = 1;
  static const LOG_LEVEL_INFO = 2;
  static const LOG_LEVEL_WARN = 4;
  static const LOG_LEVEL_ERROR = 8;
  static const LOG_LEVEL_FATAL = 16;
  static const LOG_LEVEL_ALWAYS = 32;

  static const LEVEL_NAMES = {
    LOG_LEVEL_DEBUG: 'DEBUG',
    LOG_LEVEL_INFO: 'INFO',
    LOG_LEVEL_WARN: 'WARN',
    LOG_LEVEL_ERROR: 'ERROR',
    LOG_LEVEL_FATAL: 'FATAL',
    LOG_LEVEL_ALWAYS: 'ALWAYS'
  };

  static LogLevel valueOfName(String name) {
    for (int idx in LEVEL_NAMES.keys) {
      if (LEVEL_NAMES[idx] == name) {
        return LogLevel(idx);
      }
    }
    return LogLevel.debug();
  }

  int level;

  LogLevel(int level) {
    this.level = level;
  }

  @override
  int get hashCode => level.hashCode;

  @override
  bool operator ==(Object other) {
    var same =
        identical(this, other) || (other is LogLevel && level == other.level);
    return same;
  }

  bool canUpper() {
    return this.level != LOG_LEVEL_FATAL;
  }

  bool canLower() {
    return this.level != LOG_LEVEL_DEBUG;
  }

  LogLevel upper() {
    if (this.level == LOG_LEVEL_FATAL) {
      return this;
    }
    return LogLevel(this.level << 1);
  }

  LogLevel lower() {
    if (this.level == LOG_LEVEL_DEBUG) {
      return this;
    }
    return LogLevel(this.level >> 1);
  }

  static LogLevel debug() {
    return LogLevel(LOG_LEVEL_DEBUG);
  }

  static LogLevel info() {
    return LogLevel(LOG_LEVEL_INFO);
  }

  static LogLevel warn() {
    return LogLevel(LOG_LEVEL_WARN);
  }

  static LogLevel error() {
    return LogLevel(LOG_LEVEL_ERROR);
  }

  static LogLevel fatal() {
    return LogLevel(LOG_LEVEL_FATAL);
  }

  String name() {
    return LEVEL_NAMES[this.level];
  }
}
