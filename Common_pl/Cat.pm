# ==============================================================================
#   機能
#     ファイル内容の表示
#   構文
#     USAGE 参照
#
#   Copyright (c) 2010-2017 Yukio Shiiya
#
#   This software is released under the MIT License.
#   https://opensource.org/licenses/MIT
# ==============================================================================

######################################################################
# 基本設定
######################################################################
package Common_pl::Cat;

use strict;
use warnings;

#use vars qw($VERSION);
#$VERSION = 'X.XX';

require Exporter;
use vars qw(@ISA @EXPORT);
@ISA = qw(Exporter);
@EXPORT = qw(CAT);

use File::Spec;
use Getopt::Long qw(GetOptionsFromArray :config gnu_getopt no_ignore_case);

my $s_err = "";
$SIG{__DIE__} = $SIG{__WARN__} = sub { $s_err = $_[0]; };

######################################################################
# 変数定義
######################################################################

######################################################################
# サブルーチン定義
######################################################################
sub USAGE {
	print STDOUT <<EOF;
Usage:
    use Common_pl::Cat;
    CAT([OPTION, ...] [FILE, ...]);

    FILE  : Concatenate FILEs and print on the standard output.

OPTIONS:
    Specify options for cat command.
    Following options are supported now.
      --help
    See also cat(1) or "cat --help" for the further information on each option.
EOF
}

# ファイル内容の表示
sub CAT {
	# 変数定義
	my @files = ();
	my ($file, $line);
	my $result = 0;

	# オプションのチェック
	if ( not eval { GetOptionsFromArray( \@_,
		"help" => sub {
			USAGE();return 0;
		},
	) } ) {
		print STDERR "-E $s_err\n";
		USAGE();return 1;
	}

	# 引数のチェック
	@files = @_;

	# ファイル配列(files)のループ
	foreach $file (sort(@files)) {
		$file = File::Spec->catfile("$file");
		# 既存ファイルでない場合
		if ( not stat("$file") ) {
			print STDERR "CAT: $file: $!\n";
			$result = 1;
			next;
		}
		# 既存ディレクトリの場合
		if ( -d "$file" ) {
			print STDERR "CAT: $file: $!\n";
			$result = 1;
			next;
		# 上記以外の場合
		} else {
			# ファイル内容の表示
			if ( not defined(open(FH, '<', "$file")) ) {
				print STDERR "CAT: $file: $!\n";
				$result = 1;
				next;
			}
			#binmode(FH);
			foreach $line (<FH>) {
				print "$line";
			}
			close(FH);
		}
	}

	# 作業終了後処理
	return $result;
}

1;
