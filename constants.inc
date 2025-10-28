; ============================================================================
; Constants for Pong Game
; ============================================================================
; This file contains all constant values used throughout the game.
; Constants are values that don't change during program execution.

; === SDL2 Initialization Flags ===
SDL_INIT_VIDEO          equ 0x00000020    ; Initialize video subsystem

; === SDL2 Window Flags ===
SDL_WINDOW_SHOWN        equ 0x00000004    ; Window is visible

; === SDL2 Renderer Flags ===
SDL_RENDERER_ACCELERATED equ 0x00000002   ; Use hardware acceleration
SDL_RENDERER_PRESENTVSYNC equ 0x00000004  ; Sync with monitor refresh rate

; === SDL2 Event Types ===
SDL_QUIT                equ 0x100         ; User requested quit (X button)
SDL_KEYDOWN             equ 0x300         ; Key pressed down
SDL_KEYUP               equ 0x301         ; Key released

; === SDL2 Key Codes ===
SDLK_ESCAPE             equ 27            ; Escape key
SDLK_w                  equ 119           ; W key (ASCII 'w')
SDLK_s                  equ 115           ; S key (ASCII 's')
SDLK_UP                 equ 1073741906    ; Up arrow
SDLK_DOWN               equ 1073741905    ; Down arrow

; === Screen Dimensions ===
SCREEN_WIDTH            equ 800           ; Window width in pixels
SCREEN_HEIGHT           equ 600           ; Window height in pixels

; === Paddle Dimensions ===
PADDLE_WIDTH            equ 15            ; Paddle width in pixels
PADDLE_HEIGHT           equ 80            ; Paddle height in pixels
PADDLE_SPEED            equ 6             ; Pixels per frame paddle moves
PADDLE_MARGIN           equ 30            ; Distance from screen edge

; === Ball Dimensions ===
BALL_SIZE               equ 12            ; Ball is square, this is width/height
BALL_SPEED_X            equ 5             ; Initial horizontal speed
BALL_SPEED_Y            equ 4             ; Initial vertical speed

; === Game Logic ===
WIN_SCORE               equ 10            ; Score needed to win
FPS_DELAY               equ 16            ; Milliseconds per frame (≈60 FPS)

; === Colors (RGBA format) ===
; Each color is 1 byte: Red, Green, Blue, Alpha (0-255)
COLOR_BLACK_R           equ 0
COLOR_BLACK_G           equ 0
COLOR_BLACK_B           equ 0
COLOR_BLACK_A           equ 255

COLOR_WHITE_R           equ 255
COLOR_WHITE_G           equ 255
COLOR_WHITE_B           equ 255
COLOR_WHITE_A           equ 255

; === System Call Numbers (Linux x86-64) ===
SYS_EXIT                equ 60            ; Exit program
