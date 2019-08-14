all: normal unmerged untracked submodules

status:
	@git status --porcelain=v2 | awk '/^1/ { print $$2$$3" "$$9 }; /^2/ { print $$2$$3" "$$11" -> "$$10 }; /^u/ { print $$2$$3" "$$11 }; /^\?/ { print }'

snapshot:
	git commit --no-edit -m 'commit' --allow-empty --only
	git ls-files --stage | git commit -F - --only --allow-empty
	git add --all
	git commit -m 'worktree'

restore:
	git reset --soft @~
	git show --pretty='%B' | grep -v '^$$' | git update-index --index-info
	git reset -N -- _A _Rnew
	git reset -- '\?\?'

reset:
	git reset --hard '@^{/^\[start\]}'
	git clean -ffd
	git commit -m commit --allow-empty

# Normal cases as described in 'Short Format' secton of 'git help status':

normal: _A _M _D M_ MM MD A_ AM AD D_ R_ RM RD C_ CM CD _R DR _C DC

_A: reset
	seq 3 > $@
	git add -N -- $@

_M: reset
	seq 3 > $@
	git add -- $@
	git commit --amend --no-edit -- $@
	seq 1 > $@

_D: reset
	seq 7 > $@
	git add -- $@
	git commit --amend --no-edit -- $@
	rm $@

M_: reset
	seq 3 > $@
	git add -- $@
	git commit --amend --no-edit -- $@
	seq 3 >> $@
	git add -- $@

MM: reset
	seq 3 > $@
	git add -- $@
	git commit --amend --no-edit -- $@
	seq 3 >> $@
	git add -- $@
	seq 3 >> $@

MD: reset
	seq 3 > $@
	git add -- $@
	git commit --amend --no-edit -- $@
	seq 7 >> $@
	git add -- $@
	rm $@

A_: reset
	seq 3 > $@
	git add -- $@

AM: reset
	seq 3 > $@
	git add -- $@
	seq 3 >> $@

AD: reset
	seq 7 > $@
	git add -- $@
	rm $@

D_: reset
	seq 13 > $@
	git add -- $@
	git commit --amend --no-edit -- $@
	rm $@
	git add -- $@

R_: reset
	seq 10 > $@
	git add -- $@
	git commit --amend --no-edit -- $@
	mv $@ $@new
	git add $@ $@new

RM: reset
	seq 10 > $@
	git add -- $@
	git commit --amend --no-edit -- $@
	mv $@ $@new
	git add $@ $@new
	seq 3 > $@new

RD: reset
	seq 10 > $@
	git add -- $@
	git commit --amend --no-edit -- $@
	mv $@ $@new
	git add $@ $@new
	rm $@new

C_ CM CD: reset
	# how to make status to detect copies?

# M_ A_ R_ C_: reset
# _M MM AM RM CM: reset
# _D MD AD RD CD: reset
# already done above

_R: reset
	seq 15 > $@
	git add -- $@
	git commit --amend --no-edit -- $@
	mv $@ $@new
	git add -N $@new

DR: reset
	# how to perproduce?

_C DC: reset
	# how to detect copies in status?

define INDEX_INFO
100644 4b825dc642cb6eb9a060e54bf8d69288fbee4904 1	DD
100644 4b825dc642cb6eb9a060e54bf8d69288fbee4904 2	AU
100644 4b825dc642cb6eb9a060e54bf8d69288fbee4904 1	UD
100644 4b825dc642cb6eb9a060e54bf8d69288fbee4904 2	UD
100644 4b825dc642cb6eb9a060e54bf8d69288fbee4904 3	UA
100644 4b825dc642cb6eb9a060e54bf8d69288fbee4904 1	DU
100644 4b825dc642cb6eb9a060e54bf8d69288fbee4904 3	DU
100644 4b825dc642cb6eb9a060e54bf8d69288fbee4904 2	AA
100644 4b825dc642cb6eb9a060e54bf8d69288fbee4904 3	AA
100644 4b825dc642cb6eb9a060e54bf8d69288fbee4904 1	UU
100644 4b825dc642cb6eb9a060e54bf8d69288fbee4904 2	UU
100644 4b825dc642cb6eb9a060e54bf8d69288fbee4904 3	UU
endef
export INDEX_INFO
unmerged:
	    echo "$$INDEX_INFO" | git update-index --index-info

untracked: \?\?
\?\?: reset
	touch \?\?

# ignored:

# Submodules:

submodules: A_S___ M_S___ D_S___ _DS___ _AS___ _MSC__ _MS_M_ _MS__U _MSCMU _MSCM_ _MS_MU _MSC_U MMSC__

A_S___: reset
	git submodule add -f ../$(shell basename $(CURDIR)) $@
	git commit --amend --no-edit -- .gitmodules

M_S___: reset
	git submodule add -f ../$(shell basename $(CURDIR)) $@
	git commit --amend --no-edit -- .gitmodules $@
	git -C $@ commit --allow-empty -m "m"
	git add $@

D_S___: reset
	git submodule add -f ../$(shell basename $(CURDIR)) $@
	git commit --amend --no-edit -- .gitmodules $@
	git -C $@ commit --allow-empty -m "m"
	rm -rf $@
	git add $@

_AS___: reset
# 	'git status' crashes with this
# 	git submodule add -f ../$(shell basename $(CURDIR)) $@
# 	git commit --amend --no-edit -- .gitmodules
# 	git reset -N $@

_DS___: reset
	git submodule add -f ../$(shell basename $(CURDIR)) $@
	git commit --amend --no-edit -- .gitmodules $@
	git -C $@ commit --allow-empty -m "m"
	rm -rf $@

_MSC__: reset
	git submodule add -f ../$(shell basename $(CURDIR)) $@
	git commit --amend --no-edit -- .gitmodules $@
	git -C $@ commit --allow-empty -m "m"

_MS_M_: reset
	git submodule add -f ../$(shell basename $(CURDIR)) $@
	git commit --amend --no-edit -- .gitmodules $@
	echo 1 >$@/file

_MS__U: reset
	git submodule add -f ../$(shell basename $(CURDIR)) $@
	git commit --amend --no-edit -- .gitmodules $@
	echo 1 >$@/file2

_MSCMU: reset
	git submodule add -f ../$(shell basename $(CURDIR)) $@
	git commit --amend --no-edit -- .gitmodules $@
	git -C $@ commit --allow-empty -m "m"
	echo 1 >$@/file
	echo 1 >$@/file2

_MSCM_: reset
	git submodule add -f ../$(shell basename $(CURDIR)) $@
	git commit --amend --no-edit -- .gitmodules $@
	git -C $@ commit --allow-empty -m "m"
	echo 1 >$@/file

_MS_MU: reset
	git submodule add -f ../$(shell basename $(CURDIR)) $@
	git commit --amend --no-edit -- .gitmodules $@
	echo 1 >$@/file
	echo 1 >$@/file2

_MSC_U: reset
	git submodule add -f ../$(shell basename $(CURDIR)) $@
	git commit --amend --no-edit -- .gitmodules $@
	git -C $@ commit --allow-empty -m "m"
	echo 1 >$@/file2

MMSC__: reset
	git submodule add -f ../$(shell basename $(CURDIR)) $@
	git commit --amend --no-edit -- .gitmodules $@
	git -C $@ commit --allow-empty -m "m"
	git add $@
	git -C $@ commit --allow-empty -m "m"
