SRC := $(wildcard *.typ)
TGT := $(patsubst %.typ,%.pdf,$(SRC))

all : $(TGT)

%.pdf : %.typ
	typst c --root ../.. $^

clean:
	rm *.pdf

.PHONY: all clean
