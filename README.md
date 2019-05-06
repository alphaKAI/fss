# fss - fast file searcher

## これは何
高速なファイル検索を行うためのツール．  
もともとは，[mlocate](https://pagure.io/mlocate) をより使いやすくするためのツールでしたが，抽象化によりほかのバックエンドにも対応可能です．  
(mlocateはlocateコマンドとupdatedbコマンドからなり，updatedbコマンドにより生成されたDBをもとに高速にファイル/ディレクトリを検索するツールです)  


## 対応しているバックエンド
以下のバックエンド(searcher)に対応しています．  

- locate(mlocate)

`source/fss/drivers`にdriverを追加することで，他のバックエンドを追加することもできます．  

また，これらのバックエンドをsearcherと呼びます．

## 事前にインストールしておくべきもの

* 最新のDコンパイラ(DMD or LDC or GDC)
* 最新のdub
* 最新のmlocateなどのバックエンド(使いたいもので大丈夫です)

## ビルド方法

```bash
$ cd /path/to/clone
$ git clone https://github.com/alphaKAI/fss
$ cd fss
$ dub build --build=release
```

## 使い方

バックエンドに指定されたプログラムをより使いやすくするためのラッパーとして動作します．  
つまり，最終的にはそのバックエンドが呼び出され検索を行います．fssの動作としてはオプションを生成したり，バックエンドの出力の加工を行います．  
以下にfssで使えるオプションについて記述します．   
また，fssの動作には設定ファイルsetting.jsonが必要ですので，それについても記述します．  

### fssのオプション

`$ fss -h`でも確認できますが，以下に一覧を記述します．  

* --filter-current or --fc : 検索結果のうち，カレントディレクトリ以下のものだけを表示します．
* --filter-with pattern or --fw pattern : locateコマンドでもregex/regexpオプションで指定できますが，後述するsetting.jsonの中でディレクトリ名を置換した結果に対して正規表現でフィルターすることができます．
* --no-filter or --nf : fss側で出力をフィルターしたくない場合に指定します．(setting.jsonでオプションを指定している場合に，一時的に向こうにしたい場合など)
* --full-match pattern or --fm pattern : パターンに完全に一致するファイルだけを表示します．
* --help or -h : fssのオプションを表示します．
* --locate-help or --lh : searcher(バックエンド)のオプションを指定します．

### 設定ファイルの記述
FSSでは以下の項目について設定が可能です．

- searcherへのフルパス(必須) bin_path
- searcherのdriverの指定 driver (現在はlocateのみ対応)
- searcherの常に渡すオプション(任意) opts : --existingなどのオプションを常に渡したい場合に指定します
- searcherの出力結果を書き換えるテーブル(任意) rep_table : locateコマンドはシンボリックリンクを貼っていた場合に，参照先のファイルのみを出力します．これを書き換えたい場合に使用します．
- fss独自のオプション(任意) fss_opts

以下に設定ファイルの例を示します．このような内容のファイルを，`~/.config/fss/setting.json`に保存してください．

```json
{
  "bin_path": "/usr/bin/locate",
  "driver" : "locate",
  "opts": [
    "-e"
  ],
  "rep_table": {
    "/disks/ext_hdd_2tb/": "/home/alphakai/files/"
  },
  "fss_opts": [
    "--filter-current"
  ]
}
```

## ライセンス
fssはMITライセンスの下で配布します．  
ライセンスについての詳細は`LICENSE`ファイルをご確認ください．  
Copyright (C) 2019 Akihiro Shoji  