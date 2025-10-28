; ============================================================================
; PONG GAME - x86-64 Assembly with SDL2
; ============================================================================
; A complete implementation of the classic Pong game in assembly language.
; This code is heavily commented for learning purposes.

; Include our constants file
%include "constants.inc"

; Use relative addressing by default (modern NASM best practice)
default rel

; ============================================================================
; SECTION .data - Initialized Data
; ============================================================================
; This section contains data that has initial values when program starts.

section .data
    ; Window title (null-terminated string)
    window_title: db "Pong - Assembly Edition", 0

    ; SDL structures will be initialized at runtime, but we need these pointers
    ; We'll store actual memory addresses in the .bss section

; ============================================================================
; SECTION .bss - Uninitialized Data
; ============================================================================
; This section contains variables that will be initialized at runtime.
; Using .bss saves space in the executable file.

section .bss
    ; === SDL2 Pointers ===
    ; These will hold memory addresses returned by SDL2 functions
    window:         resq 1        ; SDL_Window* (8 bytes = quad word)
    renderer:       resq 1        ; SDL_Renderer* (8 bytes)

    ; === SDL2 Event Structure ===
    ; SDL_Event is 56 bytes, stores keyboard/mouse/quit events
    event:          resb 56       ; Reserve 56 bytes

    ; === Game State Flags ===
    running:        resb 1        ; 1 = game running, 0 = quit
    game_over:      resb 1        ; 1 = someone won, 0 = still playing

    ; === Left Paddle State ===
    ; Position is top-left corner of rectangle
    paddle_left_x:  resd 1        ; X position (4 bytes = double word)
    paddle_left_y:  resd 1        ; Y position
    paddle_left_up: resb 1        ; 1 = moving up, 0 = not
    paddle_left_down: resb 1      ; 1 = moving down, 0 = not

    ; === Right Paddle State ===
    paddle_right_x: resd 1        ; X position
    paddle_right_y: resd 1        ; Y position
    paddle_right_up: resb 1       ; 1 = moving up
    paddle_right_down: resb 1     ; 1 = moving down

    ; === Ball State ===
    ball_x:         resd 1        ; X position (center of ball)
    ball_y:         resd 1        ; Y position (center of ball)
    ball_vel_x:     resd 1        ; X velocity (can be negative)
    ball_vel_y:     resd 1        ; Y velocity (can be negative)

    ; === Scores ===
    score_left:     resd 1        ; Left player score
    score_right:    resd 1        ; Right player score

    ; === SDL Rectangles ===
    ; SDL_Rect structure: {x, y, w, h} - each field is 4 bytes (int)
    rect_paddle_left:  resd 4     ; 16 bytes total
    rect_paddle_right: resd 4     ; 16 bytes total
    rect_ball:         resd 4     ; 16 bytes total

; ============================================================================
; SECTION .text - Code
; ============================================================================
; This section contains the actual program instructions.

section .text
    ; Declare external SDL2 functions we'll call
    extern SDL_Init
    extern SDL_CreateWindow
    extern SDL_CreateRenderer
    extern SDL_DestroyRenderer
    extern SDL_DestroyWindow
    extern SDL_Quit
    extern SDL_PollEvent
    extern SDL_SetRenderDrawColor
    extern SDL_RenderClear
    extern SDL_RenderFillRect
    extern SDL_RenderPresent
    extern SDL_Delay

    ; Entry point - tell linker where to start
    global main

; ============================================================================
; MAIN FUNCTION
; ============================================================================
; This is where execution begins. We'll initialize SDL, set up the game,
; run the main loop, then clean up.

