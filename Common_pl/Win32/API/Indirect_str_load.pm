# ==============================================================================
#   機能
#     参照文字列の解決
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
package Common_pl::Win32::API::Indirect_str_load;

use strict;
use warnings;

#use vars qw($VERSION);
#$VERSION = 'X.XX';

require Exporter;
use vars qw(@ISA @EXPORT);
@ISA = qw(Exporter);
@EXPORT = qw(INDIRECT_STR_LOAD);

use Encode;
use Win32::API;

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
    use Common_pl::Win32::API::Indirect_str_load;
    \$result = INDIRECT_STR_LOAD(SOURCE);

    SOURCE : Specify an indirect string, it is in the following form.
       \@filename,resource
EOF
}

# 参照文字列の解決
sub INDIRECT_STR_LOAD {
	# 変数定義
	my $INDIRECT_STR_CHARS_MAX = 2048;
	my $szSource;
	my $szOutBuf = encode("UTF-16LE", "\0") x ($INDIRECT_STR_CHARS_MAX + 1);
	my $cchOutBuf = $INDIRECT_STR_CHARS_MAX + 1;
	my $hresult;

	# 外部モジュール 依存定義 (Win32::API)
	# cf. https://msdn.microsoft.com/en-us/library/aa383751.aspx
	Win32::API::Type->typedef("HRESULT", "LONG");
	# cf. https://msdn.microsoft.com/en-us/library/bb759919.aspx
	Win32::API::More->Import(
		"shlwapi",
		"HRESULT SHLoadIndirectString(
			LPCWSTR pszSource,
			LPWSTR pszOutBuf,
			UINT cchOutBuf,
			LPHANDLE ppvReserved
		)"
	);
	# cf. https://msdn.microsoft.com/en-us/library/aa378137.aspx
	my $S_OK = 0x00000000;

	# 必須引数の処理
	# 第1引数の処理
	if ( scalar(@_) < 1 ) {
		return "-E Missing SOURCE argument";
	} else {
		$szSource = encode("UTF-16LE", $_[0]);
	}

	# indirect string のロード
	$hresult = SHLoadIndirectString($szSource, $szOutBuf, $cchOutBuf, undef);
	$szOutBuf = (split(/\0/, decode("UTF-16LE", $szOutBuf), 0))[0];
	if ($hresult == $S_OK) {
		return $szOutBuf;
	} else {
		return sprintf("-E Load indirect string failed (0x%-08lX) -- %s", $hresult, $szOutBuf);
	}
}

1;
