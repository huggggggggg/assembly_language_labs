;-------------------------------------------------------------------;
;               Лабораторная работа #1 по ассемблеру                ;
;-------------------------------------------------------------------;
;   Автор программы:    Лианна Фарманова                            ;
;   Группа:             СБС-002-O-01                                ;
;   Вариант:            9                                           ;
;-------------------------------------------------------------------;
;   Эта программа может быть собрана с помощью команд:              ;
;   nasm -fwin32 lab1.asm                                           ;
;   GoLink /console /entry _start lab1.obj kernel32.dll msvcrt.dll  ;
;-------------------------------------------------------------------;

; extern - ключевое слово для импорта функции из внешнего модуля
extern printf       ; printf функция из модуля библиотеки msvcrt.dll - стандартной библиотеки C
extern scanf        ; scanf функция из модуля библиотеки msvcrt.dll - стандартной библиотеки C
extern ExitProcess  ; ExitProcess функция из модуля библиотеки kernel32.dll - стандартной библиотеки C
global _start       ; ключевое слово global указывает на то что метка _start будет видна из внешних модулей

; ключевое слово section обознает объявление секции

section .rdata          ; объявление секции данных с доступом на чтение
                        ; далее следует объявление областей памяти содержащих константные строки
    fmt                 db  "%d", 0                                      ; формат для scanf
    msgDivideByZero     db  "Can't divide by zero", 0xA, 0
    res                 db  0xA, "W1*W2 - D1/B1/W3 + W4 + B2*W5 = %d", 0xA, 0 ; 0xA - символ переноса аналогичный "\n" из C
    B1_s                db  "B1 (-128 - 127)  =  ", 0
    B2_s                db  "B2 (-128 - 127)  =  ", 0
    W1_s                db  "W1 (-32768 - 32767)  =  ", 0
    W2_s                db  "W2 (-32768 - 32767)  =  ", 0
    W3_s                db  "W3 (-32768 - 32767)  =  ", 0
    W4_s                db  "W4 (-32768 - 32767)  =  ", 0
    W5_s                db  "W5 (-32768 - 32767)  =  ", 0
    D1_s                db  "D1 (?2147483648 - 2147483647) =  ", 0

section .bss ;  секция неинициализированных данных
;               резервируем для каждой переменной dword
;               для корректного срабатывания функции scanf,
;               в дальнейшем будем обращаться к переменным 
;               по их размерности, которая указана в ТЗ
    B1    resd    1
    B2    resd    1
    W1    resd    1
    W2    resd    1
    W3    resd    1
    W4    resd    1
    W5    resd    1
    D1    resd    1

section .text      ; секция кода программы
_start:            ; метка _start EntryPoint(точка входа) в нашу программу
;   считываем пользвотельские данные, код для считывания будет повторяться для каждой переменной
    push B1_s      ; проталкиваем аргумент в стек для использвания его в функции printf
    call printf    ; вызываем функцию printf
    add esp, 4     ; чистим стек от аргумента который протолкнули ранее (чистим стек в ручную, из-за особенностей cdecl calling convension - соглашение о вызове функций), прибавляя к stack pointer разамер аргумента в байтах
    push B1        ; проталкиваем адрес переменной
    push fmt       ; проталкиваем форматирующую строку (проталкиваем в обратном порядке все аргументы)
    call scanf     ; вызываем scanf
    add esp,8      ; чистим стек, прибавляя в нему 8 байт (4 байта на адрес переменной + 4 байта на адрес форматирующей строки)
                   ; далее все действия аналогичны для каждой переменной
    push B2_s
    call printf
    add esp, 4
    push B2
    push fmt
    call scanf
    add esp,8
    
    push W1_s
    call printf
    add esp, 4
    push W1
    push fmt
    call scanf
    add esp,8
    
    push W2_s
    call printf
    add esp, 4
    push W2
    push fmt
    call scanf
    add esp,8
    
    push W3_s
    call printf
    add esp, 4
    push W3
    push fmt
    call scanf
    add esp,8
    
    push W4_s
    call printf
    add esp, 4
    push W4
    push fmt
    call scanf
    add esp,8
    
    push W5_s
    call printf
    add esp, 4
    push W5
    push fmt
    call scanf
    add esp,8
    
    push D1_s
    call printf
    add esp, 4
    push D1
    push fmt
    call scanf
    add esp,8
    
;   проверка деления на 0
    mov al, byte [B1]
    test al, al
    jz err
    mov ax, word [W3]
    test ax,ax
    jz err
    
;   считаем w1*w2 - d1/b1/w3 + w4 + b2*w5
    mov al, byte [B1]
    cbw
    mov bx, ax
    mov ax, word [D1]
    mov dx, word [D1+2]
    idiv bx
    cwd
    mov bx, word [W3]
    idiv bx
    cwd
    mov bx, ax
    mov cx, dx
    mov ax, word [W1]
    mov dx, word [W2]
    imul dx
    sub ax, bx
    sbb dx, cx
    mov bx, ax
    mov cx, dx
    mov ax, word [W4]
    cwd
    add bx, ax
    adc cx, dx
    mov al, byte [B2]
    cbw
    mov dx, word [W5]
    imul dx
    add ax, bx
    adc dx, cx
    
;   печатаем результат
    push dx
    push ax
    push res
    call printf
    add esp, 8
    
    jmp exit
err:
    push msgDivideByZero
    call printf
    add esp, 4
exit:
    push 0              ; проталкиваем код ошибки для функции ExitProcess (код ошибки 0 - нет ошибки)
    call ExitProcess    ; вызываем функцию
