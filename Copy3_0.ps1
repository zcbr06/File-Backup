Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$Form = New-Object System.Windows.Forms.Form
$Form.Text = "File Backup"
$Form.Size = New-Object System.Drawing.Size(650, 770)
$Form.StartPosition = "CenterScreen"

# Source folder
$LblSource = New-Object System.Windows.Forms.Label
$LblSource.Text = "Source folder:"
$LblSource.Location = New-Object System.Drawing.Point(10, 10)
$LblSource.AutoSize = $true
$Form.Controls.Add($LblSource)

$TxtSource = New-Object System.Windows.Forms.TextBox
$TxtSource.Location = New-Object System.Drawing.Point(10, 30)
$TxtSource.Size = New-Object System.Drawing.Size(450, 20)
$Form.Controls.Add($TxtSource)

$BtnSource = New-Object System.Windows.Forms.Button
$BtnSource.Text = "Browse"
$BtnSource.Location = New-Object System.Drawing.Point(470, 28)
$BtnSource.Add_Click({
    $Dialog = New-Object System.Windows.Forms.FolderBrowserDialog
    if ($Dialog.ShowDialog() -eq "OK") { $TxtSource.Text = $Dialog.SelectedPath }
})
$Form.Controls.Add($BtnSource)

# Destination folder
$LblDest = New-Object System.Windows.Forms.Label
$LblDest.Text = "Destination folder:"
$LblDest.Location = New-Object System.Drawing.Point(10, 60)
$LblDest.AutoSize = $true
$Form.Controls.Add($LblDest)

$TxtDest = New-Object System.Windows.Forms.TextBox
$TxtDest.Location = New-Object System.Drawing.Point(10, 80)
$TxtDest.Size = New-Object System.Drawing.Size(450, 20)
$Form.Controls.Add($TxtDest)

$BtnDest = New-Object System.Windows.Forms.Button
$BtnDest.Text = "Browse"
$BtnDest.Location = New-Object System.Drawing.Point(470, 78)
$BtnDest.Add_Click({
    $Dialog = New-Object System.Windows.Forms.FolderBrowserDialog
    if ($Dialog.ShowDialog() -eq "OK") { $TxtDest.Text = $Dialog.SelectedPath }
})
$Form.Controls.Add($BtnDest)

# Tabs for file groups
$TabControl = New-Object System.Windows.Forms.TabControl
$TabControl.Location = New-Object System.Drawing.Point(10, 110)
$TabControl.Size = New-Object System.Drawing.Size(610, 350)
$Form.Controls.Add($TabControl)

$Groups = @{
    "Music" = "*.mp3","*.flac","*.wav","*.aac","*.ogg","*.wma","*.m4a","*.alac","*.aiff","*.ape"
    "Images" = "*.jpg","*.jpeg","*.png","*.bmp","*.gif","*.tif","*.tiff","*.webp","*.heic","*.raw","*.psd","*.svg"
    "Video" = "*.mp4","*.mkv","*.avi","*.mov","*.wmv","*.flv","*.webm"
}

$CheckedLists = @{}
foreach ($GroupName in $Groups.Keys) {
    $TabPage = New-Object System.Windows.Forms.TabPage
    $TabPage.Text = $GroupName

    $CheckedList = New-Object System.Windows.Forms.CheckedListBox
    $CheckedList.Dock = "Fill"
    $CheckedList.CheckOnClick = $true
    foreach ($Ext in $Groups[$GroupName]) { $CheckedList.Items.Add($Ext) }

    $TabPage.Controls.Add($CheckedList)
    $TabControl.TabPages.Add($TabPage)

    $CheckedLists[$GroupName] = $CheckedList
}

# Overwrite / Skip
$LblMode = New-Object System.Windows.Forms.Label
$LblMode.Text = "Copy mode:"
$LblMode.Location = New-Object System.Drawing.Point(10, 470)
$LblMode.AutoSize = $true
$Form.Controls.Add($LblMode)

$RbOverwrite = New-Object System.Windows.Forms.RadioButton
$RbOverwrite.Text = "Overwrite"
$RbOverwrite.Location = New-Object System.Drawing.Point(100, 468)
$RbOverwrite.Checked = $true
$Form.Controls.Add($RbOverwrite)

$RbSkip = New-Object System.Windows.Forms.RadioButton
$RbSkip.Text = "Skip existing"
$RbSkip.Location = New-Object System.Drawing.Point(200, 468)
$Form.Controls.Add($RbSkip)

# Progress and stats
$ProgressBar = New-Object System.Windows.Forms.ProgressBar
$ProgressBar.Location = New-Object System.Drawing.Point(10, 500)
$ProgressBar.Size = New-Object System.Drawing.Size(610, 20)
$Form.Controls.Add($ProgressBar)

$LblProgress = New-Object System.Windows.Forms.Label
$LblProgress.Text = "Progress: 0/0"
$LblProgress.Location = New-Object System.Drawing.Point(10, 530)
$LblProgress.AutoSize = $true
$Form.Controls.Add($LblProgress)

