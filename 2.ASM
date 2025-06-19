format PE GUI 4.0
entry start

include 'D:\FASM\INCLUDE\win32a.inc'

ID_CHECKBOX = 2    ; Идентификатор флажка
ID_BUTTON   = 3    ; Идентификатор кнопки

section '.code' code readable executable

start:
    invoke GetModuleHandle, 0
    mov esi, eax
    invoke DialogBoxParam, esi, 1, HWND_DESKTOP, DialogProc, 0
    invoke ExitProcess, 0

proc DialogProc hwnddlg, msg, wparam, lparam
    xor eax, eax

    cmp [msg], WM_CLOSE
    je .FreeDialog

    cmp [msg], WM_COMMAND
    jne .ExitProc

    mov eax, BN_CLICKED
    shl eax, 16
    add eax, ID_BUTTON
    cmp [wparam], eax
    jne .ExitProc

    ; Проверяем состояние чекбокса
    invoke IsDlgButtonChecked, [hwnddlg], ID_CHECKBOX
    cmp eax, BST_CHECKED
    je .Checked

    mov eax, _TextUnChecked
    jmp .ShowMessage

.Checked:
    mov eax, _TextChecked

.ShowMessage:
    invoke MessageBox, [hwnddlg], eax, NULL, MB_OK
    ret

.FreeDialog:
    invoke EndDialog, [hwnddlg], 0

.ExitProc:
    ret
endp

section '.data' readable
    _TextChecked   db 'Checked', 0
    _TextUnChecked db 'UnChecked', 0

section '.idata' import data readable writeable
library kernel, 'KERNEL32.DLL', \
        user, 'USER32.DLL'

import kernel, \
    GetModuleHandle, 'GetModuleHandleA', \
    ExitProcess, 'ExitProcess'

import user, \
    DialogBoxParam, 'DialogBoxParamA', \
    EndDialog, 'EndDialog', \
    MessageBox, 'MessageBoxA', \
    IsDlgButtonChecked, 'IsDlgButtonChecked'

section '.rsrc' resource data readable
directory RT_DIALOG, dialogs

resource dialogs, 1, LANG_NEUTRAL, WorkWithCheckBox

dialog WorkWithCheckBox, 'Checkbox Example', 0, 0, 150, 80, WS_CAPTION + WS_SYSMENU + DS_CENTER
    dialogitem 'Button', 'Checkbox', ID_CHECKBOX, 10, 10, 100, 20, WS_VISIBLE + BS_AUTOCHECKBOX
    dialogitem 'Button', 'Check', ID_BUTTON, 10, 40, 100, 25, WS_VISIBLE
enddialog
