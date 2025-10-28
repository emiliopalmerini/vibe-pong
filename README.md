# Pong in x86-64 Assembly

A classic Pong game implementation written in pure x86-64 assembly language for Linux, using SDL2 for graphics and input.

## About

This project is a learning exercise in low-level programming, implementing the famous Pong game entirely in assembly. Despite being written in assembly, the game features:

- Two-player gameplay
- Smooth paddle movement
- Realistic ball physics and collision detection
- Score tracking
- 60 FPS gameplay

## Prerequisites

Before building, you need:

1. **NASM** (Netwide Assembler)
```bash
sudo pacman -S nasm    # Arch Linux
sudo apt install nasm  # Ubuntu/Debian
```

2. **GCC** (for linking)
```bash
# Usually pre-installed on Linux
gcc --version
```

3. **SDL2** development libraries
```bash
sudo pacman -S sdl2           # Arch Linux
sudo apt install libsdl2-dev  # Ubuntu/Debian
```

## Building

Simply run:

```bash
make
```

This will:
1. Assemble all `.asm` files to object files (`.o`)
2. Link them with SDL2 to create the `pong` executable

## Running

```bash
./pong
```

## Controls

- **Left Paddle**: `W` (up) / `S` (down)
- **Right Paddle**: `↑` (up) / `↓` (down)
- **Quit**: `ESC`

## Game Rules

- First player to reach 10 points wins
- Ball bounces off top and bottom walls
- Ball bounces off paddles with angle based on hit position
- If ball goes past a paddle, opponent scores a point

## Project Structure

```
pong/
├── PLAN.md           - Development plan with phases and explanations
├── README.md         - This file
├── CLAUDE.md         - Project guidelines for AI assistance
├── Makefile          - Build automation
└── *.asm             - Assembly source files
```

## Development Phases

See `PLAN.md` for the detailed development roadmap. The project is built incrementally:

1. Setup & Create Window
2. Draw a Rectangle
3. Make Rectangle Move
4. Add Second Paddle
5. Add Ball & Physics
6. Scoring & Game Logic
7. Polish & Improvements

## Technical Details

- **Architecture**: x86-64 (64-bit)
- **Assembler**: NASM
- **Platform**: Linux (System V ABI calling convention)
- **Graphics**: SDL2 library
- **Resolution**: 800x600 pixels
- **Frame Rate**: 60 FPS

## Learning Assembly?

This project is designed to teach assembly through building something fun. Each phase in `PLAN.md` introduces new assembly concepts as needed. You don't need to know assembly beforehand - just follow the phases!

## Resources

- [NASM Documentation](https://www.nasm.us/doc/)
- [SDL2 API Reference](https://wiki.libsdl.org/SDL2/APIByCategory)
- [x86-64 Instruction Reference](https://www.felixcloutier.com/x86/)

## License

This is a learning project - feel free to use, modify, and learn from it!
