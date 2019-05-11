module fss.drivers.mdfind;

import fss.context;
import fss.driver;
import fss.conf;
import std.process;
import std.format;
import std.string;
import std.stdio;
import std.regex;
import std.file;

class MdfindDriver : FSSDriver {
  override DriverType type() {
    return DriverType.Mdfind;
  }

  override void showHelp(FSSConfig conf) {
    auto o = executeShell("%s -h".format(conf.bin_path));
    o.output.writeln;
  }

  override void enableFullMatch(FSSContext ctx, string full_match_str) {
    ctx.enableFilterWith("^%s$".format(full_match_str));
    ctx.args ~= "-name %s".format(full_match_str);

    ctx.setFilterFunc((string line) {
      import std.path, std.regex, std.string;

      string base_name = baseName(line);

      return !base_name.matchAll(ctx.rg_filter).empty;
    });
  }

  override void enableSearchUnderDir(FSSContext ctx, string dir) {
    ctx.args ~= "-onlyin %s".format(dir);
  }
}
