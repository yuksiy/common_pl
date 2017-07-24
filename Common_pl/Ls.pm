# ==============================================================================
#   機能
#     ファイル一覧の表示
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
package Common_pl::Ls;

use strict;
use warnings;

#use vars qw($VERSION);
#$VERSION = 'X.XX';

require Exporter;
use vars qw(@ISA @EXPORT);
@ISA = qw(Exporter);
@EXPORT = qw(LS);

use Getopt::Long qw(GetOptionsFromArray :config gnu_getopt no_ignore_case);

my $s_err = "";
$SIG{__DIE__} = $SIG{__WARN__} = sub { $s_err = $_[0]; };

######################################################################
# 変数定義
######################################################################
my $FLAG_OPT_ALL = 0;
my $FLAG_OPT_DIR = 0;

######################################################################
# サブルーチン定義
######################################################################
sub USAGE {
	print STDOUT <<EOF;
Usage:
    use Common_pl::Ls;
    LS([OPTION, ...] [FILE, ...]);

    FILE : List information about the FILEs.

OPTIONS:
    Specify options for ls command.
    Following options are supported now.
      -a, --all
      -d, --directory
      -l
      --help
    See also ls(1) or "ls --help" for the further information on each option.
EOF
}

# ファイル一覧の表示
sub LS {
	use Common_pl::Ls_file;
	# 変数定義
	my @files = ();
	my ($file, $files_count_total);
	my $line;
	my ($s_file, $s_file_err) = ("", "");
	my @dirs = ();
	my ($dir, $dirs_count_total, $dirs_count);
	my $result = 0;

	# オプションのチェック
	if ( not eval { GetOptionsFromArray( \@_,
		"a|all" => \$FLAG_OPT_ALL,
		"d|dir" => \$FLAG_OPT_DIR,
		"l" => sub {
			$Common_pl::Ls_file::FLAG_OPT_LONG = 1;
		},
		"help" => sub {
			USAGE();return 0;
		},
	) } ) {
		print STDERR "-E $s_err\n";
		USAGE();return 1;
	}

	# ファイルの処理
	@files = @_;
	if ( @files == 0 ) {
		@files = (".");
	}
	$files_count_total = @files;

	# ファイル配列(files)のループ
	foreach $file (sort(@files)) {
		$line = eval "LS_FILE('$file', '')";
		# 既存ファイルでない場合
		if ( $@ ne "" ) {
			$s_file_err .= "LS: $@";
			$result = 1;
			next;
		}
		# 既存ディレクトリの場合、かつDIR オプションが指定されていない場合
		if ( ( -d "$file" ) and ( not $FLAG_OPT_DIR ) ) {
			# ディレクトリ名の退避
			push @dirs, "$file";
		# 上記以外の場合
		} else {
			# ファイル一覧の取得
			$s_file .= "$line";
		}
	}

	# ファイル一覧の表示
	print STDERR $s_file_err;
	print $s_file;

	# ディレクトリの処理
	$dirs_count_total = @dirs;

	# ディレクトリ配列(dirs)のループ
	$dirs_count = 0;
	foreach $dir (sort(@dirs)) {
		$dirs_count = $dirs_count + 1;
		# ディレクトリのオープン
		if ( not defined(opendir(DH, "$dir")) ) {
			print STDERR "LS: cannot open directory $dir: $!\n";
			$result = 1;
			next;
		}
		# ディレクトリヘッダの表示
		if ( $files_count_total >= 2 ) {
			if ( ( $dirs_count == 1 ) and ( $files_count_total == $dirs_count_total ) ) {
				print "$dir:\n";
			} else {
				print "\n";
				print "$dir:\n";
			}
		}
		# ディレクトリ内ファイルのループ
		foreach $file (sort(readdir(DH))) {
			# ファイル名が「.」で始まる場合、かつALL オプションが指定されていない場合
			if ( ( $file !~ m#^\.# ) and ( not $FLAG_OPT_ALL ) ) {
				next;
			}
			# ディレクトリ内ファイル一覧の表示
			print LS_FILE("$file", "$dir");
		}
		# ディレクトリのクローズ
		closedir(DH);
	}

	# 作業終了後処理
	return $result;
}

1;
