# ============================================================================
# Makefile for Pong Assembly Game
# ============================================================================

# Assembler and flags
NASM = nasm
NASM_FLAGS = -f elf64

# Linker and flags
CC = gcc
LD_FLAGS = -no-pie -lSDL2

# Output executable name
TARGET = pong

# Source files
ASM_SOURCES = main.asm
ASM_OBJECTS = $(ASM_SOURCES:.asm=.o)

# ============================================================================
# Build Rules
# ============================================================================

# Default target: build everything
all: $(TARGET)

# Link object files into executable
$(TARGET): $(ASM_OBJECTS)
	@echo "Linking $(TARGET)..."
	$(CC) -o $(TARGET) $(ASM_OBJECTS) $(LD_FLAGS)
	@echo "Build complete! Run with: ./$(TARGET)"

# Assemble .asm files to .o object files
%.o: %.asm constants.inc
	@echo "Assembling $<..."
	$(NASM) $(NASM_FLAGS) $< -o $@

# ============================================================================
# Utility Targets
# ============================================================================

# Run the game
run: $(TARGET)
	./$(TARGET)

# Clean build artifacts
clean:
	@echo "Cleaning build files..."
	rm -f $(ASM_OBJECTS) $(TARGET)
	@echo "Clean complete!"

# Rebuild from scratch
rebuild: clean all

# Show help
help:
	@echo "Pong Assembly Game - Makefile"
	@echo ""
	@echo "Available targets:"
	@echo "  make          - Build the game"
	@echo "  make run      - Build and run the game"
	@echo "  make clean    - Remove build artifacts"
	@echo "  make rebuild  - Clean and build"
	@echo "  make help     - Show this help message"

# Declare phony targets (not actual files)
.PHONY: all run clean rebuild help
