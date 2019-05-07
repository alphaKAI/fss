module fss.context;
import fss.conf;
import fss.driver;
import fss.drivers.locate;
import fss.drivers.mdfind;
import std.regex;

class FSSContext {
  FSSDriver driver;
  FSSConfig conf;
  string[] args;
  bool do_filter;
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
    case Mdfind:
      driver = new MdfindDriver;
      break;
    }

    return new FSSContext(driver, conf);
  }

  void search() {
    if (this.full_match) {
      this.driver.enableFullMatch(this, this.full_match_str);
    }
    this.driver.search(this);
  }

  void enableFilterWith(string pattern) {
    this.do_filter = true;
    this.rg_filter = pattern.regex;
  }

  void disableFilter() {
    this.do_filter = false;
  }

  void enableSearchUnderDir(string dir) {
    this.driver.enableSearchUnderDir(this, dir);
  }

  void enableFullMatch(string full_match_str) {
    this.full_match = true;
    this.full_match_str = full_match_str;
  }
}
