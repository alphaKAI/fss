module fss.driver;
import fss.conf;
import fss.context;

enum DriverType : string {
  Locate = "locate"
}

interface FSSDriver {
  DriverType type();
  void showHelp(FSSConfig conf);
  void search(FSSContext ctx);
  void setFullMatch(FSSContext ctx, string full_match_str);
}
