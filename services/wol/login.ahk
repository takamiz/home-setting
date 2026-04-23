; kabu STATION Auto Login (Improved Launch Version)
#Requires AutoHotkey v2.0
SetTitleMatchMode(2)

password := "doFPjDeY*RdjT8uA"
pythonExe := "C:\Program Files\Python312\python.exe"
pythonScript := "C:\Users\rdpuser\get_otp_oauth.py"
otpFile := "C:\Users\rdpuser\otp.txt"
kabusPath := "C:\Users\rdpuser\AppData\Local\kabuStation\KabuS.exe"

ToolTip("kabu-bot: Checking process...")

; 1. プロセスがなければ起動
if (!ProcessExist("KabuS.exe")) {
    ToolTip("kabu-bot: Starting KabuS.exe...")
    ; 作業ディレクトリを設定して起動の成功率を上げる
    SplitPath(kabusPath, &name, &dir)
    SetWorkingDir(dir)
    Run('"' kabusPath '"')
    
    ; 起動を待機
    if (!ProcessWait("KabuS.exe", 30)) {
        ToolTip("kabu-bot: Failed to launch KabuS.exe process.")
        Sleep(3000)
        ExitApp
    }
    Sleep(5000) ; 起動直後の安定待ち
}

; 2. ログインウィンドウの出現を待つ (最大120秒)
ToolTip("kabu-bot: Waiting for Login Window...")
if (WinWait("ahk_exe KabuS.exe", , 120)) {
    WinActivate("ahk_exe KabuS.exe")
    if (WinWaitActive("ahk_exe KabuS.exe", , 10)) {
        Sleep(2000) ; ウィンドウが完全に描画されるのを待つ
        
        ; パスワード入力
        ToolTip("kabu-bot: Typing Password...")
        SendEvent("^a{Backspace}")
        Sleep(500)
        SendEvent(password)
        Sleep(1500) ; ログインボタンが有効になるのを十分に待つ
        SendEvent("{Enter}")
        
        ; 3. OTP 取得ループ
        Loop 15 { ; 3秒おきに最大45秒間チェック
            ToolTip("kabu-bot: Fetching OTP (Attempt " A_Index ")...")
            
            if FileExist(otpFile)
                FileDelete(otpFile)

            RunWait(A_ComSpec ' /c ""' pythonExe '" "' pythonScript '" > "' otpFile '""', , "Hide")
            
            if (FileExist(otpFile)) {
                otp := Trim(FileRead(otpFile))
                if (RegExMatch(otp, "^\d{6}$")) {
                    ToolTip("kabu-bot: OTP Found [" otp "]. Final Login...")
                    WinActivate("ahk_exe KabuS.exe")
                    Sleep(1000)
                    SendEvent("^a{Backspace}")
                    Sleep(500)
                    SendEvent(otp)
                    Sleep(1000)
                    SendEvent("{Enter}")
                    ToolTip("kabu-bot: SUCCESS!")
                    Sleep(3000)
                    ToolTip()
                    ExitApp
                }
            }
            Sleep(3000) ; 3秒ごとにリトライ
        }
    }
}
ToolTip("kabu-bot: Failed or Timeout.")
Sleep(3000)
ToolTip()
ExitApp
