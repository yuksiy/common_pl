# ==============================================================================
#   機能
#     第1引数に指定された文字列が数値か否かをチェックする
#   構文
#     use Common_pl::Is_numeric;
#     IS_NUMERIC("STR");
#
#   Copyright (c) 2010-2017 Yukio Shiiya
#
#   This software is released under the MIT License.
#   https://opensource.org/licenses/MIT
# ==============================================================================

######################################################################
# 基本設定
######################################################################
package Common_pl::Is_numeric;

use strict;
use warnings;

#use vars qw($VERSION);
#$VERSION = 'X.XX';

require Exporter;
use vars qw(@ISA @EXPORT);
@ISA = qw(Exporter);
@EXPORT = qw(IS_NUMERIC);

######################################################################
# サブルーチン定義
######################################################################
# 指定された文字列が数値か否かのチェック
sub IS_NUMERIC {
	# 引数のチェック
	if ( scalar(@_) != 1 ) {
		return 1;
	}

	# 変数定義
	my ($str) = ($_[0]);

	# 指定された文字列が数値か否かのチェック
	if ( $str =~ m/^[0-9]{1,}$/ ) {
		return 0;
	} else {
		return 1;
	}
}

1;
