#!/usr/bin/perl

######################################################################
# 基本設定
######################################################################
use strict;
use warnings;

use Cwd qw(abs_path);
use File::Basename;
use File::Spec;

use Common_pl::Cmd_v;

my $s_err = "";
$SIG{__DIE__} = $SIG{__WARN__} = sub { $s_err = $_[0]; };

$SIG{WINCH} = "IGNORE";
$SIG{HUP} = $SIG{INT} = $SIG{TERM} = sub { POST_PROCESS();exit 1; };

my $SCRIPT_FULL_NAME = abs_path($0);
$SCRIPT_FULL_NAME = File::Spec->catfile("$SCRIPT_FULL_NAME");
my ($SCRIPT_NAME, $SCRIPT_ROOT) = fileparse($SCRIPT_FULL_NAME);
my $PID = $$;

######################################################################
# 変数定義
######################################################################
my $rc;
my $line;

my $TMP_DIR = File::Spec->tmpdir();
my $SCRIPT_TMP_FILE = File::Spec->catfile($TMP_DIR, "$SCRIPT_NAME.$PID");

######################################################################
# サブルーチン定義
######################################################################
sub PRE_PROCESS {
}

sub POST_PROCESS {
	# 一時ファイルの削除
	unlink($SCRIPT_TMP_FILE);
}

sub OPEN_TMP_FILE {
	if ( not defined(open(SCRIPT_TMP_FILE, '>', "$SCRIPT_TMP_FILE")) ) {
		print STDERR "-E SCRIPT_TMP_FILE cannot open -- \"$SCRIPT_TMP_FILE\": $!\n";
		POST_PROCESS();exit 1;
	}
	#binmode(SCRIPT_TMP_FILE);
}

sub CLOSE_TMP_FILE {
	close(SCRIPT_TMP_FILE);
}

sub DISPLAY_TMP_FILE {
	print "### \"$SCRIPT_TMP_FILE\" START ###\n";
	if ( not defined(open(SCRIPT_TMP_FILE, '<', "$SCRIPT_TMP_FILE")) ) {
		print STDERR "-E SCRIPT_TMP_FILE cannot open -- \"$SCRIPT_TMP_FILE\": $!\n";
		POST_PROCESS();exit 1;
	}
	#binmode(SCRIPT_TMP_FILE);
	while ($line = <SCRIPT_TMP_FILE>) {
		print $line;
	}
	close(SCRIPT_TMP_FILE);
	print "### \"$SCRIPT_TMP_FILE\" END ###\n";
}

sub TEST_NO_OPT {
	print "########################################\n";
	print "# No options\n";
	print "########################################\n";
	print "----------------------------------------\n";
	print "(SHOULD SUCCESS)\n";
	$rc = CMD_V("print \"test\\n\";");
	print "rc = $rc\n\n";
	$rc = SYS_V("echo \"test\"");
	print "rc = $rc\n\n";
	$rc = CMD("print \"test\\n\";");
	print "rc = $rc\n\n";
	$rc = SYS("echo \"test\"");
	print "rc = $rc\n\n";
}

sub TEST_OPT_N {
	print "########################################\n";
	print "# -n\n";
	print "########################################\n";
	print "----------------------------------------\n";
	print "(SHOULD FAIL)\n";
	$rc = CMD_V("-n", "print \"test\\n\";");
	print "rc = $rc\n\n";
	$rc = SYS_V("-n", "echo \"test\"");
	print "rc = $rc\n\n";
	$rc = CMD("-n", "print \"test\\n\";");
	print "rc = $rc\n\n";
	$rc = SYS("-n", "echo \"test\"");
	print "rc = $rc\n\n";

	print "----------------------------------------\n";
	print "(SHOULD SUCCESS)\n";
	$rc = CMD_V("-n", "0", "print \"test\\n\";");
	print "rc = $rc\n\n";
	$rc = SYS_V("-n", "0", "echo \"test\"");
	print "rc = $rc\n\n";
	$rc = CMD("-n", "0", "print \"test\\n\";");
	print "rc = $rc\n\n";
	$rc = SYS("-n", "0", "echo \"test\"");
	print "rc = $rc\n\n";

	print "----------------------------------------\n";
	print "(SHOULD SUCCESS)\n";
	$rc = CMD_V("-n", "1", "print \"test\\n\";");
	print "rc = $rc\n\n";
	$rc = SYS_V("-n", "1", "echo \"test\"");
	print "rc = $rc\n\n";
	$rc = CMD("-n", "1", "print \"test\\n\";");
	print "rc = $rc\n\n";
	$rc = SYS("-n", "1", "echo \"test\"");
	print "rc = $rc\n\n";
}