$LblCurrent = New-Object System.Windows.Forms.Label
$LblCurrent.Text = "Current file: None"
$LblCurrent.Location = New-Object System.Drawing.Point(10, 555)
$LblCurrent.AutoSize = $true
$Form.Controls.Add($LblCurrent)

$LblStats = New-Object System.Windows.Forms.Label
$LblStats.Text = "Copied: 0 | Skipped: 0 | Total size: 0 MB"
$LblStats.Location = New-Object System.Drawing.Point(10, 580)
$LblStats.AutoSize = $true
$Form.Controls.Add($LblStats)

$LblSpeed = New-Object System.Windows.Forms.Label
$LblSpeed.Text = "Speed: 0 MB/s | ETA: 0s"
$LblSpeed.Location = New-Object System.Drawing.Point(10, 605)
$LblSpeed.AutoSize = $true
$Form.Controls.Add($LblSpeed)

# Start button
$BtnStart = New-Object System.Windows.Forms.Button
$BtnStart.Text = "Start Backup"
$BtnStart.Location = New-Object System.Drawing.Point(10, 630)
$BtnStart.Size = New-Object System.Drawing.Size(610, 40)
$Form.Controls.Add($BtnStart)

# Backup logic with speed, ETA, and logging
$BtnStart.Add_Click({
    $Source = $TxtSource.Text
    $Dest = $TxtDest.Text
    $LogFile = Join-Path (Get-Location) "backup_log.txt"
    Add-Content $LogFile "`n`n=== Backup started at $(Get-Date) ==="

    if (-not (Test-Path $Source) -or -not (Test-Path $Dest)) {
        [System.Windows.Forms.MessageBox]::Show("Select valid source and destination folders.")
        Add-Content $LogFile "ERROR: Invalid source or destination folder."
        return
    }

    $Extensions = @()
    foreach ($Group in $CheckedLists.Keys) {
        $CheckedLists[$Group].CheckedItems | ForEach-Object { $Extensions += $_ }
    }
    if ($Extensions.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("Select at least one extension.")
        Add-Content $LogFile "ERROR: No extensions selected."
        return
    }

    $Overwrite = $RbOverwrite.Checked

    $AllFiles = Get-ChildItem -Path $Source -Recurse -Include $Extensions -File -ErrorAction SilentlyContinue
    if ($AllFiles.Count -eq 0) { 
        [System.Windows.Forms.MessageBox]::Show("No files found."); 
        Add-Content $LogFile "INFO: No files found matching selected extensions."
        return 
    }

    $TotalFiles = $AllFiles.Count
    $Copied = 0
    $Skipped = 0
    $TotalSize = ($AllFiles | Measure-Object Length -Sum).Sum / 1MB

    $ProgressBar.Minimum = 0
    $ProgressBar.Maximum = $TotalFiles
    $ProgressBar.Value = 0

    $StartTime = Get-Date
    $TotalCopiedBytes = 0

    foreach ($File in $AllFiles) {
        $FileStart = Get-Date
        try {
            $RelativePath = $File.FullName.Substring($Source.Length).TrimStart("\")
            $TargetPath = Join-Path $Dest $RelativePath
            $TargetDir = Split-Path $TargetPath -Parent

            if (-not (Test-Path $TargetDir)) { New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null }

            if ((Test-Path $TargetPath) -and (-not $Overwrite)) {
                $Skipped++
                Add-Content $LogFile "SKIPPED: $($File.FullName)"
            } else {
                Copy-Item $File.FullName -Destination $TargetPath -Force
                $Copied++
                Add-Content $LogFile "COPIED: $($File.FullName)"
                $TotalCopiedBytes += $File.Length
            }
        } catch {
            Add-Content $LogFile "ERROR copying $($File.FullName): $_"
        }

        $Elapsed = (Get-Date) - $StartTime
        $Speed = if ($Elapsed.TotalSeconds -gt 0) { [math]::Round($TotalCopiedBytes / 1MB / $Elapsed.TotalSeconds,2) } else { 0 }
        $RemainingFiles = $TotalFiles - ($Copied + $Skipped)
        $ETA = if ($Speed -gt 0) { [math]::Round(($RemainingFiles * ($TotalSize / $TotalFiles)) / $Speed,0) } else { 0 }

        $ProgressBar.Value = $Copied + $Skipped
        $LblProgress.Text = "Progress: $($Copied + $Skipped)/$TotalFiles"
        $LblCurrent.Text = "Current file: $($File.Name)"
        $LblStats.Text = "Copied: $Copied | Skipped: $Skipped | Total size: $([math]::Round($TotalSize,2)) MB"
        $LblSpeed.Text = "Speed: $Speed MB/s | ETA: $ETA s"

        [System.Windows.Forms.Application]::DoEvents()
    }

    Add-Content $LogFile "=== Backup finished at $(Get-Date) ==="
    Add-Content $LogFile "Summary: Copied=$Copied, Skipped=$Skipped, Total files=$TotalFiles, Total size=$([math]::Round($TotalSize,2)) MB"

    [System.Windows.Forms.MessageBox]::Show("Backup completed! Log saved to $LogFile")
})

$Form.Topmost = $true
[void]$Form.ShowDialog()
