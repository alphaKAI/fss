module fss.driver;
import fss.conf;
import fss.context;

enum DriverType : string {
  Locate = "locate",
  Mdfind = "mdfind"
}

interface FSSDriver {
  DriverType type();
  void showHelp(FSSConfig conf);
  void search(FSSContext ctx);
  void enableFullMatch(FSSContext ctx, string full_match_str);
  void enableSearchUnderDir(FSSContext ctx, string dir);
}