sub TEST_OPT_V {
	print "########################################\n";
	print "# -v\n";
	print "########################################\n";
	print "----------------------------------------\n";
	print "(SHOULD FAIL)\n";
	$rc = CMD_V("-v", "print \"test\\n\";");
	print "rc = $rc\n\n";
	$rc = SYS_V("-v", "echo \"test\"");
	print "rc = $rc\n\n";
	$rc = CMD("-v", "print \"test\\n\";");
	print "rc = $rc\n\n";
	$rc = SYS("-v", "echo \"test\"");
	print "rc = $rc\n\n";

	print "----------------------------------------\n";
	print "(SHOULD SUCCESS)\n";
	$rc = CMD_V("-v", "0", "print \"test\\n\";");
	print "rc = $rc\n\n";
	$rc = SYS_V("-v", "0", "echo \"test\"");
	print "rc = $rc\n\n";
	$rc = CMD("-v", "0", "print \"test\\n\";");
	print "rc = $rc\n\n";
	$rc = SYS("-v", "0", "echo \"test\"");
	print "rc = $rc\n\n";

	print "----------------------------------------\n";
	print "(SHOULD SUCCESS)\n";
	$rc = CMD_V("-v", "1", "print \"test\\n\";");
	print "rc = $rc\n\n";
	$rc = SYS_V("-v", "1", "echo \"test\"");
	print "rc = $rc\n\n";
	$rc = CMD("-v", "1", "print \"test\\n\";");
	print "rc = $rc\n\n";
	$rc = SYS("-v", "1", "echo \"test\"");
	print "rc = $rc\n\n";
}

sub TEST_OPT_OFH {
	print "########################################\n";
	print "# --ofh\n";
	print "########################################\n";
	print "----------------------------------------\n";
	print "(SHOULD FAIL)\n";
	$rc = CMD_V("--ofh", "print \"test\\n\";");
	print "rc = $rc\n\n";
	$rc = SYS_V("--ofh", "echo \"test\"");
	print "rc = $rc\n\n";
	$rc = CMD("--ofh", "print \"test\\n\";");
	print "rc = $rc\n\n";
	$rc = SYS("--ofh", "echo \"test\"");
	print "rc = $rc\n\n";

	print "----------------------------------------\n";
	print "(SHOULD FAIL)\n";
	$rc = CMD_V("--ofh", \*SCRIPT_TMP_FILE, "print \"test\\n\";");
	print "rc = $rc\n\n";
	$rc = SYS_V("--ofh", \*SCRIPT_TMP_FILE, "echo \"test\"");
	print "rc = $rc\n\n";
	$rc = CMD("--ofh", \*SCRIPT_TMP_FILE, "print \"test\\n\";");
	print "rc = $rc\n\n";
	$rc = SYS("--ofh", \*SCRIPT_TMP_FILE, "echo \"test\"");
	print "rc = $rc\n\n";

	print "----------------------------------------\n";
	print "(SHOULD SUCCESS)\n";
	OPEN_TMP_FILE();
	$rc = CMD_V("--ofh", \*SCRIPT_TMP_FILE, "print \"test\\n\";");
	print "rc = $rc\n\n";
	CLOSE_TMP_FILE();
	DISPLAY_TMP_FILE();

	OPEN_TMP_FILE();
	$rc = SYS_V("--ofh", \*SCRIPT_TMP_FILE, "echo \"test\"");
	print "rc = $rc\n\n";
	CLOSE_TMP_FILE();
	DISPLAY_TMP_FILE();

	OPEN_TMP_FILE();
	$rc = CMD("--ofh", \*SCRIPT_TMP_FILE, "print \"test\\n\";");
	print "rc = $rc\n\n";
	CLOSE_TMP_FILE();
	DISPLAY_TMP_FILE();

	OPEN_TMP_FILE();
	$rc = SYS("--ofh", \*SCRIPT_TMP_FILE, "echo \"test\"");
	print "rc = $rc\n\n";
	CLOSE_TMP_FILE();
	DISPLAY_TMP_FILE();
}

