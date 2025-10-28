# Pong Game Development Plan (x86-64 Assembly)

## Overview
We'll build a classic Pong game using x86-64 NASM assembly on Linux, with SDL2 for graphics and input. This plan focuses on getting a working game with explanations of what each part does.

## Technology Stack
- **Assembly**: NASM (Netwide Assembler) for x86-64
- **Platform**: Linux
- **Graphics**: SDL2 library (handles window, rendering, input)
- **Build**: NASM assembler + GCC linker

## Development Phases

### Phase 1: Setup & Create Window
**Goal**: Get a black window open and running

**What we'll create**:
- Basic assembly program structure
- Call SDL2 functions to create a window
- Implement main game loop (keep window open until ESC pressed)

**Assembly concepts explained**:
- Sections (.data, .bss, .text) - where different types of data go
- External functions - calling C library (SDL2) from assembly
- Registers - CPU's temporary storage (rax, rdi, rsi, etc.)
- System calls - how to exit program properly
- Stack frame - setting up and cleaning up functions

**Files**: `main.asm`, `Makefile`

---

### Phase 2: Draw a Rectangle
**Goal**: Draw a white rectangle on screen

**What we'll create**:
- Renderer setup with SDL2
- Draw filled rectangle (our first visual!)
- Clear and present screen each frame

**Assembly concepts explained**:
- Memory addresses - passing pointers to SDL2 functions
- Structures - SDL_Rect structure for position/size
- Function parameters - x86-64 calling convention (rdi, rsi, rdx, rcx, r8, r9)

**Files**: Update `main.asm`

---

### Phase 3: Make Rectangle Move
**Goal**: Rectangle moves up/down with arrow keys

**What we'll create**:
- Input event handling
- Movement logic (change Y position)
- Boundary checking (don't go off screen)

**Assembly concepts explained**:
- Conditionals - compare and jump instructions (cmp, je, jl, jg)
- Variables - reading and writing memory locations
- Arithmetic - add/subtract to move objects

**Files**: Update `main.asm`

---

### Phase 4: Add Second Paddle
**Goal**: Two paddles, one on each side

**What we'll create**:
- Left paddle (W/S keys) and right paddle (Up/Down arrows)
- Separate movement logic for each paddle
- Separate boundary checking

**Assembly concepts explained**:
- Code organization - subroutines/functions to avoid repetition
- Parameters - passing values to functions
- Return values - getting results back

**Files**: Update `main.asm`, potentially split into `paddle.asm`, `input.asm`

---

### Phase 5: Add Ball & Physics
**Goal**: Ball bounces around screen and off paddles

**What we'll create**:
- Ball entity (position, velocity)
- Ball movement (update position each frame)
- Wall collision (top/bottom bounce)
- Paddle collision detection
- Ball velocity changes

**Assembly concepts explained**:
- Signed numbers - velocity can be positive/negative
- Collision math - checking if rectangles overlap
- State management - tracking ball direction

**Files**: Add `ball.asm`

---

### Phase 6: Scoring & Game Logic
**Goal**: Complete game with scoring

**What we'll create**:
- Score tracking (left/right player points)
- Score display (draw numbers on screen)
- Ball reset when point scored
- Win condition (first to 10 points)

**Assembly concepts explained**:
- Counters - incrementing scores
- Number to string conversion - displaying numbers
- Game states - playing vs game over

**Files**: Add `score.asm`, `text.asm`

---

### Phase 7: Polish & Improvements
**Goal**: Make it feel like real Pong

**What we'll add**:
- Frame rate limiting (60 FPS)
- Smooth movement
- Ball speed increases during rally
- Sound effects (optional)
- Start screen (optional)

**Assembly concepts explained**:
- Timing - SDL_GetTicks() for frame timing
- Loops - implementing delays
- Optimization - making code run efficiently

---

## Build Process

Each phase will use this build process:

```bash
# Assemble .asm files to object files
nasm -f elf64 main.asm -o main.o

# Link with SDL2 library
gcc -o pong main.o -lSDL2 -no-pie

# Run
./pong
```

The Makefile will automate this.

---

## Project Structure (Final)

```
pong/
├── PLAN.md           (this file)
├── README.md         (project overview)
├── CLAUDE.md         (instructions for Claude)
├── Makefile          (build automation)
├── main.asm          (entry point, main loop)
├── paddle.asm        (paddle logic)
├── ball.asm          (ball physics)
├── score.asm         (scoring logic)
├── text.asm          (text rendering)
└── constants.inc     (shared constants)
```

---

## Key Assembly Concepts Quick Reference

### Registers (x86-64)
- **rax**: Return values, general purpose
- **rdi, rsi, rdx, rcx, r8, r9**: First 6 function parameters
- **rsp**: Stack pointer (don't touch directly unless you know what you're doing!)
- **rbp**: Base pointer (for function stack frames)

### Common Instructions
- `mov dest, src`: Copy data
- `add dest, src`: Add
- `sub dest, src`: Subtract
- `cmp a, b`: Compare (sets flags)
- `je label`: Jump if equal
- `jne label`: Jump if not equal
- `jl label`: Jump if less than
- `jg label`: Jump if greater than
- `call function`: Call function
- `ret`: Return from function

### SDL2 Functions We'll Use
- `SDL_Init`: Initialize SDL
- `SDL_CreateWindow`: Make window
- `SDL_CreateRenderer`: Make renderer
- `SDL_PollEvent`: Get input events
- `SDL_SetRenderDrawColor`: Set draw color
- `SDL_RenderClear`: Clear screen
- `SDL_RenderFillRect`: Draw rectangle
- `SDL_RenderPresent`: Show what we drew
- `SDL_Delay`: Wait (for frame timing)
- `SDL_Quit`: Clean up SDL

---

## Learning Resources

As you work through this, you can reference:
- **NASM Manual**: https://www.nasm.us/doc/
- **SDL2 API**: https://wiki.libsdl.org/SDL2/APIByCategory
- **x86-64 ABI** (calling convention): System V AMD64 ABI

Don't worry about memorizing everything - we'll explain each concept when we use it!
