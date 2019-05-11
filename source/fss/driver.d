module fss.driver;
import fss.conf;
import fss.context;
import std.functional;
import std.string, std.regex;
import std.process, std.stdio;

enum DriverType : string {
  Locate = "locate",
  Mdfind = "mdfind"
}

abstract class FSSDriver {
  bool delegate(string) filterFunc;

  abstract DriverType type();
  abstract void showHelp(FSSConfig conf);

  void search(FSSContext ctx) {
    if (this.filterFunc == null) {
      this.filterFunc = (string line) {
        return !line.matchAll(ctx.rg_filter).empty;
      };
    }

    string cmd = "%s %s %s".format(ctx.conf.bin_path, ctx.conf.opts.join(" "), ctx.args.join(" "));
    auto pipes = pipeShell(cmd, Redirect.stdout | Redirect.stderr);
    scope (exit)
      wait(pipes.pid);
    foreach (line; pipes.stdout.byLine) {
      // pathの読み替えをする．
      foreach (t; ctx.conf.rep_table) {
        line = line.replaceAll(t[0], t[1]);
      }

      if (ctx.do_filter) {
        if (filterFunc(cast(string)line)) {
          writeln(line);
        }
      } else {
        writeln(line);
      }
    }
  }

  abstract void enableFullMatch(FSSContext ctx, string full_match_str);
  abstract void enableSearchUnderDir(FSSContext ctx, string dir);

  void setFilterFunc(bool function(string) f) {
    this.setFilterFunc(toDelegate(f));
  }

  void setFilterFunc(bool delegate(string) f) {
    this.filterFunc = f;
  }
}
