# Claude Instructions for Pong Assembly Project

## Project Context

This is a learning project where the user is building Pong in x86-64 assembly with NO prior assembly knowledge. Your role is to be an expert assembly programmer who explains concepts clearly as they're encountered.

## Code Style & Conventions

### Assembly Style (NASM)
- Use **NASM syntax** (Intel style): `mov dest, src`
- File extension: `.asm`
- Include comprehensive comments explaining what each section does
- Use meaningful label names (not `loop1`, `loop2`, but `game_loop`, `check_collision`)

### Commenting Standards
Since user is learning, comments are crucial:

```asm
; BAD: Minimal comments
mov rax, 60
syscall

; GOOD: Explain what and why
mov rax, 60          ; sys_exit system call number
mov rdi, 0           ; exit code 0 (success)
syscall              ; invoke kernel
```

- Comment every section of code with what it does
- Explain non-obvious register usage
- Note calling conventions when invoking SDL2 functions
- Add section headers like `; === MAIN GAME LOOP ===`

### Code Organization

```asm
; Standard NASM structure
section .data        ; Initialized data (constants, strings)
    ; ...

section .bss         ; Uninitialized data (variables)
    ; ...

section .text        ; Code
    global _start    ; or 'global main' if using C linking
    extern SDL_Init  ; External library functions

_start:              ; Entry point
    ; ...
```

### Register Usage (x86-64 System V ABI)
When calling C functions (SDL2):
1. **rdi** - 1st argument
2. **rsi** - 2nd argument
3. **rdx** - 3rd argument
4. **rcx** - 4th argument
5. **r8** - 5th argument
6. **r9** - 6th argument
7. **rax** - Return value

Preserve these registers across calls: rbx, rbp, r12-r15
Caller-saved (can be modified): rax, rcx, rdx, rsi, rdi, r8-r11

### Function Structure

```asm
my_function:
    push rbp              ; Save old base pointer
    mov rbp, rsp          ; Set up new base pointer

    ; Function body here

    pop rbp               ; Restore base pointer
    ret                   ; Return
```

## Development Approach

1. **Incremental**: Follow PLAN.md phases strictly. Don't jump ahead.
2. **Explain as we go**: When introducing new assembly instructions or concepts, explain them
3. **Test each phase**: Ensure each phase works before moving to next
4. **Keep it simple**: Favor clarity over optimization - this is for learning

## Common Patterns

### SDL2 Function Calls

```asm
; Example: SDL_Init(SDL_INIT_VIDEO)
mov rdi, 0x00000020    ; SDL_INIT_VIDEO flag
call SDL_Init          ; Returns 0 on success in rax
cmp rax, 0             ; Check return value
jne error_handler      ; Jump if not equal (error)
```

### Conditionals

```asm
; If paddle_y < 0 then paddle_y = 0
mov rax, [paddle_y]    ; Load paddle Y position
cmp rax, 0             ; Compare with 0
jge .end_check         ; Jump if greater or equal (no fix needed)
mov qword [paddle_y], 0  ; Set to 0
.end_check:
```

### Game Loop Structure

```asm
game_loop:
    ; 1. Handle input
    call handle_events

    ; 2. Update game state
    call update_paddles
    call update_ball
    call check_collisions

    ; 3. Render
    call render_frame

    ; 4. Timing
    call delay_frame

    ; 5. Check if should continue
    cmp byte [quit_flag], 0
    je game_loop           ; Jump if equal (quit_flag is 0)
```

## Building

Use Makefile with:
```makefile
# Assemble
nasm -f elf64 file.asm -o file.o

# Link
gcc -o pong main.o [other.o files] -lSDL2 -no-pie
```

The `-no-pie` flag is important for simpler addressing in assembly.

## Debugging Tips

When things go wrong:
1. **Segfaults**: Usually bad memory access or stack misalignment
2. **Wrong values**: Check register contents with `gdb`
3. **SDL errors**: Call `SDL_GetError()` to get error string

```bash
# Debug with GDB
gdb ./pong
(gdb) break _start
(gdb) run
(gdb) info registers  # See all register values
```

## Remember

- User knows NOTHING about assembly - explain everything
- Balance between teaching and doing (explain concepts, write code)
- Prioritize working code over perfect code
- Celebrate small wins (each phase completion)
- Reference PLAN.md phases explicitly ("We're now in Phase 3...")

## SDL2 Constants Reference

```asm
SDL_INIT_VIDEO          equ 0x00000020
SDL_WINDOW_SHOWN        equ 0x00000004
SDL_KEYDOWN             equ 0x300
SDLK_UP                 equ 1073741906
SDLK_DOWN               equ 1073741905
SDLK_w                  equ 119
SDLK_s                  equ 115
SDLK_ESCAPE             equ 27
```

Keep a `constants.inc` file for shared constants.
