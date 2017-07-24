# ==============================================================================
#   機能
#     引数に指定されたコマンドラインを表示・実行する
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
package Common_pl::Cmd_v;

use strict;
use warnings;

#use vars qw($VERSION);
#$VERSION = 'X.XX';

require Exporter;
use vars qw(@ISA @EXPORT);
@ISA = qw(Exporter);
@EXPORT = qw(CMD_V SYS_V CMD SYS);

use Fcntl qw(:flock :seek);
use File::Spec;
use Getopt::Long qw(GetOptionsFromArray :config gnu_getopt no_ignore_case);

use Common_pl::Is_numeric;

######################################################################
# 変数定義
######################################################################
my $sub_name;
my @arg;

my $NO_PLAY;
my $VERBOSITY;
my $OFH;
my $OFN;
my $OFD;
my $PREFIX;
my $SUFFIX;
my $rc;

######################################################################
# サブルーチン定義
######################################################################
sub USAGE {
	print STDOUT <<EOF;
Usage:
    use Common_pl::Cmd_v;
    CMD_V([OPTION, ...] "CMD_LINE");
    SYS_V([OPTION, ...] "CMD_LINE");
    CMD([OPTION, ...] "CMD_LINE");
    SYS([OPTION, ...] "CMD_LINE");

OPTIONS:
    -n NO_PLAY (0|1)
    -v VERBOSITY (0|1)
    --ofh \*OFH (output filehandle reference)
    --ofn OFN (output filename)
    -p PREFIX (string)
    -s SUFFIX (string)
EOF
}

sub MAIN {
	$NO_PLAY = 0;
	if ( $sub_name =~ m#^(?:CMD_V|SYS_V)$# ) {
		$VERBOSITY = 1;
	} elsif ( $sub_name =~ m#^(?:CMD|SYS)$# ) {
		$VERBOSITY = 0;
	}
	$OFH = \*STDOUT;
	$OFN = "";							#初期状態が「空文字」でなければならない変数
	$PREFIX = "++ ";
	$SUFFIX = "";

	# オプションのチェック
	if ( not eval { GetOptionsFromArray( \@arg,
		"n=s" => sub {
			$NO_PLAY = $_[1];
			$rc = IS_NUMERIC($NO_PLAY);
			if ( $rc != 0 ) {
				print STDERR "-E Argument to \"-v\" not numeric -- \"$NO_PLAY\"\n";
				die;
			}
			if ( ( $NO_PLAY != 0 ) and ( $NO_PLAY != 1 ) ) {
				print STDERR "-E Argument to \"-v\" is invalid -- \"$NO_PLAY\"\n";
				die;
			}
		},
		"v=s" => sub {
			$VERBOSITY = $_[1];
			$rc = IS_NUMERIC($VERBOSITY);
			if ( $rc != 0 ) {
				print STDERR "-E Argument to \"-v\" not numeric -- \"$VERBOSITY\"\n";
				die;
			}
			if ( ( $VERBOSITY != 0 ) and ( $VERBOSITY != 1 ) ) {
				print STDERR "-E Argument to \"-v\" is invalid -- \"$VERBOSITY\"\n";
				die;
			}
		},
		"ofh=s" => sub {
			$OFH = $_[1];
		},
		"ofn=s" => sub {
			$OFN = $_[1];
			$OFN = File::Spec->catfile("$OFN");
		},
		"p=s" => sub {
			$PREFIX = $_[1];
		},
		"s=s" => sub {
			$SUFFIX = $_[1];
		},
	) } ) {
		if ( $@ ne "" ) {
			print STDERR "-E $@\n";
		}
		return -1;
	}

	# 引数のチェック
	if ( scalar(@arg) != 1 ) {
		print STDERR "-E Missing 1st argument\n";
		return -1;
	}

	# コマンドラインの表示・実行
	if ( $sub_name =~ m#^(?:CMD_V|CMD)$# ) {
		$rc = PRINT_CMD("$arg[0]");
		if ( $rc != 0 ) {
			return $rc;
		}
		if ( $NO_PLAY == 0 ) {
			$rc = eval "$arg[0]";
			return $rc;
		} else {
			return 1;
		}
	} elsif ( $sub_name =~ m#^(?:SYS_V|SYS)$# ) {
		$rc = PRINT_CMD("system(\"$arg[0]\")");
		if ( $rc != 0 ) {
			return $rc;
		}
		if ( $NO_PLAY == 0 ) {
			$rc = system("$arg[0]");
			$rc = $rc >> 8;
			return $rc;
		} else {
			return 0;
		}
	}
}

sub PRINT_CMD {
	if ( $VERBOSITY == 1 ) {
		if ( $OFN ne "" ) {
			if ( not defined(open(OFN, '>>', "$OFN")) ) {
				print STDERR "-E OFN cannot open -- \"$OFN\": $!\n";
				return -1;
			}
			#binmode(OFN);
			$OFH = \*OFN;
		}
		$OFD = fileno($OFH);
		if ( not defined($OFD) ) {
			print STDERR "-E Filehandle which the reference of the argument to \"-o\" points is not opened\n";
			return -1;
		}
		if ( ( $OFD != 0 ) and ( $OFD != 1 ) and ( $OFD != 2 ) ) {
			$rc = flock($OFH, LOCK_EX);
			if ( $rc != 1 ) {
				print STDERR "-E Filehandle which the reference of the argument to \"-o\" points cannot lock\n";
				return -1;
			}
			seek($OFH, 0, SEEK_END);
		}
		$rc = print $OFH $PREFIX . $_[0] . $SUFFIX . "\n";
		if ( $rc != 1 ) {
			print STDERR "-E Print command line to filehandle which the reference of the argument to \"-o\" points failed\n";
			return -1;
		}
		if ( ( $OFD != 0 ) and ( $OFD != 1 ) and ( $OFD != 2 ) ) {
			$rc = flock($OFH, LOCK_UN);
			if ( $rc != 1 ) {
				print STDERR "-E Filehandle which the reference of the argument to \"-o\" points cannot unlock\n";
				return -1;
			}
		}
		if ( $OFN ne "" ) {
			close(OFN);
		}
	}
	return 0;
}

sub CMD_V {
	$sub_name = "CMD_V";
	@arg = @_;
	return MAIN();
}

sub SYS_V {
	$sub_name = "SYS_V";
	@arg = @_;
	return MAIN();
}

sub CMD {
	$sub_name = "CMD";
	@arg = @_;
	return MAIN();
}

sub SYS {
	$sub_name = "SYS";
	@arg = @_;
	return MAIN();
}

1;
