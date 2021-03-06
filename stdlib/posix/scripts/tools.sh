#!/bin/sh

languageTools='. : break continue eval exec exit export readonly return set shift times trap unset'

fileTools='basename cd chgrp chmod chown cp dd df dirname du file find fuser link ln ls mkdir mkfifo mv rm rmdir tee touch unlink'

miscTools='cal'

textTools='awk cat cksum cmp comm csplit cut echo expand fold grep head join more nl od paste printf sed sort split tail tr tsort unexpand uniq wc'
interactiveTools='ed ex vi'
processTools='bg fg jobs kill nice nohup ps renice wait'
scheduleTools='at batch'
zipTools='compress pax uncompress zcat'

buildTools='ar c99 diff gencat iconv m4 make man patch strings'
devTools='cflow ctags cxref lex nm strip yacc'
fortranTools='asa crontab fort77'
adminTools='getconf ulimit umask who'
terminalTools='stty tabs tty'


commsTools='mailx mesg talk'
uuTools='uucp uudecode uuencode uustat uux'
