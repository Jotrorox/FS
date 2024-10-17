# Compiler and linker settings
NASM = nasm
LD = ld
NASM_FLAGS = -f elf64 -O3
LD_FLAGS = 

# Source and output files
SRC = asmfetch.asm
BUILD_DIR = build
OBJ = $(BUILD_DIR)/asmfetch.o
OUT = $(BUILD_DIR)/asmfetch

# Default target to build the project
all: $(BUILD_DIR) $(OUT)

# Create the build directory if it doesn't exist
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# Rule to assemble the NASM code and link it
$(OUT): $(OBJ)
	$(LD) $(LD_FLAGS) -o $(OUT) $(OBJ)

# Rule to assemble the NASM source into object file
$(OBJ): $(SRC)
	$(NASM) $(NASM_FLAGS) -o $(OBJ) $(SRC)

# Clean up object and output files
clean:
	rm -rf $(BUILD_DIR)

# Run the program
run: $(OUT)
	./$(OUT)
