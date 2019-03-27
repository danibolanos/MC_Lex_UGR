.SUFFIXES:
.PHONY: r, run, arn

cxxflags := -lfl
precomp := flex
compilador := gcc 

run: loteria

loteria: loteria_exe

loteria_exe: loteria.l
	flex $<
	gcc lex.yy.c -o $@ -lfl


clean:
	rm -rf *_exe lex.yy.c
