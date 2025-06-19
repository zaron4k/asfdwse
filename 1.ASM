format PE GUI 4.0
entry start

include 'D:\FASM\INCLUDE\win32a.inc'

ID_LISTBOX = 2

section '.code' code readable executable

start:
    invoke GetModuleHandle, 0
    mov esi, eax
    invoke DialogBoxParam, esi, 1, HWND_DESKTOP, DialogProc, 0
    invoke ExitProcess, 0

proc DialogProc hwnddlg, msg, wparam, lparam
    cmp [msg], WM_CLOSE
    je .FreeDialog

    cmp [msg], WM_INITDIALOG
    je .InitDialog

    cmp [msg], WM_COMMAND
    jne .ExitProc

    ; Проверяем событие двойного клика в ListBox
    mov eax, LBN_DBLCLK
    shl eax, 16
    add eax, ID_LISTBOX
    cmp [wparam], eax
    jne .ExitProc

    ; Получаем индекс выбранного элемента
    invoke SendDlgItemMessage, [hwnddlg], ID_LISTBOX, LB_GETCURSEL, 0, 0
    mov ebx, eax                 ; сохраняем индекс

    ; Получаем связанное с элементом значение (указатель на строку)
    invoke SendDlgItemMessage, [hwnddlg], ID_LISTBOX, LB_GETITEMDATA, ebx, 0

    ; Выводим MessageBox с текстом
    invoke MessageBox, [hwnddlg], eax, _Caption, MB_OK

    jmp .ExitProc

.InitDialog:
    invoke SendDlgItemMessage, [hwnddlg], ID_LISTBOX, LB_ADDSTRING, 0, _GoodMorning
    mov ebx, eax
    invoke SendDlgItemMessage, [hwnddlg], ID_LISTBOX, LB_SETITEMDATA, ebx, _GoodMorning

    invoke SendDlgItemMessage, [hwnddlg], ID_LISTBOX, LB_ADDSTRING, 0, _GoodDay
    mov ebx, eax
    invoke SendDlgItemMessage, [hwnddlg], ID_LISTBOX, LB_SETITEMDATA, ebx, _GoodDay

    invoke SendDlgItemMessage, [hwnddlg], ID_LISTBOX, LB_ADDSTRING, 0, _GoodEvening
    mov ebx, eax
    invoke SendDlgItemMessage, [hwnddlg], ID_LISTBOX, LB_SETITEMDATA, ebx, _GoodEvening

    invoke SendDlgItemMessage, [hwnddlg], ID_LISTBOX, LB_ADDSTRING, 0, _GoodNight
    mov ebx, eax
    invoke SendDlgItemMessage, [hwnddlg], ID_LISTBOX, LB_SETITEMDATA, ebx, _GoodNight

    xor eax, eax
    ret

.FreeDialog:
    invoke EndDialog, [hwnddlg], 0
    xor eax, eax
    ret

.ExitProc:
    xor eax, eax
    ret

endp

section '.data' data readable
    _GoodMorning db 'Доброе утро', 0
    _GoodDay     db 'Добрый день', 0
    _GoodEvening db 'Добрый вечер', 0
    _GoodNight   db 'Доброй ночи', 0
    _Caption     db 'Сообщение', 0

section '.idata' import data readable writeable
library kernel, 'KERNEL32.DLL',\
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

resource dialogs, 1, LANG_ENGLISH, form1

dialog form1, 'ListBox', 70, 70, 200, 100, WS_CAPTION + WS_SYSMENU + DS_CENTER
    dialogitem 'LISTBOX', '', ID_LISTBOX, 5, 5, 190, 90, WS_VISIBLE + LBS_SORT + LBS_NOTIFY
enddialog
