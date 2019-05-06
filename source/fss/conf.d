module fss.conf;
import fss.driver;
import std.typecons;
import std.regex;

alias RepSet = Tuple!(Regex!char, string);

class FSSConfig {
  string bin_path;
  string[] opts;
  RepSet[] rep_table;
  string[] fss_opts;
  DriverType type;
}
