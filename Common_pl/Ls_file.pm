# ==============================================================================
#   機能
#     ファイル情報の生成
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
package Common_pl::Ls_file;

use strict;
use warnings;

#use vars qw($VERSION);
#$VERSION = 'X.XX';

require Exporter;
use vars qw(@ISA @EXPORT);
@ISA = qw(Exporter);
@EXPORT = qw(LS_FILE);

use File::Spec;
use POSIX qw(strftime);
if ($^O !~ m#^(?:MSWin32)$#) {
	eval "use Common_pl::Unix::Mod_num2str";
} else {
	eval "use Common_pl::Win32::Mod_num2str";
}

######################################################################
# 変数定義
######################################################################
our $FLAG_OPT_LONG = 0;

my %uname = ();
my %gname = ();

######################################################################
# サブルーチン定義
######################################################################
sub USAGE {
	print STDOUT <<'EOF';
Usage:
    use Common_pl::Ls_file;
    $Common_pl::Ls_file::FLAG_OPT_LONG = {0|1};

  Syntax1.
    $line = eval "LS_FILE(\"$file_full\", \"\")";
    if ( $@ ne "" ) {
        print STDERR "$@";
    } else {
        print "$line";
    }

  Syntax2.
    $line = eval "LS_FILE(\"$file\", \"$dir\")";
    if ( $@ ne "" ) {
        print STDERR "$@";
    } else {
        print "$dir:\n";
        print "$line";
    }
EOF
}

# ファイル情報の生成
sub LS_FILE {
	# 引数のチェック
	if ( scalar(@_) != 2 ) {
		return 1;
	}

	# 変数定義
	my ($file, $dir) = ($_[0], $_[1]);
	my ($file_full);
	my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks);
	my $line;
	my ($mode_desc, $uname, $gname, $size_desc, $mtime_desc, $file_desc);

	# dir 引数が指定されていない場合
	if ( $dir eq "" ) {
		$file_full = "$file";
	# dir 引数が指定されている場合
	} else {
		$file_full = File::Spec->catfile("$dir", "$file");
	}

	# ファイル情報の取得
	if ( not ( ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks) = lstat("$file_full") ) ) {
		die "cannot access $file_full: $!\n";
	}

	# DIR オプションが指定されている場合
	if ( $FLAG_OPT_LONG ) {
		# mode_desc
		$mode_desc = MOD_NUM2STR($mode);

		if ( $^O !~ m#^(?:MSWin32)$# ) {
			# uname
			if ( defined($uname{$uid}) ) {
				$uname = $uname{$uid};
			} else {
				$uname = getpwuid($uid);
				if ( defined($uname) ) { $uname{$uid} = $uname; } else { $uname = $uid; }
			}
			# gname
			if ( defined($gname{$gid}) ) {
				$gname = $gname{$gid};
			} else {
				$gname = getgrgid($gid);
				if ( defined($gname) ) { $gname{$gid} = $gname; } else { $gname = $gid; }
			}
		}

		# size_desc
		if ( ( $mode_desc =~ m#^b# ) or ($mode_desc =~ m#^c#) ) {
			$size_desc = sprintf("%3d, %3d", ($rdev >> 8) & 0xff, $rdev & 0xff);
		} else {
			$size_desc = $size;
		}

		# mtime_desc
		$mtime_desc = strftime("%Y-%m-%d %H:%M",localtime($mtime));

		# file_desc
		if ( $mode_desc =~ m#^l# ) {
			$file_desc = "$file -> " . readlink("$file_full");
		} else {
			$file_desc = "$file";
		}
		if ( $^O !~ m#^(?:MSWin32)$# ) {
			$line = sprintf("%-10s %3s %-8s %-8s %8s %s %s", $mode_desc, $nlink, $uname, $gname, $size_desc, $mtime_desc, $file_desc);
		} else {
			$line = sprintf("%-10s %3s %8s %s %s", $mode_desc, $nlink, $size_desc, $mtime_desc, $file_desc);
		}
	# DIR オプションが指定されていない場合
	} else {
		$line = $file;
	}

	# ファイル情報の生成
	return "$line\n";
}

1;
