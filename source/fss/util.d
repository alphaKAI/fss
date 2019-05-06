module fss.util;
import std.format, std.stdio, std.json;
import std.path, std.file, std.string;
import std.regex, std.typecons;
import fss.conf;
import fss.driver;
import fss.drivers.locate;

enum SettingFileDirs = ["~/.config/fss", "~/.myscripts/fss"];
enum SettingFileName = "setting.json";

FSSConfig readSettingFile() {
  FSSConfig conf = new FSSConfig;
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
  if ("bin_path" !in parsed.object) {
    throw new Exception("Please specify bin_path in setting file.");
  }
  conf.bin_path = parsed.object["bin_path"].str;

  if ("driver" !in parsed.object) {
    throw new Exception("Please specify driver type in setting file.");
  }
  string driver_str = parsed.object["driver"].str;
  switch (driver_str) with (DriverType) {
  case Locate:
    conf.type = Locate;
    break;
  default:
    throw new Exception("Unknown driver was specified : " ~ driver_str);
  }

  if ("opts" in parsed.object) {
    foreach (elem; parsed.object["opts"].array) {
      conf.opts ~= elem.str;
    }
  }

  if ("rep_table" in parsed.object) {
    foreach (k, v; parsed.object["rep_table"].object) {
      conf.rep_table ~= tuple(k.regex, v.str);
    }
  }

  if ("fss_opts" in parsed.object) {
    foreach (elem; parsed.object["fss_opts"].array) {
      conf.fss_opts ~= elem.str;
    }
  }

  return conf;
}
