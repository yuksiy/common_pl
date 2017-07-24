# ==============================================================================
#   機能
#     第1引数に指定されたファイルが空か否かをチェックする
#   構文
#     use Common_pl::Is_fil_empty;
#     IS_FIL_EMPTY("FILE");
#
#   Copyright (c) 2011-2017 Yukio Shiiya
#
#   This software is released under the MIT License.
#   https://opensource.org/licenses/MIT
# ==============================================================================

######################################################################
# 基本設定
######################################################################
package Common_pl::Is_fil_empty;

use strict;
use warnings;

#use vars qw($VERSION);
#$VERSION = 'X.XX';

require Exporter;
use vars qw(@ISA @EXPORT);
@ISA = qw(Exporter);
@EXPORT = qw(IS_FIL_EMPTY);

use File::Spec;

######################################################################
# サブルーチン定義
######################################################################
# 指定されたファイルが空か否かのチェック
sub IS_FIL_EMPTY {
	# 引数のチェック
	if ( scalar(@_) != 1 ) {
		return 1;
	}

	# 変数定義
	my ($file) = ($_[0]);
	$file = File::Spec->catfile("$file");
	my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks);

	# 指定されたファイルのチェック
	if ( not -f "$file" ) {
		return 1;
	}

	# ファイル情報の取得
	if ( ( ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks) = lstat("$file") ) == 0 ) {
		return 1;
	}

	# 指定されたファイルが空か否かのチェック
	if ( $size == 0 ) {
		return 0;
	} else {
		return 1;
	}
}

1;
