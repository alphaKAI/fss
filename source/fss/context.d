module fss.context;
import fss.conf;
import fss.driver;
import fss.drivers.locate;
import std.regex;

class FSSContext {
  FSSDriver driver;
  FSSConfig conf;
  string[] args;
  bool doFilter;
  bool full_match;
  string full_match_str;
  Regex!char rg_filter;

  this(FSSDriver driver, FSSConfig conf) {
    this.driver = driver;
    this.conf = conf;
  }

  void showHelp() {
    this.driver.showHelp(this.conf);
  }

  static FSSContext makeContextFromConf(FSSConfig conf) {
    FSSDriver driver;

    final switch (conf.type) with (DriverType) {
    case Locate:
      driver = new LocateDriver;
      break;
    }

    return new FSSContext(driver, conf);
  }

  void search() {
    if (this.full_match) {
      this.driver.setFullMatch(this, this.full_match_str);
    }
    this.driver.search(this);
  }
}
