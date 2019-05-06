import std.stdio, std.string, std.format, std.regex, std.typecons, std.process,
  std.path, std.file, std.json;

struct FSSConfig {
  string locate_path;
  string[] opts;
  string[string] rep_table;
  string[] fss_opts;
}

enum SettingFileDirs = ["~/.config/fss", "~/.myscripts/fss"];
enum SettingFileName = "setting.json";

FSSConfig readSettingFile() {
  FSSConfig conf;
  string sf_path;

  foreach (dir; SettingFileDirs) {
    string target = "%s/%s".format(dir.expandTilde, SettingFileName);
    if (exists(target)) {
      sf_path = target;
    }
  }

  if (sf_path.empty) {
    throw new Exception("Setting file not found. Please create setting file at %s/%s".format(
        SettingFileDirs[0], SettingFileName));
  }

  auto parsed = readText(sf_path).parseJSON;
  if ("locate_path" !in parsed.object) {
    throw new Exception("Please specify locate_path in setting file.");
  }
  conf.locate_path = parsed.object["locate_path"].str;

  if ("opts" in parsed.object) {
    foreach (elem; parsed.object["opts"].array) {
      conf.opts ~= elem.str;
    }
  }

  if ("rep_table" in parsed.object) {
    foreach (k, v; parsed.object["rep_table"].object) {
      conf.rep_table[k] = v.str;
    }
  }

  if ("fss_opts" in parsed.object) {
    foreach (elem; parsed.object["fss_opts"].array) {
      conf.fss_opts ~= elem.str;
    }
  }

  return conf;
}

void main(string[] args) {
  args = args[1 .. $];
  bool doFilter;
  string filterRule;

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

  void parse_fss_opt(ref string[] fss_opts, bool remove_fss_opt = false) {
    // args から fss用のオプションを取り除くため．
    string[] tmp;

    bool skip;
    foreach (i, fss_opt; fss_opts) {
      if (skip) {
        skip = false;
        continue;
      }

      if (fss_opt == "--fc" || fss_opt == "--filter-current") {
        doFilter = true;
        filterRule = getcwd();
        continue;
      }

      if (fss_opt == "--fw" || fss_opt == "--filter-with") {
        if (!(i + 1 < fss_opts.length)) {
          throw new Error("--filter-with required one param");
        }
        doFilter = true;
        skip = true;
        filterRule = fss_opts[i + 1];
        continue;
      }

      if (fss_opt == "--nf" || fss_opt == "--no-filter") {
        doFilter = false;
        continue;
      }

      if (fss_opt == "--fm" || fss_opt == "--full-match") {
        if (!(i + 1 < fss_opts.length)) {
          throw new Error("--full-match required one param");
        }
        tmp ~= `--regexp "^%s$" -b`.format(fss_opts[i + 1]);
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
        tmp = ["-h"];
        break;
      }

      tmp ~= fss_opt;
    }

    if (remove_fss_opt) {
      fss_opts = tmp;
    }
  }

  auto conf = readSettingFile();

  parse_fss_opt(conf.fss_opts);
  parse_fss_opt(args, true);

  string arg = args.join(" ");

  Regex!char rg_filter;
  if (doFilter) {
    rg_filter = regex(filterRule);
  }

  alias RepSet = Tuple!(Regex!char, string);
  RepSet[] rep_table;
  foreach (k, v; conf.rep_table) {
    rep_table ~= tuple(k.regex, v);
  }

  string cmd = "%s %s %s".format(conf.locate_path, conf.opts.join(" "), arg);
  auto pipes = pipeShell(cmd, Redirect.stdout | Redirect.stderr);
  scope (exit)
    wait(pipes.pid);

  foreach (line; pipes.stdout.byLine) {
    // pathの読み替えをする．
    foreach (t; rep_table) {
      line = line.replaceAll(t[0], t[1]);
    }

    if (doFilter) {
      if (!line.matchAll(rg_filter).empty) {
        writeln(line);
      }
    } else {
      writeln(line);
    }
  }
}