main:
    ; === Function Prologue ===
    ; Set up stack frame for this function
    push rbp                    ; Save old base pointer
    mov rbp, rsp                ; Set new base pointer to current stack

    ; === Initialize SDL2 ===
    ; Call SDL_Init(SDL_INIT_VIDEO)
    ; In x86-64, first argument goes in rdi register
    mov rdi, SDL_INIT_VIDEO     ; rdi = first parameter
    call SDL_Init               ; Returns 0 on success in rax
    cmp rax, 0                  ; Compare return value with 0
    jl .exit_error              ; Jump if less than 0 (error)

    ; === Create Window ===
    ; SDL_CreateWindow(title, x, y, width, height, flags)
    ; Parameters go in: rdi, rsi, rdx, rcx, r8, r9
    mov rdi, window_title       ; rdi = title string
    mov rsi, 100                ; rsi = x position (100px from left)
    mov rdx, 100                ; rdx = y position (100px from top)
    mov rcx, SCREEN_WIDTH       ; rcx = width
    mov r8, SCREEN_HEIGHT       ; r8 = height
    mov r9, SDL_WINDOW_SHOWN    ; r9 = flags
    call SDL_CreateWindow       ; Returns pointer in rax
    cmp rax, 0                  ; Check if NULL
    je .exit_error              ; Jump if equal (NULL = error)
    mov [window], rax           ; Save window pointer

    ; === Create Renderer ===
    ; SDL_CreateRenderer(window, index, flags)
    mov rdi, [window]           ; rdi = window pointer
    mov rsi, -1                 ; rsi = -1 (let SDL choose driver)
    mov rdx, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC
    call SDL_CreateRenderer     ; Returns pointer in rax
    cmp rax, 0                  ; Check if NULL
    je .exit_error              ; Jump if error
    mov [renderer], rax         ; Save renderer pointer

    ; === Initialize Game State ===
    call init_game              ; Set up initial positions and values

    ; === Main Game Loop ===
.game_loop:
    ; Check if we should keep running
    mov al, [running]           ; Load running flag (1 byte)
    cmp al, 0                   ; Compare with 0
    je .cleanup                 ; Jump if equal (exit loop)

    ; Process input events
    call handle_events          ; Check keyboard/quit events

    ; Update game logic (only if game not over)
    mov al, [game_over]         ; Check game_over flag
    cmp al, 0                   ; Is game still going?
    jne .skip_update            ; Jump if not equal (game over)

    call update_paddles         ; Move paddles based on input
    call update_ball            ; Move ball and check collisions

.skip_update:
    ; Render everything
    call render                 ; Draw all game objects

    ; Frame rate limiting (60 FPS)
    mov rdi, FPS_DELAY          ; rdi = milliseconds to wait
    call SDL_Delay              ; Sleep for this many ms

    jmp .game_loop              ; Loop back to start

.cleanup:
    ; === Clean Up SDL Resources ===
    ; Must destroy in reverse order of creation
    mov rdi, [renderer]         ; rdi = renderer pointer
    call SDL_DestroyRenderer    ; Free renderer

    mov rdi, [window]           ; rdi = window pointer
    call SDL_DestroyWindow      ; Free window

    call SDL_Quit               ; Shut down SDL

    ; === Exit Program Successfully ===
    mov rax, 0                  ; Return 0 (success)
    jmp .exit

.exit_error:
    ; === Exit with Error ===
    mov rax, 1                  ; Return 1 (error)

.exit:
    ; === Function Epilogue ===
    pop rbp                     ; Restore base pointer
    ret                         ; Return to OS

; ============================================================================
; INIT_GAME - Initialize Game State
; ============================================================================
; Sets all game variables to their starting values.

init_game:
    push rbp
    mov rbp, rsp

    ; Set running flag
    mov byte [running], 1       ; Game is running
    mov byte [game_over], 0     ; Game not over

    ; === Initialize Left Paddle ===
    mov dword [paddle_left_x], PADDLE_MARGIN
    ; Center vertically: (SCREEN_HEIGHT - PADDLE_HEIGHT) / 2
    mov eax, SCREEN_HEIGHT
    sub eax, PADDLE_HEIGHT
    shr eax, 1                  ; Divide by 2 (shift right 1 bit)
    mov [paddle_left_y], eax
    mov byte [paddle_left_up], 0
    mov byte [paddle_left_down], 0

    ; === Initialize Right Paddle ===
    mov eax, SCREEN_WIDTH
    sub eax, PADDLE_MARGIN
    sub eax, PADDLE_WIDTH
    mov [paddle_right_x], eax
    ; Center vertically (same as left)
    mov eax, SCREEN_HEIGHT
    sub eax, PADDLE_HEIGHT
    shr eax, 1
    mov [paddle_right_y], eax
    mov byte [paddle_right_up], 0
    mov byte [paddle_right_down], 0

    ; === Initialize Ball ===
    call reset_ball             ; Center ball and set velocity

    ; === Initialize Scores ===
    mov dword [score_left], 0
    mov dword [score_right], 0

    pop rbp
    ret

