# ==============================================================================
#   機能
#     第1引数に指定されたディレクトリが空か否かをチェックする
#   構文
#     use Common_pl::Is_dir_empty;
#     IS_DIR_EMPTY("DIR");
#
#   Copyright (c) 2010-2017 Yukio Shiiya
#
#   This software is released under the MIT License.
#   https://opensource.org/licenses/MIT
# ==============================================================================

######################################################################
# 基本設定
######################################################################
package Common_pl::Is_dir_empty;

use strict;
use warnings;

#use vars qw($VERSION);
#$VERSION = 'X.XX';

require Exporter;
use vars qw(@ISA @EXPORT);
@ISA = qw(Exporter);
@EXPORT = qw(IS_DIR_EMPTY);

use File::Spec;

######################################################################
# サブルーチン定義
######################################################################
# 指定されたディレクトリが空か否かのチェック
sub IS_DIR_EMPTY {
	# 引数のチェック
	if ( scalar(@_) != 1 ) {
		return 1;
	}

	# 変数定義
	my ($dir) = ($_[0]);
	$dir = File::Spec->catdir("$dir");
	my $file;
	my $contents_count;

	# 指定されたディレクトリのチェック
	if ( not -d "$dir" ) {
		return 1;
	}

	# ディレクトリのオープン
	if ( not defined(opendir(DH, "$dir")) ) {
		#print STDERR "IS_DIR_EMPTY: cannot open directory $dir: $!\n";
		return $!;
	}
	# ディレクトリ内ファイルのループ
	$contents_count = 0;
	foreach $file (readdir(DH)) {
		# ファイル名が「.」または「..」である場合
		if ( ( "$file" eq "." ) or ( "$file" eq ".." ) ) {
			next;
		# ファイル名が「.」または「..」である場合
		} else {
			$contents_count = $contents_count + 1;
			last;
		}
	}
	# ディレクトリのクローズ
	closedir(DH);

	# 指定されたディレクトリが空か否かのチェック
	if ( $contents_count == 0 ) {
		return 0;
	} else {
		return 1;
	}
}

1;
