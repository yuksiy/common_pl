# ==============================================================================
#   機能
#     ファイルモードの数値表記を文字列表記に変換
#   構文
#     use Common_pl::Unix::Mod_num2str;
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
package Common_pl::Unix::Mod_num2str;

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
	my $permission = "";

	# モード文字列の生成 (UNIX用)
	# cf.
	#   返すべきファイル種別の候補
	#     /usr/include/linux/stat.h
	#       S_IFSOCK
	#       S_IFLNK
	#       S_IFREG
	#       S_IFBLK
	#       S_IFDIR
	#       S_IFCHR
	#       S_IFIFO
	#   ファイル種別の判定に使用できるPerl関数の候補
	#     http://search.cpan.org/dist/perl/pod/perlfunc.pod
	#       S_ISREG() S_ISDIR() S_ISLNK()
	#       S_ISBLK() S_ISCHR() S_ISFIFO() S_ISSOCK()
	if    ( S_ISREG($num) )  { $file_type = "-"; }
	elsif ( S_ISDIR($num) )  { $file_type = "d"; }
	elsif ( S_ISLNK($num) )  { $file_type = "l"; }
	elsif ( S_ISBLK($num) )  { $file_type = "b"; }
	elsif ( S_ISCHR($num) )  { $file_type = "c"; }
	elsif ( S_ISFIFO($num) ) { $file_type = "p"; }
	elsif ( S_ISSOCK($num) ) { $file_type = "s"; }
	else                     { $file_type = "?"; }

	# cf.
	#   パーミッションの判定に使用できるPerl定数の候補
	#     http://search.cpan.org/dist/perl/pod/perlfunc.pod
	#       S_IRUSR S_IWUSR S_IXUSR
	#       S_IRGRP S_IWGRP S_IXGRP
	#       S_IROTH S_IWOTH S_IXOTH
	#
	#       S_ISUID S_ISGID S_ISVTX
	$permission .= ( ($num & S_IRUSR) >> 8 ? "r" : "-" );
	$permission .= ( ($num & S_IWUSR) >> 7 ? "w" : "-" );
	$permission .= ( ($num & S_ISUID) >> 11
		? ( ( ($num & S_IXUSR) >> 6 ? "s" : "S" ) )
		: ( ( ($num & S_IXUSR) >> 6 ? "x" : "-" ) ) );

	$permission .= ( ($num & S_IRGRP) >> 5 ? "r" : "-" );
	$permission .= ( ($num & S_IWGRP) >> 4 ? "w" : "-" );
	$permission .= ( ($num & S_ISGID) >> 10
		? ( ( ($num & S_IXGRP) >> 3 ? "s" : "S" ) )
		: ( ( ($num & S_IXGRP) >> 3 ? "x" : "-" ) ) );

	$permission .= ( ($num & S_IROTH) >> 2 ? "r" : "-" );
	$permission .= ( ($num & S_IWOTH) >> 1 ? "w" : "-" );
	$permission .= ( ($num & S_ISVTX) >> 9
		? ( ( ($num & S_IXOTH) >> 0 ? "t" : "T" ) )
		: ( ( ($num & S_IXOTH) >> 0 ? "x" : "-" ) ) );

	return sprintf("%-10s", $file_type . $permission);
}

1;