; ============================================================================
; RESET_BALL - Reset Ball to Center
; ============================================================================
; Called at game start and after each point scored.

reset_ball:
    push rbp
    mov rbp, rsp

    ; Center ball on screen
    mov eax, SCREEN_WIDTH
    shr eax, 1                  ; Divide by 2
    mov [ball_x], eax

    mov eax, SCREEN_HEIGHT
    shr eax, 1                  ; Divide by 2
    mov [ball_y], eax

    ; Set velocity (positive = right/down, negative = left/up)
    mov dword [ball_vel_x], BALL_SPEED_X
    mov dword [ball_vel_y], BALL_SPEED_Y

    pop rbp
    ret

; ============================================================================
; HANDLE_EVENTS - Process Input Events
; ============================================================================
; Checks for keyboard input and quit events.

handle_events:
    push rbp
    mov rbp, rsp

.event_loop:
    ; SDL_PollEvent(event*) - returns 1 if event exists, 0 if none
    mov rdi, event              ; rdi = pointer to event structure
    call SDL_PollEvent          ; Get next event
    cmp rax, 0                  ; Any events?
    je .done                    ; Jump if equal (no events left)

    ; Check event type (first 4 bytes of event structure)
    mov eax, [event]            ; Load event type

    ; === Check for Quit Event ===
    cmp eax, SDL_QUIT           ; User closed window?
    je .quit                    ; Jump if equal (quit)

    ; === Check for Key Press ===
    cmp eax, SDL_KEYDOWN        ; Key pressed?
    je .key_down                ; Jump if equal (handle key)

    ; === Check for Key Release ===
    cmp eax, SDL_KEYUP          ; Key released?
    je .key_up                  ; Jump if equal (handle key)

    jmp .event_loop             ; Check next event

.key_down:
    ; SDL_KeyboardEvent structure:
    ; type(4) + timestamp(4) + windowID(4) + state(1) + repeat(1) + pad(2) = 16 bytes
    ; Then keysym: scancode(4) + sym(4) at offset 16
    ; So sym is at offset 16 + 4 = 20
    mov eax, [event + 20]       ; Load key code (keysym.sym)

    ; Check for Escape (quit)
    cmp eax, SDLK_ESCAPE
    je .quit

    ; Check for W (left paddle up)
    cmp eax, SDLK_w
    jne .check_s
    mov byte [paddle_left_up], 1
    jmp .event_loop

.check_s:
    ; Check for S (left paddle down)
    cmp eax, SDLK_s
    jne .check_up
    mov byte [paddle_left_down], 1
    jmp .event_loop

.check_up:
    ; Check for Up Arrow (right paddle up)
    cmp eax, SDLK_UP
    jne .check_down
    mov byte [paddle_right_up], 1
    jmp .event_loop

.check_down:
    ; Check for Down Arrow (right paddle down)
    cmp eax, SDLK_DOWN
    jne .event_loop
    mov byte [paddle_right_down], 1
    jmp .event_loop

.key_up:
    ; Key released - stop paddle movement
    mov eax, [event + 20]       ; Load key code (keysym.sym)

    ; Check for W release
    cmp eax, SDLK_w
    jne .check_s_up
    mov byte [paddle_left_up], 0
    jmp .event_loop

.check_s_up:
    ; Check for S release
    cmp eax, SDLK_s
    jne .check_up_up
    mov byte [paddle_left_down], 0
    jmp .event_loop

.check_up_up:
    ; Check for Up Arrow release
    cmp eax, SDLK_UP
    jne .check_down_up
    mov byte [paddle_right_up], 0
    jmp .event_loop

