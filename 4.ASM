format PE GUI 4.0
entry start
include 'D:\FASM\INCLUDE\win32a.inc'

ID_COMBOBOX = 2
ID_BUTTON = 3

section '.code' code readable executable

start:
    invoke GetModuleHandle, 0
    invoke DialogBoxParam, eax, 1, HWND_DESKTOP, DialogProc, 0
    invoke ExitProcess, 0

proc DialogProc hwnddlg, msg, wparam, lparam
    cmp [msg], WM_CLOSE
    je FreeDialog

    cmp [msg], WM_INITDIALOG
    je InitDialog

    cmp [msg], WM_COMMAND
    jne ExitProc

    mov eax, BN_CLICKED
    shl eax, 16
    add eax, ID_BUTTON
    cmp [wparam], eax
    jne ExitProc

    invoke SendDlgItemMessage, [hwnddlg], ID_COMBOBOX, CB_GETCURSEL, 0, 0
    mov esi, eax
    cmp esi, -1
    je ExitProc

    invoke SendDlgItemMessage, [hwnddlg], ID_COMBOBOX, CB_GETITEMDATA, esi, 0
    mov ebx, eax

    invoke MessageBox, [hwnddlg], ebx, _Caption, MB_OK

ExitProc:
    xor eax, eax
    ret

FreeDialog:
    invoke EndDialog, [hwnddlg], 0
    xor eax, eax
    ret

InitDialog:
    invoke SendDlgItemMessage, [hwnddlg], ID_COMBOBOX, CB_ADDSTRING, 0, _GoodMorning
    mov edi, eax
    invoke SendDlgItemMessage, [hwnddlg], ID_COMBOBOX, CB_SETITEMDATA, edi, _GoodMorning

    invoke SendDlgItemMessage, [hwnddlg], ID_COMBOBOX, CB_ADDSTRING, 0, _GoodDay
    mov edi, eax
    invoke SendDlgItemMessage, [hwnddlg], ID_COMBOBOX, CB_SETITEMDATA, edi, _GoodDay

    invoke SendDlgItemMessage, [hwnddlg], ID_COMBOBOX, CB_ADDSTRING, 0, _GoodEvening
    mov edi, eax
    invoke SendDlgItemMessage, [hwnddlg], ID_COMBOBOX, CB_SETITEMDATA, edi, _GoodEvening

    invoke SendDlgItemMessage, [hwnddlg], ID_COMBOBOX, CB_ADDSTRING, 0, _GoodNight
    mov edi, eax
    invoke SendDlgItemMessage, [hwnddlg], ID_COMBOBOX, CB_SETITEMDATA, edi, _GoodNight

    invoke SendDlgItemMessage, [hwnddlg], ID_COMBOBOX, CB_SETCURSEL, 0, 0

    xor eax, eax
    ret

endp

section '.data' data readable
_GoodMorning db 'Доброе утро', 0
_GoodDay db 'Добрый день', 0
_GoodEvening db 'Добрый вечер', 0
_GoodNight db 'Доброй ночи', 0
_Caption db 'Вы выбрали:', 0

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
       SendDlgItemMessage, 'SendDlgItemMessageA'

section '.rsrc' resource data readable
directory RT_DIALOG, dialogs

resource dialogs, 1, LANG_NEUTRAL, Dialog1
dialog Dialog1, 'ComboBox Example', 100, 100, 200, 130, WS_CAPTION + WS_SYSMENU + DS_CENTER
dialogitem 'ComboBox', '', ID_COMBOBOX, 10, 10, 150, 100, WS_VISIBLE + WS_TABSTOP + CBS_DROPDOWNLIST
dialogitem 'Button', 'Show Message', ID_BUTTON, 60, 115, 90, 20, WS_VISIBLE + WS_TABSTOP + BS_DEFPUSHBUTTON
enddialog
