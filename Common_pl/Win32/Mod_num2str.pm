# ==============================================================================
#   機能
#     ファイルモードの数値表記を文字列表記に変換
#   構文
#     use Common_pl::Win32::Mod_num2str;
#     MOD_NUM2STR(NUM);
#
#   Copyright (c) 2016-2017 Yukio Shiiya
#
#   This software is released under the MIT License.
#   https://opensource.org/licenses/MIT
# ==============================================================================

######################################################################
# 基本設定
######################################################################
package Common_pl::Win32::Mod_num2str;

use strict;
use warnings;

#use vars qw($VERSION);
#$VERSION = 'X.XX';

require Exporter;
use vars qw(@ISA @EXPORT);
@ISA = qw(Exporter);
@EXPORT = qw(MOD_NUM2STR);

use Fcntl qw(:mode);

######################################################################
# サブルーチン定義
######################################################################
sub MOD_NUM2STR {
	# 引数のチェック
	if ( scalar(@_) != 1 ) {
		return 1;
	}

	# 変数定義
	my ($num) = ($_[0]);
	my $file_type = "";

	# モード文字列の生成 (Windows用)
	# cf.
	#   返すべきファイル種別の候補
	#     Microsoft Visual Studio 10.0\VC\include\sys\stat.h
	#       S_IFDIR
	#       S_IFCHR
	#       S_IFIFO
	#       S_IFREG
	#   ファイル種別の判定に使用できるPerl関数の候補
	#     http://search.cpan.org/dist/perl/pod/perlfunc.pod
	#       S_ISREG() S_ISDIR() S_ISLNK()
	#       S_ISBLK() S_ISCHR() S_ISFIFO() S_ISSOCK()
	if    ( S_ISREG($num) )  { $file_type = ""; }
	elsif ( S_ISDIR($num) )  { $file_type = "<DIR>"; }
	elsif ( S_ISCHR($num) )  { $file_type = "<CHR>"; }
	elsif ( S_ISFIFO($num) ) { $file_type = "<FIFO>"; }
	else                     { $file_type = "<UNKNOWN>"; }

	return sprintf("%-10s", $file_type);
}

1;