.check_down_up:
    ; Check for Down Arrow release
    cmp eax, SDLK_DOWN
    jne .event_loop
    mov byte [paddle_right_down], 0
    jmp .event_loop

.quit:
    ; User wants to quit
    mov byte [running], 0       ; Stop game loop

.done:
    pop rbp
    ret

; ============================================================================
; UPDATE_PADDLES - Move Paddles Based on Input
; ============================================================================
; Updates paddle Y positions and enforces screen boundaries.

update_paddles:
    push rbp
    mov rbp, rsp

    ; === Update Left Paddle ===
    ; Check if moving up
    mov al, [paddle_left_up]
    cmp al, 0
    je .left_check_down         ; Not moving up

    ; Move up (decrease Y)
    mov eax, [paddle_left_y]
    sub eax, PADDLE_SPEED       ; Move up by PADDLE_SPEED pixels
    cmp eax, 0                  ; Check top boundary
    jge .left_set_y             ; Jump if >= 0 (valid position)
    mov eax, 0                  ; Clamp to 0
.left_set_y:
    mov [paddle_left_y], eax
    jmp .right_paddle           ; Done with left paddle

.left_check_down:
    ; Check if moving down
    mov al, [paddle_left_down]
    cmp al, 0
    je .right_paddle            ; Not moving down

    ; Move down (increase Y)
    mov eax, [paddle_left_y]
    add eax, PADDLE_SPEED       ; Move down
    mov ebx, SCREEN_HEIGHT
    sub ebx, PADDLE_HEIGHT      ; Maximum Y position
    cmp eax, ebx                ; Check bottom boundary
    jle .left_set_y2            ; Jump if <= max (valid)
    mov eax, ebx                ; Clamp to max
.left_set_y2:
    mov [paddle_left_y], eax

.right_paddle:
    ; === Update Right Paddle ===
    ; Check if moving up
    mov al, [paddle_right_up]
    cmp al, 0
    je .right_check_down

    ; Move up
    mov eax, [paddle_right_y]
    sub eax, PADDLE_SPEED
    cmp eax, 0
    jge .right_set_y
    mov eax, 0
.right_set_y:
    mov [paddle_right_y], eax
    jmp .done

.right_check_down:
    ; Check if moving down
    mov al, [paddle_right_down]
    cmp al, 0
    je .done

    ; Move down
    mov eax, [paddle_right_y]
    add eax, PADDLE_SPEED
    mov ebx, SCREEN_HEIGHT
    sub ebx, PADDLE_HEIGHT
    cmp eax, ebx
    jle .right_set_y2
    mov eax, ebx
.right_set_y2:
    mov [paddle_right_y], eax

.done:
    pop rbp
    ret

; ============================================================================
; UPDATE_BALL - Move Ball and Handle Collisions
; ============================================================================
; Updates ball position, checks for collisions with walls and paddles,
; and handles scoring.

update_ball:
    push rbp
    mov rbp, rsp

    ; === Move Ball ===
    ; Update X position
    mov eax, [ball_x]
    add eax, [ball_vel_x]       ; ball_x += ball_vel_x
    mov [ball_x], eax

    ; Update Y position
    mov eax, [ball_y]
    add eax, [ball_vel_y]       ; ball_y += ball_vel_y
    mov [ball_y], eax

    ; === Check Top/Bottom Wall Collision ===
    ; Check top wall
    mov eax, [ball_y]
    cmp eax, BALL_SIZE / 2      ; Compare with half ball size
    jg .check_bottom            ; Jump if greater (not hitting top)

    ; Hit top wall - bounce (negate Y velocity)
    mov eax, [ball_vel_y]
    neg eax                     ; Negate (flip sign)
    mov [ball_vel_y], eax
    mov dword [ball_y], BALL_SIZE / 2  ; Position at edge

