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
  DriverType type() {
    return DriverType.Mdfind;
  }

  void showHelp(FSSConfig conf) {
    auto o = executeShell("%s -h".format(conf.bin_path));
    o.output.writeln;
  }

  void enableFullMatch(FSSContext ctx, string full_match_str) {
    ctx.enableFilterWith("^%s$".format(full_match_str));
    ctx.args ~= "-name %s".format(full_match_str);
  }

  void search(FSSContext ctx) {
    string cmd = "%s %s %s".format(ctx.conf.bin_path, ctx.conf.opts.join(" "), ctx.args.join(" "));
    writeln("cmd: ", cmd);
    auto pipes = pipeShell(cmd, Redirect.stdout | Redirect.stderr);
    scope (exit)
      wait(pipes.pid);
    foreach (line; pipes.stdout.byLine) {
      // pathの読み替えをする．
      foreach (t; ctx.conf.rep_table) {
        line = line.replaceAll(t[0], t[1]);
      }

      if (ctx.do_filter) {
        if (!line.matchAll(ctx.rg_filter).empty) {
          writeln(line);
        }
      } else {
        writeln(line);
      }
    }
  }

  void enableSearchUnderDir(FSSContext ctx, string dir) {
    ctx.args ~= "-onlyin %s".format(dir);
  }
}
