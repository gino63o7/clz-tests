CC ?= gcc
CFLAGS_common ?= -Wall -std=gnu99 -g -DDEBUG -O0
ifeq ($(strip $(PROFILE)),1)
CFLAGS_common += -Dcorrect
endif
ifeq ($(strip $(MP)),1)
CFLAGS_common += -fopenmp -DMP
endif

EXEC = \
	iteration.o \
	binary.o \
	byte.o \
	recursive.o \
	harley.o 

GIT_HOOKS := .git/hooks/pre-commit
.PHONY: all
all: $(GIT_HOOKS) $(EXEC)

$(GIT_HOOKS):
	@scripts/install-git-hooks
	@echo

SRCS_common = main.c

%.o: $(SRCS_common) %.c clz.h
	$(CC) $(CFLAGS_common) -o $@ -D$(shell echo $(subst .o,,$@)) $(SRCS_common)

run: $(EXEC)
	for method in $(EXEC); do\
		taskset -c 1 ./$$method 67100000 67116384; \
	done

plot: iteration.txt iteration.txt binary.txt byte.txt harley.txt
	gnuplot scripts/runtime.gp

.PHONY: clean
clean:
	$(RM) $(EXEC) *.o *.txt *.png
