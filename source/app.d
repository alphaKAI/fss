import std.stdio;
import std.typecons;
import std.regex;
import std.path;
import std.file;
import std.process;
import std.string;
import std.format;
import fss.driver;
import fss.conf;
import fss.util;
import fss.context;

// dfmt off
alias OptionDescripter = Tuple!(string, "full_name", string, "short_name", string, "description");
OptionDescripter[] fss_options = [
  OptionDescripter("--filter-current", "--fc", "filter by current directory name"),
  OptionDescripter("--filter-with", "--fw", "filter by user specified regex pattern"),
  OptionDescripter("--no-filter", "--nf", "no filter"),
  OptionDescripter("--full-match", "--fm", "full match file name"),
  OptionDescripter("--help", "-h", "Show usage"),
  OptionDescripter("--locate-help", "--lh", "Show usage of locate command")
];
// dfmt on

void parse_fss_opt(FSSContext ctx, ref string[] fss_opts, bool remove_fss_opt = false) {
  // args から fss用のオプションを取り除くため．
  string[] tmp;
  bool skip;
  foreach (i, fss_opt; fss_opts) {
    if (skip) {
      skip = false;
      continue;
    }

    if (fss_opt == "--fc" || fss_opt == "--filter-current") {
      ctx.doFilter = true;
      ctx.rg_filter = getcwd().regex;
      continue;
    }

    if (fss_opt == "--fw" || fss_opt == "--filter-with") {
      if (!(i + 1 < fss_opts.length)) {
        throw new Error("--filter-with required one param");
      }
      ctx.doFilter = true;
      skip = true;
      ctx.rg_filter = fss_opts[i + 1].regex;
      continue;
    }

    if (fss_opt == "--nf" || fss_opt == "--no-filter") {
      ctx.doFilter = false;
      continue;
    }

    if (fss_opt == "--fm" || fss_opt == "--full-match") {
      if (!(i + 1 < fss_opts.length)) {
        throw new Error("--full-match required one param");
      }
      ctx.full_match = true;
      ctx.full_match_str = fss_opts[i + 1];
      skip = true;
      continue;
    }

    if (fss_opt == "-h" || fss_opt == "--help") {
      import core.stdc.stdlib;

      writeln("fss - fast file searcher with locate command");
      writeln("options...");
      foreach (option; fss_options) {
        writefln("\t %s|%s : %s", option.full_name, option.short_name, option.description);
      }

      exit(EXIT_SUCCESS);
    }

    if (fss_opt == "--lh" || fss_opt == "--locate-help") {
      import core.stdc.stdlib;

      ctx.showHelp();
      exit(EXIT_SUCCESS);
      break;
    }

    tmp ~= fss_opt;
  }

  if (remove_fss_opt) {
    fss_opts = tmp;
  }
}

void main(string[] args) {
  args = args[1 .. $];
  bool doFilter;
  string filterRule;

  auto conf = readSettingFile();
  auto ctx = FSSContext.makeContextFromConf(conf);
  ctx.args = args;

  parse_fss_opt(ctx, ctx.conf.fss_opts);
  parse_fss_opt(ctx, ctx.args, true);

  ctx.search;
}
