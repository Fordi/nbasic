# Potentially OS-specific
RMDIR    = rm -rf
COPY     = cp
USR_BIN  = /usr/local/bin
CXX      = g++
MKDIR_P  = mkdir -p
CPPFLAGS = -O2 -Wall
LDFLAGS  =

# Directories
OUT         = bin
SRC         = .

# Object dependencies
NBASIC_DEPS = $(OUT)/main.o \
              $(OUT)/nbasic.o \
              $(OUT)/RegEx.o

NBASIC      = $(OUT)/nbasic

# default target
default: all

# Header dependencies
$(NBASIC_DEPS)  : $(SRC)/nbasic.h
$(OUT)/main.o   :
$(OUT)/nbasic.o : $(SRC)/RegEx.h
$(OUT)/RegEx.o  : $(SRC)/RegEx.h

# Binaries
$(NBASIC) : $(OUT) $(NBASIC_DEPS)
	$(CPP) -o $(NBASIC) $(NBASIC_DEPS) $(LDFLAGS)

# Custom targets
all: $(NBASIC)

install:
	$(COPY) $(NBASIC) $(USR_BIN)

# Output directory
$(OUT):
	$(MKDIR_P) $(OUT)

# Libs
$(OUT)/%.o : $(SRC)/%.cpp
	$(CXX) $(CPPFLAGS) -o $@ -c $< > $@.log 2>&1

# Clean-up
clean:
	$(RMDIR) -rf $(OUT)

install:
