module fss.drivers.locate;
import fss.context;
import fss.driver;
import fss.conf;
import std.process;
import std.format;
import std.string;
import std.stdio;
import std.regex;
import std.file;

class LocateDriver : FSSDriver {
  override DriverType type() {
    return DriverType.Locate;
  }

  override void showHelp(FSSConfig conf) {
    auto o = executeShell("%s -h".format(conf.bin_path));
    o.output.writeln;
  }

  override void enableFullMatch(FSSContext ctx, string full_match_str) {
    ctx.args ~= `--regexp "^%s$" -b`.format(full_match_str);
  }

  override void enableSearchUnderDir(FSSContext ctx, string dir) {
    ctx.do_filter = true;
    ctx.rg_filter = getcwd().regex;
  }
}