.check_bottom:
    ; Check bottom wall
    mov eax, [ball_y]
    mov ebx, SCREEN_HEIGHT
    sub ebx, BALL_SIZE / 2      ; Bottom boundary
    cmp eax, ebx
    jl .check_paddle_collision  ; Jump if less (not hitting bottom)

    ; Hit bottom wall - bounce
    mov eax, [ball_vel_y]
    neg eax
    mov [ball_vel_y], eax
    mov [ball_y], ebx           ; Position at edge

.check_paddle_collision:
    ; === Check Left Paddle Collision ===
    ; Ball must be on left side and overlapping paddle
    mov eax, [ball_x]
    sub eax, BALL_SIZE / 2      ; Ball left edge
    mov ebx, PADDLE_MARGIN
    add ebx, PADDLE_WIDTH       ; Paddle right edge
    cmp eax, ebx                ; Is ball left edge past paddle right?
    jg .check_right_paddle      ; Jump if greater (no collision)

    ; Ball X overlaps, check Y overlap
    mov eax, [ball_y]
    mov ebx, [paddle_left_y]    ; Paddle top
    cmp eax, ebx                ; Is ball below paddle top?
    jl .check_right_paddle      ; Jump if less (no collision)

    mov ebx, [paddle_left_y]
    add ebx, PADDLE_HEIGHT      ; Paddle bottom
    cmp eax, ebx                ; Is ball above paddle bottom?
    jg .check_right_paddle      ; Jump if greater (no collision)

    ; Collision! Bounce ball
    mov eax, [ball_vel_x]
    neg eax                     ; Reverse X direction
    mov [ball_vel_x], eax

    ; Move ball out of paddle
    mov eax, PADDLE_MARGIN
    add eax, PADDLE_WIDTH
    add eax, BALL_SIZE / 2
    mov [ball_x], eax
    jmp .done

.check_right_paddle:
    ; === Check Right Paddle Collision ===
    mov eax, [ball_x]
    add eax, BALL_SIZE / 2      ; Ball right edge
    mov ebx, [paddle_right_x]   ; Paddle left edge
    cmp eax, ebx                ; Is ball right edge before paddle left?
    jl .check_scoring           ; Jump if less (no collision)

    ; Ball X overlaps, check Y overlap
    mov eax, [ball_y]
    mov ebx, [paddle_right_y]   ; Paddle top
    cmp eax, ebx
    jl .check_scoring

    mov ebx, [paddle_right_y]
    add ebx, PADDLE_HEIGHT
    cmp eax, ebx
    jg .check_scoring

    ; Collision! Bounce ball
    mov eax, [ball_vel_x]
    neg eax
    mov [ball_vel_x], eax

    ; Move ball out of paddle
    mov eax, [paddle_right_x]
    sub eax, BALL_SIZE / 2
    mov [ball_x], eax
    jmp .done

.check_scoring:
    ; === Check if Ball Went Off Screen (Score Point) ===
    ; Check left side (right player scores)
    mov eax, [ball_x]
    cmp eax, 0
    jg .check_right_side        ; Jump if greater (still on screen)

    ; Right player scored
    mov eax, [score_right]
    inc eax                     ; Increment score
    mov [score_right], eax

    ; Check for win
    cmp eax, WIN_SCORE
    jge .game_over              ; Jump if >= WIN_SCORE

    ; Reset ball
    call reset_ball
    jmp .done

.check_right_side:
    ; Check right side (left player scores)
    mov eax, [ball_x]
    cmp eax, SCREEN_WIDTH
    jl .done                    ; Jump if less (still on screen)

    ; Left player scored
    mov eax, [score_left]
    inc eax
    mov [score_left], eax

    ; Check for win
    cmp eax, WIN_SCORE
    jge .game_over

    ; Reset ball
    call reset_ball
    jmp .done

.game_over:
    ; Someone won!
    mov byte [game_over], 1

.done:
    pop rbp
    ret

; ============================================================================
; DRAW_DIGIT - Draw a single digit (0-9) on screen
; ============================================================================
; Parameters (passed via registers):
;   rdi = renderer pointer
;   rsi = digit (0-9)
;   rdx = x position (center of digit)
;   rcx = y position (top of digit)
;
; Draws a digit using 7-segment display style with rectangles

