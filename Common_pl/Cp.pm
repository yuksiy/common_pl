# ==============================================================================
#   機能
#     ファイルのコピー
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
package Common_pl::Cp;

use strict;
use warnings;

#use vars qw($VERSION);
#$VERSION = 'X.XX';

require Exporter;
use vars qw(@ISA @EXPORT);
@ISA = qw(Exporter);
@EXPORT = qw(CP);

use File::Basename;
use File::Copy;
use File::Spec;
use Getopt::Long qw(GetOptionsFromArray :config gnu_getopt no_ignore_case);
if ($^O =~ m#^(?:MSWin32)$#) {
	eval "use Win32API::File::Time qw(utime);";
}

my $s_err = "";
$SIG{__DIE__} = $SIG{__WARN__} = sub { $s_err = $_[0]; };

######################################################################
# 変数定義
######################################################################
my $FLAG_OPT_FORCE = 0;
my $FLAG_OPT_INTERACTIVE = 0;
my $FLAG_OPT_RECURSIVE = 0;

my %ATTR_LIST = ();
$ATTR_LIST{context} = 0; $ATTR_LIST{links} = 0; $ATTR_LIST{mode} = 0; $ATTR_LIST{ownership} = 0; $ATTR_LIST{timestamps} = 0;
my ($OPT);

######################################################################
# サブルーチン定義
######################################################################
sub USAGE {
	print STDOUT <<EOF;
Usage:
    use Common_pl::Cp;
  Syntax1. Copy SRC to DEST.
    CP([OPTION, ...] SRC, DEST);
  Syntax2. Copy multiple SRC(s) to DEST directory.
    CP([OPTION, ...] SRC, ..., DEST);

    SRC : Specify source file(s).
    DEST: Specify destination file or directory.

OPTIONS:
    Specify options for cp command.
    Following options are supported now.
      -d                        same as --preserve=links
      -f, --force
      (NOT IMPLEMENTED!) -i, --interactive
      -L, --dereference         same as --no-preserve=links
      -P, --no-dereference      same as --preserve=links
      -p                        same as --preserve=mode,ownership,timestamps
      --preserve[=ATTR_LIST[, ...]]
         ATTR_LIST : {all|context(NOT IMPLEMENTED!)|links|mode|ownership|timestamps}
         Following options are ignored on the MSWin32 system:
           links,mode,ownership
         Last access time is not preserved on the following systems:
           cygwin,MSWin32
         (default: mode,ownership,timestamps)
      --no-preserve=ATTR_LIST
      (NOT IMPLEMENTED!) -R, -r, --recursive
      --help
    See also cp(1) or "cp --help" for the further information on each option.
EOF
}

