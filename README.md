# common_pl

## 概要

共通ツール (Perl)

## 使用方法

「*.pm」ファイルのヘッダー部分を参照してください。

## 動作環境

OS:

* Linux (Debian, Fedora)
* Cygwin

依存パッケージ または 依存コマンド:

* make (インストール目的のみ)
* perl
* [Win32-API](http://search.cpan.org/dist/Win32-API/) (Cygwinのみ)

## インストール

ソースからインストールする場合:

    (Debian の場合)
    # make install

    (Fedora の場合)
    # make ENVTYPE=fedora install

    (Cygwin の場合)
    # make ENVTYPE=cygwin install

## インストール後の設定

Perlの変数「@INC」にインストール先ディレクトリを追加してください。

    (Cygwin の場合)
    # echo "export PERL5LIB=/usr/local/lib/site_perl" > /etc/profile.d/perl.sh

## 最新版の入手先

<https://github.com/yuksiy/common_pl>

## License

MIT License. See [LICENSE](https://github.com/yuksiy/common_pl/blob/master/LICENSE) file.

## Copyright

Copyright (c) 2010-2017 Yukio Shiiya
