; kabu STATION Auto Login (Optimized Version)
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
    Run(kabusPath)
}

; 2. ログインウィンドウの出現を待つ (最大120秒)
ToolTip("kabu-bot: Waiting for Login Window...")
if (WinWait("ahk_exe KabuS.exe", , 120)) {
    WinActivate("ahk_exe KabuS.exe")
    WinWaitActive("ahk_exe KabuS.exe", , 5) ; アクティブになるのを待つ
    Sleep(500) ; 念のための安定待ち
    
    ; パスワード入力
    ToolTip("kabu-bot: Typing Password...")
    Send("^a{Backspace}")
    Sleep(200)
    Send(password)
    Sleep(300)
    Send("{Enter}")
    
    ; 3. OTP 取得ループ
    Loop 12 { ; 3秒おきに最大36秒間チェック
        ToolTip("kabu-bot: Fetching OTP (Attempt " A_Index ")...")
        
        ; 以前の OTP ファイルがあれば削除
        if FileExist(otpFile)
            FileDelete(otpFile)

        RunWait(A_ComSpec ' /c ""' pythonExe '" "' pythonScript '" > "' otpFile '""', , "Hide")
        
        if (FileExist(otpFile)) {
            otp := Trim(FileRead(otpFile))
            if (RegExMatch(otp, "^\d{6}$")) {
                ToolTip("kabu-bot: OTP Found [" otp "]. Final Login...")
                WinActivate("ahk_exe KabuS.exe")
                Sleep(500)
                Send("^a{Backspace}")
                Sleep(200)
                Send(otp)
                Sleep(300)
                Send("{Enter}")
                ToolTip("kabu-bot: SUCCESS!")
                Sleep(2000)
                ToolTip()
                ExitApp
            }
        }
        Sleep(3000) ; 3秒ごとにリトライ
    }
}
ToolTip("kabu-bot: Failed or Timeout.")
Sleep(3000)
ToolTip()
ExitApp