draw_digit:
    push rbp
    mov rbp, rsp
    push r12
    push r13
    push r14
    push r15
    sub rsp, 8                  ; Align stack to 16 bytes for SDL calls

    ; Save parameters
    mov r12, rdi                ; r12 = renderer pointer
    mov r13d, esi               ; r13 = digit
    mov r14d, edx               ; r14 = x position
    mov r15d, ecx               ; r15 = y position

    ; Digit dimensions
    %define DIGIT_WIDTH 30
    %define DIGIT_HEIGHT 50
    %define SEGMENT_THICK 6

    ; === Define which segments to draw for each digit ===
    ; Segments: top, top-right, bottom-right, bottom, bottom-left, top-left, middle
    ; Bit 0 = top, bit 1 = top-right, bit 2 = bottom-right, bit 3 = bottom
    ; bit 4 = bottom-left, bit 5 = top-left, bit 6 = middle

    ; Segment patterns for digits 0-9
    ; 0 = 0111111 (all except middle)
    ; 1 = 0000110 (top-right, bottom-right)
    ; 2 = 1011011 (top, top-right, middle, bottom-left, bottom)
    ; 3 = 1001111 (top, top-right, middle, bottom-right, bottom)
    ; 4 = 1100110 (top-left, middle, top-right, bottom-right)
    ; 5 = 1101101 (top, top-left, middle, bottom-right, bottom)
    ; 6 = 1111101 (top, top-left, middle, bottom-left, bottom, bottom-right)
    ; 7 = 0000111 (top, top-right, bottom-right)
    ; 8 = 1111111 (all segments)
    ; 9 = 1101111 (all except bottom-left)

    ; Get segment pattern for this digit
    mov eax, r13d               ; eax = digit
    cmp eax, 0
    je .digit_0
    cmp eax, 1
    je .digit_1
    cmp eax, 2
    je .digit_2
    cmp eax, 3
    je .digit_3
    cmp eax, 4
    je .digit_4
    cmp eax, 5
    je .digit_5
    cmp eax, 6
    je .digit_6
    cmp eax, 7
    je .digit_7
    cmp eax, 8
    je .digit_8
    cmp eax, 9
    je .digit_9
    jmp .done                   ; Invalid digit

.digit_0:
    mov ebx, 0b0111111
    jmp .draw_segments
.digit_1:
    mov ebx, 0b0000110
    jmp .draw_segments
.digit_2:
    mov ebx, 0b1011011
    jmp .draw_segments
.digit_3:
    mov ebx, 0b1001111
    jmp .draw_segments
.digit_4:
    mov ebx, 0b1100110
    jmp .draw_segments
.digit_5:
    mov ebx, 0b1101101
    jmp .draw_segments
.digit_6:
    mov ebx, 0b1111101
    jmp .draw_segments
.digit_7:
    mov ebx, 0b0000111
    jmp .draw_segments
.digit_8:
    mov ebx, 0b1111111
    jmp .draw_segments
.digit_9:
    mov ebx, 0b1101111

.draw_segments:
    ; rbx contains segment pattern (7 bits)
    ; Draw each segment if its bit is set

    ; === Segment 0: Top horizontal ===
    test ebx, 0b0000001
    jz .seg1
    mov eax, r14d
    sub eax, DIGIT_WIDTH / 2
    mov [rect_ball], eax
    mov [rect_ball + 4], r15d
    mov dword [rect_ball + 8], DIGIT_WIDTH
    mov dword [rect_ball + 12], SEGMENT_THICK
    mov rdi, r12
    lea rsi, [rect_ball]
    call SDL_RenderFillRect

.seg1:
    ; === Segment 1: Top-right vertical ===
    test ebx, 0b0000010
    jz .seg2
    mov eax, r14d
    add eax, DIGIT_WIDTH / 2 - SEGMENT_THICK
    mov [rect_ball], eax
    mov [rect_ball + 4], r15d
    mov dword [rect_ball + 8], SEGMENT_THICK
    mov dword [rect_ball + 12], DIGIT_HEIGHT / 2
    mov rdi, r12
    lea rsi, [rect_ball]
    call SDL_RenderFillRect

