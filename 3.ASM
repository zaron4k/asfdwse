format PE GUI 4.0
entry start
include 'D:\FASM\INCLUDE\win32a.inc'

; Идентификаторы элементов управления
ID_BUTTONSHOWMESSAGE = 3
ID_BUTTONCANCEL     = 10h
ID_MESSAGETEXT      = 4
ID_HELLO            = 5
ID_GOODMORNING      = 6
ID_GOODDAY          = 7
ID_GOODEVENING      = 8
ID_GOODNIGHT        = 9
ID_BUTTONS          = 0Ah
ID_OK               = 0Bh
ID_OKCANCEL         = 0Ch
ID_RETRYCANCEL      = 0Dh
ID_YESNO            = 0Eh
ID_YESNOCANCEL      = 0Fh

section '.code' code readable executable
start:
    invoke GetModuleHandle, 0
    invoke DialogBoxParam, eax, 1, HWND_DESKTOP, DialogProc, 0
    invoke ExitProcess, 0

proc DialogProc hwnddlg, msg, wparam, lparam
    xor eax, eax
    cmp [msg], WM_CLOSE
    je FreeDialog

    cmp [msg], WM_INITDIALOG
    je InitDialog

    cmp [msg], WM_COMMAND
    jne ExitProc

    mov eax, BN_CLICKED
    shl eax, 10h
    add eax, ID_BUTTONCANCEL
    cmp [wparam], eax
    je FreeDialog

    sub eax, ID_BUTTONCANCEL
    add eax, ID_BUTTONSHOWMESSAGE
    cmp [wparam], eax
    jne ExitProc

    ; Проверяем выбранное сообщение
    invoke IsDlgButtonChecked, [hwnddlg], ID_HELLO
    cmp eax, BST_CHECKED
    jne CheckGoodMorning
    mov eax, _TextHello
    mov dword [_TextMessage], eax
    jmp FindButtons

CheckGoodMorning:
    invoke IsDlgButtonChecked, [hwnddlg], ID_GOODMORNING
    cmp eax, BST_CHECKED
    jne CheckGoodDay
    mov eax, _TextGoodMorning
    mov dword [_TextMessage], eax
    jmp FindButtons

CheckGoodDay:
    invoke IsDlgButtonChecked, [hwnddlg], ID_GOODDAY
    cmp eax, BST_CHECKED
    jne CheckGoodEvening
    mov eax, _TextGoodDay
    mov dword [_TextMessage], eax
    jmp FindButtons

CheckGoodEvening:
    invoke IsDlgButtonChecked, [hwnddlg], ID_GOODEVENING
    cmp eax, BST_CHECKED
    jne CheckGoodNight
    mov eax, _TextGoodEvening
    mov dword [_TextMessage], eax
    jmp FindButtons

CheckGoodNight:
    mov eax, _TextGoodNight
    mov dword [_TextMessage], eax

FindButtons:
    ; Определяем выбранные кнопки
    invoke IsDlgButtonChecked, [hwnddlg], ID_OK
    cmp eax, BST_CHECKED
    jne CheckOkCancel
    mov dword [_Buttons], MB_OK
    jmp ShowMessage

CheckOkCancel:
    invoke IsDlgButtonChecked, [hwnddlg], ID_OKCANCEL
    cmp eax, BST_CHECKED
    jne CheckRetryCancel
    mov dword [_Buttons], MB_OKCANCEL
    jmp ShowMessage

CheckRetryCancel:
    invoke IsDlgButtonChecked, [hwnddlg], ID_RETRYCANCEL
    cmp eax, BST_CHECKED
    jne CheckYesNo
    mov dword [_Buttons], MB_RETRYCANCEL
    jmp ShowMessage

CheckYesNo:
    invoke IsDlgButtonChecked, [hwnddlg], ID_YESNO
    cmp eax, BST_CHECKED
    jne CheckYesNoCancel
    mov dword [_Buttons], MB_YESNO
    jmp ShowMessage

CheckYesNoCancel:
    mov dword [_Buttons], MB_YESNOCANCEL

ShowMessage:
    invoke MessageBox, [hwnddlg], dword [_TextMessage], dword [_TextMessage], dword [_Buttons]
    ret

FreeDialog:
    invoke EndDialog, [hwnddlg], 0

ExitProc:
    ret

