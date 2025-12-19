# PowerShell GUI Backup Tool

A PowerShell-based GUI backup utility for selective and detailed file backup with progress tracking and logging. Designed for efficiency, flexibility, and full traceability.

---

## Features

- **Source & Destination Selection**  
  Choose the source folder containing your files and the destination folder for backup.

- **Extension-Based Selection**  
  Select specific file extensions grouped into categories: Music, Images, Video. Supports common formats like `.mp3`, `.flac`, `.wav`, `.jpg`, `.png`, `.mp4`, `.mkv`, and more.

- **Copy Mode**  
  Choose whether to **Overwrite** existing files or **Skip** them if they already exist.

- **Progress & Statistics**  
  Real-time display of:
  - Current file being copied
  - Total files copied/skipped
  - Total backup size
  - Copy speed
  - Estimated time remaining (ETA)

- **Logging**  
  Every action, including errors, skipped files, and successful copies, is logged to `backup_log.txt` in the script’s directory.

- **Stop Button** *(planned)*  
  Allows safe interruption of the backup process.

---

## Usage

### Run via PowerShell
Open PowerShell and execute the script directly:

```powershell
.\BackupScript.ps1

Run via Batch File

@echo off
powershell.exe -ExecutionPolicy Bypass -File "C:\path\to\BackupScript.ps1"
pause

Replace "C:\path\to\BackupScript.ps1" with the full path to your script. 
Running the batch file opens the GUI for interaction.

Steps

1.Launch the GUI.

2.Select the Source and Destination folders.

3.Select file types via tabs (Music, Images, Video) and check the extensions you want.

4.Choose Overwrite or Skip existing files.

5.Click Start Backup.

6.Monitor progress, speed, and ETA in real time.

7.Check backup_log.txt for a detailed record.
