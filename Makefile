.PHONY: emu emuc sim clean synt

# ass
ASS_DIR=ass
ASS_BUILD_DIR=$(ASS_DIR)/build
ASS_BIN=$(ASS_BUILD_DIR)/ass
ASS_SRC_FILES=$(ASS_DIR)/*.cs $(ASS_DIR)/ass.csproj

$(ASS_BIN): $(ASS_SRC_FILES)
	cd $(ASS_DIR) && dotnet publish -c Release -o ./build

# test
TESTS_DIR=tests
TESTS_BUILD_DIR=$(TESTS_DIR)/build
TEST_FILE=$(TESTS_BUILD_DIR)/$(TEST).bin $(TESTS_BUILD_DIR)/$(TEST).txt

$(TESTS_BUILD_DIR)/$(TEST).bin $(TESTS_BUILD_DIR)/$(TEST).txt:$(TESTS_DIR)/$(TEST).s $(ASS_BIN)
	$(ASS_BIN) $(TEST) $(TESTS_DIR) $(TESTS_BUILD_DIR) -t

# emu
EMU_DIR=emu
EMU_BUILD_DIR=$(EMU_DIR)/build
EMU_BIN=$(EMU_BUILD_DIR)/emu
EMU_SRC_FILES = $(EMU_DIR)/*.cs $(EMU_DIR)/emu.csproj

$(EMU_BIN): $(EMU_SRC_FILES)
	cd $(EMU_DIR) && dotnet publish -c Release -o ./build

emuc: $(EMU_BIN) $(TEST_FILE) $(EMU_SRC_FILES)
	$(EMU_BIN) $(TESTS_BUILD_DIR)/$(TEST) -t -c

emu: $(EMU_BIN) $(TEST_FILE) $(EMU_SRC_FILES)
	$(EMU_BIN) $(TESTS_BUILD_DIR)/$(TEST) -t

# sim
VERILATOR = verilator
VERILATOR_CFLAGS += -MMD --build -cc  \
				-O3 --x-assign fast --x-initial fast --noassert \
				--report-unoptflat
TOPNAME=Top
INC_PATH ?=
# rules for verilator
INCFLAGS = $(addprefix -I, $(INC_PATH))
CFLAGS += $(INCFLAGS) -DTOP_NAME="\"V$(TOPNAME)\""
LDFLAGS += -lSDL2 -lSDL2_image

SIM_BUILD_DIR=sim/build
SIM_OBJ_DIR=$(SIM_BUILD_DIR)/obj
SIM_VSRC_DIR=sim/vsrc
SIM_CSRC_DIR=sim/csrc
SIM_BIN=$(SIM_BUILD_DIR)/$(TOPNAME)

VSRCS = $(shell find $(abspath ./sim/vsrc) -name "*.v")
CSRCS = $(shell find $(abspath ./sim/csrc) -name "*.c" -or -name "*.cc" -or -name "*.cpp")

$(SIM_BIN): $(VSRCS) $(CSRCS)
	rm -rf $(SIM_OBJ_DIR)
	mkdir -p $(SIM_OBJ_DIR)
	$(VERILATOR) $(VERILATOR_CFLAGS) \
		--top-module $(TOPNAME) $^ \
		-I/home/looooong/RV32S/sim/vsrc \
		$(addprefix -CFLAGS , $(CFLAGS)) $(addprefix -LDFLAGS , $(LDFLAGS)) \
		--Mdir $(SIM_OBJ_DIR) --exe -o $(abspath $(SIM_BIN)) --trace --trace-depth 99

sim: $(SIM_BIN) $(TEST_FILE)
	$(SIM_BIN) $(TEST_FILE)

# synt
YOSYS_DIR=sim/yosys
DOT=$(YOSYS_DIR)/my_design.dot

$(DOT): $(YOSYS_DIR)/script.ys $(VSRCS)
	cd $(YOSYS_DIR) && yosys script.ys

synt: $(DOT)
	dot  -Tpng $(DOT) -o $(YOSYS_DIR)/my_design.png

clean:
	rm $(TESTS_BUILD_DIR)/*