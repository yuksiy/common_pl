# ==============================================================================
#   機能
#     YES かNO かを問い合わせる
#   構文
#     use Common_pl::Yesno;
#     YESNO;
#
#   Copyright (c) 2010-2017 Yukio Shiiya
#
#   This software is released under the MIT License.
#   https://opensource.org/licenses/MIT
# ==============================================================================

######################################################################
# 基本設定
######################################################################
package Common_pl::Yesno;

use strict;
use warnings;

#use vars qw($VERSION);
#$VERSION = 'X.XX';

require Exporter;
use vars qw(@ISA @EXPORT);
@ISA = qw(Exporter);
@EXPORT = qw(YESNO);

######################################################################
# サブルーチン定義
######################################################################
# 処理継続確認
sub YESNO {
	# 変数定義
	my $reply;

	print "\007(y/n): ";
	while (1)
	{
		$reply = <STDIN>;
		if ( "$reply" =~
			m#^[Yy]$# ) { return 0; }
		elsif ( "$reply" =~
			m#^[Nn]$# ) { return 1; }
		else {
			print "\007(y/n): ";
			next;
		}
	}
}

1;
