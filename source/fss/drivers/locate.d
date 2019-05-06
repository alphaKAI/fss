module fss.drivers.locate;
import fss.context;
import fss.driver;
import fss.conf;
import std.process;
import std.format;
import std.string;
import std.stdio;
import std.regex;

class LocateDriver : FSSDriver {
  DriverType type() {
    return DriverType.Locate;
  }

  void showHelp(FSSConfig conf) {
    auto o = executeShell("%s -h".format(conf.bin_path));
    o.output.writeln;
  }

  void setFullMatch(FSSContext ctx, string full_match_str) {
    ctx.args ~= `--regexp "^%s$" -b`.format(full_match_str);
  }

  void search(FSSContext ctx) {
    string cmd = "%s %s %s".format(ctx.conf.bin_path, ctx.conf.opts.join(" "), ctx.args.join(" "));
    auto pipes = pipeShell(cmd, Redirect.stdout | Redirect.stderr);
    scope (exit)
      wait(pipes.pid);
    foreach (line; pipes.stdout.byLine) {
      // pathの読み替えをする．
      foreach (t; ctx.conf.rep_table) {
        line = line.replaceAll(t[0], t[1]);
      }

      if (ctx.doFilter) {
        if (!line.matchAll(ctx.rg_filter).empty) {
          writeln(line);
        }
      } else {
        writeln(line);
      }
    }
  }
}