sub TEST_OPT_OFN {
	print "########################################\n";
	print "# --ofn\n";
	print "########################################\n";
	print "----------------------------------------\n";
	print "(SHOULD FAIL)\n";
	$rc = CMD_V("--ofn", "print \"test\\n\";");
	print "rc = $rc\n\n";
	$rc = SYS_V("--ofn", "echo \"test\"");
	print "rc = $rc\n\n";
	$rc = CMD("--ofn", "print \"test\\n\";");
	print "rc = $rc\n\n";
	$rc = SYS("--ofn", "echo \"test\"");
	print "rc = $rc\n\n";

	print "----------------------------------------\n";
	print "(SHOULD SUCCESS)\n";
	$rc = CMD_V("--ofn", $SCRIPT_TMP_FILE, "print \"test\\n\";");
	print "rc = $rc\n\n";
	DISPLAY_TMP_FILE();

	$rc = SYS_V("--ofn", $SCRIPT_TMP_FILE, "echo \"test\"");
	print "rc = $rc\n\n";
	DISPLAY_TMP_FILE();

	$rc = CMD("--ofn", $SCRIPT_TMP_FILE, "print \"test\\n\";");
	print "rc = $rc\n\n";
	DISPLAY_TMP_FILE();

	$rc = SYS("--ofn", $SCRIPT_TMP_FILE, "echo \"test\"");
	print "rc = $rc\n\n";
	DISPLAY_TMP_FILE();
}

sub TEST_OPT_P {
	print "########################################\n";
	print "# -p\n";
	print "########################################\n";
	print "----------------------------------------\n";
	print "(SHOULD FAIL)\n";
	$rc = CMD_V("-p", "print \"test\\n\";");
	print "rc = $rc\n\n";
	$rc = SYS_V("-p", "echo \"test\"");
	print "rc = $rc\n\n";
	$rc = CMD("-p", "print \"test\\n\";");
	print "rc = $rc\n\n";
	$rc = SYS("-p", "echo \"test\"");
	print "rc = $rc\n\n";

	print "----------------------------------------\n";
	print "(SHOULD SUCCESS)\n";
	$rc = CMD_V("-p", "(PREFIX) ", "print \"test\\n\";");
	print "rc = $rc\n\n";
	$rc = SYS_V("-p", "(PREFIX) ", "echo \"test\"");
	print "rc = $rc\n\n";
	$rc = CMD("-p", "(PREFIX) ", "print \"test\\n\";");
	print "rc = $rc\n\n";
	$rc = SYS("-p", "(PREFIX) ", "echo \"test\"");
	print "rc = $rc\n\n";
}

sub TEST_OPT_S {
	print "########################################\n";
	print "# -s\n";
	print "########################################\n";
	print "----------------------------------------\n";
	print "(SHOULD FAIL)\n";
	$rc = CMD_V("-s", "print \"test\\n\";");
	print "rc = $rc\n\n";
	$rc = SYS_V("-s", "echo \"test\"");
	print "rc = $rc\n\n";
	$rc = CMD("-s", "print \"test\\n\";");
	print "rc = $rc\n\n";
	$rc = SYS("-s", "echo \"test\"");
	print "rc = $rc\n\n";

	print "----------------------------------------\n";
	print "(SHOULD SUCCESS)\n";
	$rc = CMD_V("-s", " (SUFFIX)", "print \"test\\n\";");
	print "rc = $rc\n\n";
	$rc = SYS_V("-s", " (SUFFIX)", "echo \"test\"");
	print "rc = $rc\n\n";
	$rc = CMD("-s", " (SUFFIX)", "print \"test\\n\";");
	print "rc = $rc\n\n";
	$rc = SYS("-s", " (SUFFIX)", "echo \"test\"");
	print "rc = $rc\n\n";
}

######################################################################
# メインルーチン
######################################################################

TEST_NO_OPT();
TEST_OPT_N();
TEST_OPT_V();
TEST_OPT_OFH();
TEST_OPT_OFN();
TEST_OPT_P();
TEST_OPT_S();

# 作業終了後処理
POST_PROCESS();exit 0;

