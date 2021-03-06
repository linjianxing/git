#!/bin/sh

test_description='CRLF renormalization'

. ./test-lib.sh

test_expect_success setup '
	git config core.autocrlf false &&
	printf "LINEONE\nLINETWO\nLINETHREE\n" >LF.txt &&
	printf "LINEONE\r\nLINETWO\r\nLINETHREE\r\n" >CRLF.txt &&
	printf "LINEONE\r\nLINETWO\nLINETHREE\n" >CRLF_mix_LF.txt &&
	git add . &&
	git commit -m initial
'

test_expect_success 'renormalize CRLF in repo' '
	echo "*.txt text=auto" >.gitattributes &&
	git add --renormalize "*.txt" &&
	cat >expect <<-\EOF &&
	i/lf w/crlf attr/text=auto CRLF.txt
	i/lf w/lf attr/text=auto LF.txt
	i/lf w/mixed attr/text=auto CRLF_mix_LF.txt
	EOF
	git ls-files --eol |
	sed -e "s/	/ /g" -e "s/  */ /g" |
	sort >actual &&
	test_cmp expect actual
'

test_done
