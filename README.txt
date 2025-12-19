PowerShell GUI Backup Tool

This is a PowerShell-based GUI backup tool designed for selective and detailed file backup with progress tracking and logging. It allows you to copy files from one location to another with advanced options and full traceability.

Features

Source & Destination Selection: Choose the source folder containing files and the destination folder for backup.

Extension-Based Selection: Pick specific file extensions grouped into categories such as Music, Images, and Video. Supports common formats like .mp3, .flac, .wav, .jpg, .png, .mp4, .mkv, etc.

Copy Mode: Choose whether to overwrite existing files or skip them.

Progress & Statistics: Displays current file being copied, total copied/skipped files, total backup size, copy speed, and estimated time remaining.

Logging: Every operation, including errors, skipped files, and successful copies, is logged to backup_log.txt in the script directory.

Stop Button: (Planned) Stop the backup process safely at any time.

How to Use

Run via PowerShell: Open PowerShell and execute the script directly.

Run via Batch File: Create a .bat file to launch the script easily. Example:

@echo off
powershell.exe -ExecutionPolicy Bypass -File "C:\path\to\BackupScript.ps1"
pause


Replace "C:\path\to\BackupScript.ps1" with the full path to your PowerShell backup script. Running the batch file will open the GUI and allow full interaction.

Steps

Launch the GUI.

Select the source and destination folders.

Select file types via the tabs (Music, Images, Video). Check the extensions you want to include.

Choose Overwrite or Skip existing files.

Click Start Backup to begin.

Monitor progress, speed, and ETA in real time.

Check backup_log.txt for detailed records of the backup session.

Notes

Ensure PowerShell Execution Policy allows running scripts (Set-ExecutionPolicy RemoteSigned or Bypass).

All paths and file names must use English characters only (no Cyrillic), as PowerShell may not handle Unicode paths reliably in this script.

The script supports recursive backup of all subfolders.

Large backups may take time; progress and speed indicators help track operation.