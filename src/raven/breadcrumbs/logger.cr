require "logger"

class Logger
  private LOGGER_BREADCRUMB_LEVELS = {
    Severity::DEBUG => Raven::Breadcrumb::Severity::DEBUG,
    Severity::INFO  => Raven::Breadcrumb::Severity::INFO,
    Severity::WARN  => Raven::Breadcrumb::Severity::WARNING,
    Severity::ERROR => Raven::Breadcrumb::Severity::ERROR,
    Severity::FATAL => Raven::Breadcrumb::Severity::CRITICAL,
  }

  protected def self.ignored_logger?(progname)
    Raven.configuration.exclude_loggers.includes?(progname)
  end

  private def write(severity, datetime, progname, message)
    unless self.class.ignored_logger?(progname)
      Raven.breadcrumbs.record do |crumb|
        crumb.timestamp = datetime
        crumb.level = LOGGER_BREADCRUMB_LEVELS[severity]?
        crumb.category = progname || "logger"
        crumb.message = message
      end
    end
    previous_def
  end
end