.seg2:
    ; === Segment 2: Bottom-right vertical ===
    test ebx, 0b0000100
    jz .seg3
    mov eax, r14d
    add eax, DIGIT_WIDTH / 2 - SEGMENT_THICK
    mov [rect_ball], eax
    mov eax, r15d
    add eax, DIGIT_HEIGHT / 2
    mov [rect_ball + 4], eax
    mov dword [rect_ball + 8], SEGMENT_THICK
    mov dword [rect_ball + 12], DIGIT_HEIGHT / 2
    mov rdi, r12
    lea rsi, [rect_ball]
    call SDL_RenderFillRect

.seg3:
    ; === Segment 3: Bottom horizontal ===
    test ebx, 0b0001000
    jz .seg4
    mov eax, r14d
    sub eax, DIGIT_WIDTH / 2
    mov [rect_ball], eax
    mov eax, r15d
    add eax, DIGIT_HEIGHT - SEGMENT_THICK
    mov [rect_ball + 4], eax
    mov dword [rect_ball + 8], DIGIT_WIDTH
    mov dword [rect_ball + 12], SEGMENT_THICK
    mov rdi, r12
    lea rsi, [rect_ball]
    call SDL_RenderFillRect

.seg4:
    ; === Segment 4: Bottom-left vertical ===
    test ebx, 0b0010000
    jz .seg5
    mov eax, r14d
    sub eax, DIGIT_WIDTH / 2
    mov [rect_ball], eax
    mov eax, r15d
    add eax, DIGIT_HEIGHT / 2
    mov [rect_ball + 4], eax
    mov dword [rect_ball + 8], SEGMENT_THICK
    mov dword [rect_ball + 12], DIGIT_HEIGHT / 2
    mov rdi, r12
    lea rsi, [rect_ball]
    call SDL_RenderFillRect

.seg5:
    ; === Segment 5: Top-left vertical ===
    test ebx, 0b0100000
    jz .seg6
    mov eax, r14d
    sub eax, DIGIT_WIDTH / 2
    mov [rect_ball], eax
    mov [rect_ball + 4], r15d
    mov dword [rect_ball + 8], SEGMENT_THICK
    mov dword [rect_ball + 12], DIGIT_HEIGHT / 2
    mov rdi, r12
    lea rsi, [rect_ball]
    call SDL_RenderFillRect

.seg6:
    ; === Segment 6: Middle horizontal ===
    test ebx, 0b1000000
    jz .done
    mov eax, r14d
    sub eax, DIGIT_WIDTH / 2
    mov [rect_ball], eax
    mov eax, r15d
    add eax, DIGIT_HEIGHT / 2 - SEGMENT_THICK / 2
    mov [rect_ball + 4], eax
    mov dword [rect_ball + 8], DIGIT_WIDTH
    mov dword [rect_ball + 12], SEGMENT_THICK
    mov rdi, r12
    lea rsi, [rect_ball]
    call SDL_RenderFillRect

.done:
    add rsp, 8                  ; Restore stack alignment
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    ret

; ============================================================================
; RENDER - Draw Everything
; ============================================================================
; Clears screen and draws paddles, ball, and scores.