# ファイルのコピー
sub CP {
	use Common_pl::Cmd_v;
	# 変数定義
	my @srcs = ();
	my ($src);
	my ($dest);
	my ($link_target, $dest_full);
	my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks);
	my ($mod_num);
	my $result = 0;

	# オプションのチェック
	if ( not eval { GetOptionsFromArray( \@_,
		"d" => sub {
			$ATTR_LIST{links} = 1;
		},
		"f|force" => \$FLAG_OPT_FORCE,
		"i|interactive" => \$FLAG_OPT_INTERACTIVE,
		"L|dereference" => sub {
			$ATTR_LIST{links} = 0;
		},
		"P|no-dereference" => sub {
			$ATTR_LIST{links} = 1;
		},
		"p" => sub {
			$ATTR_LIST{mode} = 1; $ATTR_LIST{ownership} = 1; $ATTR_LIST{timestamps} = 1;
		},
		"preserve=s" => sub {
			if ( "$_[1]" ne "" ) {
				foreach $OPT (split(/,/, $_[1])) {
					if ( "$OPT" eq "all" ) {
						$ATTR_LIST{context} = 1; $ATTR_LIST{links} = 1; $ATTR_LIST{mode} = 1; $ATTR_LIST{ownership} = 1; $ATTR_LIST{timestamps} = 1;
					} elsif (
						( "$OPT" eq "context" ) or
						( "$OPT" eq "links" ) or
						( "$OPT" eq "mode" ) or
						( "$OPT" eq "ownership" ) or
						( "$OPT" eq "timestamps" )
					) {
						$ATTR_LIST{$OPT} = 1;
					} else {
						print STDERR "-E argument to \"--$_[0]\" is invalid -- \"${OPT}\"\n";
						USAGE();return 1;
					}
				}
			} else {
				$ATTR_LIST{mode} = 1; $ATTR_LIST{ownership} = 1; $ATTR_LIST{timestamps} = 1;
			}
		},
		"no-preserve=s" => sub {
			if ( "$_[1]" ne "" ) {
				foreach $OPT (split(/,/, $_[1])) {
					if ( "$OPT" eq "all" ) {
						$ATTR_LIST{context} = 0; $ATTR_LIST{links} = 0; $ATTR_LIST{mode} = 0; $ATTR_LIST{ownership} = 0; $ATTR_LIST{timestamps} = 0;
					} elsif (
						( "$OPT" eq "context" ) or
						( "$OPT" eq "links" ) or
						( "$OPT" eq "mode" ) or
						( "$OPT" eq "ownership" ) or
						( "$OPT" eq "timestamps" )
					) {
						$ATTR_LIST{$OPT} = 0;
					} else {
						print STDERR "-E argument to \"--$_[0]\" is invalid -- \"${OPT}\"\n";
						USAGE();return 1;
					}
				}
			} else {
				print STDERR "-E argument to \"--$_[0]\" is missing\n";
				USAGE();return 1;
			}
		},
		"R|r|recursive" => \$FLAG_OPT_RECURSIVE,
		"help" => sub {
			USAGE();return 0;
		},
	) } ) {
		print STDERR "-E $s_err\n";
		USAGE();return 1;
	}

	# 引数のチェック
	if ( scalar(@_) == 0 ) {
		print STDERR "CP: missing file operand\n";
		return 1;
	}
	if ( scalar(@_) == 1 ) {
		print STDERR "CP: missing destination file operand after \`$_[0]\'\n";
		return 1;
	}
	$dest = pop(@_);
	@srcs = @_;

	# コピー元の数が2以上の場合
	if ( scalar(@srcs) >= 2 ) {
		# コピー先ディレクトリのチェック
		if ( not -d dirname("$dest") ) {
			print STDERR "CP: target \`" . dirname("$dest") . "\' is not a directory\n";
			return 1;
		}
	}

	# コピー元配列(srcs)のループ
	foreach $src (sort(@srcs)) {
		########################################
		# コピー対象外の処理
		########################################
		# src が既存ファイルでない場合
		if ( not lstat("$src") ) {
			print STDERR "CP: cannot lstat \`$src\': $!\n";
			$result = 1;
			next;
		}
		# src が既存特殊ファイルの場合
		if ( ( -b "$src" ) or ( -c "$src" ) or ( -p "$src" ) or ( -S "$src" ) ) {
			print STDERR "CP: omitting special file \`$src\'\n";
			$result = 1;
			next;
		}
		# src が既存ディレクトリの場合
		if ( ( -d "$src" ) and ( not -l "$src" ) ) {
			print STDERR "CP: omitting directory \`$src\'\n";
			$result = 1;
			next;
		}
		########################################
		# コピー対象の処理
		########################################
		# dest が既存ディレクトリでない場合
		if ( not -d "$dest" ) {
			$dest_full = "$dest";
		# dest が既存ディレクトリの場合
		} else {
			$dest_full = File::Spec->catfile("$dest", basename("$src"));
		}
		# dest_full が既存ファイルの場合、かつforce オプションが指定されている場合
		if ( ( lstat("$dest_full") ) and ( $FLAG_OPT_FORCE == 1 ) ) {
			# ファイルの削除
			if ( ( eval "unlink('$dest_full');" ) < 1 ) {
				print STDERR "CP: cannot unlink \`$dest_full\': $!\n";
				$result = 1;
				next;
			}
		}
		# src が既存シンボリックリンクファイルの場合、かつpreserve=links オプションが指定されている場合、
		# かつMSWin32システムではない場合
		if ( ( -l "$src" ) and ( $ATTR_LIST{"links"} ) and ( $^O !~ m#^(?:MSWin32)$# ) ) {
			# シンボリックリンクファイルの作成
			$link_target = readlink("$src");
			if ( ( eval "symlink('$link_target', '$dest_full');" ) != 1 ) {
				print STDERR "CP: cannot create symbolic link \`$dest_full\': $!\n";
				$result = 1;
				next;
			}
		# src が上記以外の場合
		} else {
			# ファイルのコピー
			if ( ( eval "use File::Copy; copy('$src', '$dest_full');" ) < 1 ) {
				print STDERR "CP: cannot create regular file \`$dest_full\': $!\n";
				$result = 1;
				next;
			}
		}
		########################################
		# コピー対象のコピー後の処理
		########################################
		# dest が既存通常ファイル、または既存シンボリックリンクファイルの場合
		if ( ( -f "$dest" ) or ( -l "$dest" ) ) {
			# src のモード・オーナ・グループ取得
			($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks) = lstat("$src");
			$mod_num = $mode & 07777;
		}
		#(NOT IMPLEMENTED!)## preserve=context オプションが指定されている場合
		#(NOT IMPLEMENTED!)#if ( $ATTR_LIST{"context"} ) {
		#(NOT IMPLEMENTED!)#	# dest が既存通常ファイルの場合
		#(NOT IMPLEMENTED!)#	if ( ( -f "$dest" ) and ( not -l "$dest" ) ) {
		#(NOT IMPLEMENTED!)#	}
		#(NOT IMPLEMENTED!)#}
		# MSWin32システムではない場合
		if ( $^O !~ m#^(?:MSWin32)$# ) {
			# preserve=ownership オプションが指定されている場合
			if ( $ATTR_LIST{"ownership"} ) {
				# dest が既存通常ファイルの場合
				if ( ( -f "$dest" ) and ( not -l "$dest" ) ) {
					# dest のオーナ・グループ設定
					if ( ( eval "chown($uid, $gid, '$dest_full');" ) < 1 ) {
						print STDERR "-E Command has ended unsuccessfully.\n";
						$result = 1;
						return $result;
					}
				}
			}
			# preserve=mode オプションが指定されている場合
			if ( $ATTR_LIST{"mode"} ) {
				# dest が既存通常ファイルの場合
				if ( ( -f "$dest" ) and ( not -l "$dest" ) ) {
					# dest のモード設定
					if ( ( eval "chmod($mod_num, '$dest_full');" ) < 1 ) {
						print STDERR "-E Command has ended unsuccessfully.\n";
						$result = 1;
						return $result;
					}
				}
			}
		}
		# preserve=timestamps オプションが指定されている場合
		if ( $ATTR_LIST{"timestamps"} ) {
			# dest が既存通常ファイルの場合
			if ( ( -f "$dest" ) and ( not -l "$dest" ) ) {
				# dest のタイムスタンプ設定
				if ( $^O =~ m#^(?:cygwin|MSWin32)$# ) {
					$atime = time;
				}
				if ( ( eval "utime($atime, $mtime, '$dest_full');" ) < 1 ) {
					print STDERR "-E Command has ended unsuccessfully.\n";
					$result = 1;
					return $result;
				}
			}
		}
	}

	# 作業終了後処理
	return $result;
}

1;