InitDialog:
    ; Устанавливаем надписи кнопок и радио-кнопок
    invoke SetDlgItemText, [hwnddlg], ID_BUTTONSHOWMESSAGE, _TextButtonShowMessage
    invoke SetDlgItemText, [hwnddlg], ID_BUTTONCANCEL, _TextButtonCancel
    invoke SetDlgItemText, [hwnddlg], ID_HELLO, _TextHello
    invoke SetDlgItemText, [hwnddlg], ID_GOODMORNING, _TextGoodMorning
    invoke SetDlgItemText, [hwnddlg], ID_GOODDAY, _TextGoodDay
    invoke SetDlgItemText, [hwnddlg], ID_GOODEVENING, _TextGoodEvening
    invoke SetDlgItemText, [hwnddlg], ID_GOODNIGHT, _TextGoodNight
    invoke SetDlgItemText, [hwnddlg], ID_BUTTONS, _TextButtons
    invoke SetDlgItemText, [hwnddlg], ID_MESSAGETEXT, _TextMessages
    invoke SetDlgItemText, [hwnddlg], ID_OK, _TextOk
    invoke SetDlgItemText, [hwnddlg], ID_OKCANCEL, _TextOkCancel
    invoke SetDlgItemText, [hwnddlg], ID_RETRYCANCEL, _TextRetryCancel
    invoke SetDlgItemText, [hwnddlg], ID_YESNO, _TextYesNo
    invoke SetDlgItemText, [hwnddlg], ID_YESNOCANCEL, _TextYesNoCancel

    ; Устанавливаем выбранные по умолчанию радио-кнопки
    invoke SendDlgItemMessage, [hwnddlg], ID_HELLO, BM_SETCHECK, BST_CHECKED, 0
    invoke SendDlgItemMessage, [hwnddlg], ID_OK, BM_SETCHECK, BST_CHECKED, 0

    xor eax, eax
    ret
endp

section '.data' readable
_TextButtonShowMessage db 'Show Message', 0
_TextButtonCancel      db 'Cancel', 0
_TextHello             db 'Hello', 0
_TextGoodMorning       db 'Good Morning', 0
_TextGoodDay           db 'Good Day', 0
_TextGoodEvening       db 'Good Evening', 0
_TextGoodNight         db 'Good Night', 0
_TextButtons           db 'Buttons', 0
_TextMessages          db 'Messages', 0
_TextOk                db 'OK', 0
_TextOkCancel          db 'OK, Cancel', 0
_TextRetryCancel       db 'Retry, Cancel', 0
_TextYesNo             db 'Yes, No', 0
_TextYesNoCancel       db 'Yes, No, Cancel', 0

section '.bss' data readable writeable
_Buttons dd 0
_TextMessage dd 0

section '.idata' import data readable writeable
library kernel, 'KERNEL32.DLL', \
        user, 'USER32.DLL'

import kernel,\
       GetModuleHandle, 'GetModuleHandleA',\
       ExitProcess, 'ExitProcess'

import user,\
       DialogBoxParam, 'DialogBoxParamA',\
       EndDialog, 'EndDialog',\
       MessageBox, 'MessageBoxA',\
       IsDlgButtonChecked, 'IsDlgButtonChecked',\
       SetDlgItemText, 'SetDlgItemTextA',\
       SendDlgItemMessage, 'SendDlgItemMessageA'

section '.rsrc' resource data readable

directory RT_DIALOG, dialogs

resource dialogs, 1, LANG_NEUTRAL, WorkWithEdit

dialog WorkWithEdit, 'Checkbox', 0, 0, 170, 95, WS_CAPTION + WS_SYSMENU + DS_CENTER

    dialogitem 'Button', 'Message text', ID_MESSAGETEXT, 5, 5, 70, 65, WS_VISIBLE + BS_GROUPBOX

    dialogitem 'Button', '', ID_HELLO, 7, 15, 60, 12, WS_VISIBLE + BS_AUTORADIOBUTTON + WS_GROUP
    dialogitem 'Button', '', ID_GOODMORNING, 7, 25, 60, 12, WS_VISIBLE + BS_AUTORADIOBUTTON
    dialogitem 'Button', '', ID_GOODDAY, 7, 35, 60, 12, WS_VISIBLE + BS_AUTORADIOBUTTON
    dialogitem 'Button', '', ID_GOODEVENING, 7, 45, 65, 12, WS_VISIBLE + BS_AUTORADIOBUTTON
    dialogitem 'Button', '', ID_GOODNIGHT, 7, 55, 60, 12, WS_VISIBLE + BS_AUTORADIOBUTTON

    dialogitem 'Button', '', ID_BUTTONS, 80, 5, 80, 65, WS_VISIBLE + BS_GROUPBOX

    dialogitem 'Button', '', ID_OK, 82, 15, 30, 12, WS_VISIBLE + BS_AUTORADIOBUTTON + WS_GROUP
    dialogitem 'Button', '', ID_OKCANCEL, 82, 25, 60, 12, WS_VISIBLE + BS_AUTORADIOBUTTON
    dialogitem 'Button', '', ID_RETRYCANCEL, 82, 35, 70, 12, WS_VISIBLE + BS_AUTORADIOBUTTON
    dialogitem 'Button', '', ID_YESNO, 82, 45, 60, 12, WS_VISIBLE + BS_AUTORADIOBUTTON
    dialogitem 'Button', '', ID_YESNOCANCEL, 82, 55, 70, 12, WS_VISIBLE + BS_AUTORADIOBUTTON

    dialogitem 'Button', '', ID_BUTTONSHOWMESSAGE, 5, 75, 80, 15, WS_VISIBLE
    dialogitem 'Button', '', ID_BUTTONCANCEL, 90, 75, 60, 15, WS_VISIBLE

enddialog
