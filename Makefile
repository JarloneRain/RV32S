.PHONY: sim emu clean

DOTNET_RUN=dotnet run

VERILATOR = verilator
VERILATOR_CFLAGS += -MMD --build -cc  \
				-O3 --x-assign fast --x-initial fast --noassert \
				--report-unoptflat
TOPNAME=Top
# rules for verilator
INCFLAGS = $(addprefix -I, $(INC_PATH))
CFLAGS += $(INCFLAGS) -DTOP_NAME="\"V$(TOPNAME)\""
LDFLAGS += -lSDL2 -lSDL2_image

TEST_DIR=tests
TEST_BUILD_DIR=tests/build

TEST_FILE=$(TEST_BUILD_DIR)/$(TEST).bin $(TEST_BUILD_DIR)/$(TEST).txt

$(TEST_BUILD_DIR)/$(TEST).bin $(TEST_BUILD_DIR)/$(TEST).txt:$(TEST_DIR)/$(TEST).s
	cd ass && $(DOTNET_RUN) $(TEST)


emu: $(TEST_FILE)
	cd emu && $(DOTNET_RUN) $(TEST)

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
		$(addprefix -CFLAGS , $(CFLAGS)) $(addprefix -LDFLAGS , $(LDFLAGS)) \
		--Mdir $(SIM_OBJ_DIR) --exe -o $(abspath $(SIM_BIN)) --trace

sim: $(SIM_BIN) $(TEST_FILE)
	$(SIM_BIN) $(TEST_FILE)

clean:
	rm $(TEST_BUILD_DIR)/*