render:
    push rbp
    mov rbp, rsp
    push r12                    ; Save r12 (used for center line loop)
    push r13                    ; Save r13 (used for score loop)

    ; === Clear Screen (Black) ===
    mov rdi, [renderer]         ; rdi = renderer
    mov rsi, COLOR_BLACK_R      ; rsi = red
    mov rdx, COLOR_BLACK_G      ; rdx = green
    mov rcx, COLOR_BLACK_B      ; rcx = blue
    mov r8, COLOR_BLACK_A       ; r8 = alpha
    call SDL_SetRenderDrawColor

    mov rdi, [renderer]
    call SDL_RenderClear        ; Clear with current color

    ; === Set Draw Color to White ===
    mov rdi, [renderer]
    mov rsi, COLOR_WHITE_R
    mov rdx, COLOR_WHITE_G
    mov rcx, COLOR_WHITE_B
    mov r8, COLOR_WHITE_A
    call SDL_SetRenderDrawColor

    ; === Draw Left Paddle ===
    ; Fill SDL_Rect structure
    mov eax, [paddle_left_x]
    mov [rect_paddle_left], eax     ; x
    mov eax, [paddle_left_y]
    mov [rect_paddle_left + 4], eax ; y
    mov dword [rect_paddle_left + 8], PADDLE_WIDTH    ; w
    mov dword [rect_paddle_left + 12], PADDLE_HEIGHT  ; h

    mov rdi, [renderer]
    lea rsi, [rect_paddle_left]     ; rsi = pointer to rect
    call SDL_RenderFillRect

    ; === Draw Right Paddle ===
    mov eax, [paddle_right_x]
    mov [rect_paddle_right], eax
    mov eax, [paddle_right_y]
    mov [rect_paddle_right + 4], eax
    mov dword [rect_paddle_right + 8], PADDLE_WIDTH
    mov dword [rect_paddle_right + 12], PADDLE_HEIGHT

    mov rdi, [renderer]
    lea rsi, [rect_paddle_right]
    call SDL_RenderFillRect

    ; === Draw Ball ===
    ; Ball position is center, but SDL_Rect uses top-left
    mov eax, [ball_x]
    sub eax, BALL_SIZE / 2          ; Convert to top-left
    mov [rect_ball], eax
    mov eax, [ball_y]
    sub eax, BALL_SIZE / 2
    mov [rect_ball + 4], eax
    mov dword [rect_ball + 8], BALL_SIZE
    mov dword [rect_ball + 12], BALL_SIZE

    mov rdi, [renderer]
    lea rsi, [rect_ball]
    call SDL_RenderFillRect

    ; === Draw Center Line ===
    ; Draw dashed line down middle of screen
    mov r12d, 0                     ; Y position counter
.center_line_loop:
    cmp r12d, SCREEN_HEIGHT
    jge .center_line_done

    ; Draw small rectangle
    mov eax, SCREEN_WIDTH / 2 - 2
    mov [rect_ball], eax            ; Reuse rect_ball temporarily
    mov [rect_ball + 4], r12d
    mov dword [rect_ball + 8], 4    ; Width
    mov dword [rect_ball + 12], 10  ; Height

    mov rdi, [renderer]
    lea rsi, [rect_ball]
    call SDL_RenderFillRect

    add r12d, 15                    ; Space between dashes
    jmp .center_line_loop

.center_line_done:
    ; === Draw Score Indicators (Simple Dots) ===
    ; Draw left score as dots
    mov r13d, 0                 ; Counter
.draw_left_score:
    cmp r13d, [score_left]
    jge .draw_right_score_start

    ; Draw a small square for each point
    mov eax, r13d
    imul eax, 20                ; Space dots 20px apart
    add eax, 50                 ; Start position
    mov [rect_ball], eax
    mov dword [rect_ball + 4], 30
    mov dword [rect_ball + 8], 12
    mov dword [rect_ball + 12], 12

    mov rdi, [renderer]
    lea rsi, [rect_ball]
    call SDL_RenderFillRect

    inc r13d
    jmp .draw_left_score

.draw_right_score_start:
    ; Draw right score as dots
    mov r13d, 0
.draw_right_score:
    cmp r13d, [score_right]
    jge .present_frame

    ; Draw a small square for each point
    mov eax, r13d
    imul eax, 20                ; Space dots 20px apart
    add eax, SCREEN_WIDTH - 250 ; Start position (right side)
    mov [rect_ball], eax
    mov dword [rect_ball + 4], 30
    mov dword [rect_ball + 8], 12
    mov dword [rect_ball + 12], 12

    mov rdi, [renderer]
    lea rsi, [rect_ball]
    call SDL_RenderFillRect

    inc r13d
    jmp .draw_right_score

.present_frame:
    ; === Present Renderer ===
    ; Show everything we drew
    mov rdi, [renderer]
    call SDL_RenderPresent

    pop r13                     ; Restore r13
    pop r12                     ; Restore r12
    pop rbp
    ret
