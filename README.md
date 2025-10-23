Getting started

This script synchronizes the contents of the Windows user’s personal folders with a connected USB drive.
It performs a one-way synchronization operation, not a backup. Any file deleted from your Windows folders will also be deleted from the USB drive during synchronization.
Use with caution!
_____________________________________________________________________________________________________________________________________________________________________
Operation overview

On the first execution, the script saves the current username and hostname to the USB drive.
On subsequent runs, it verifies that the current user and host match the stored values.
if the verification fails, the script will display an error message and halt execution. Protecting current user data from deletion.

Before synchronization, the script checks the available storage space on the USB drive.
The process will only proceed if sufficient free space is available to accommodate new or updated data otherwise the script will display an error message and halt execution.

The script synchronizes the contents of the user’s Documents, Pictures, Videos, and Music folders to corresponding created folders on the USB drive.
Additions, modifications, and deletions are replicated to maintain an exact copy of the local windows folders.

_____________________________________________________________________________________________________________________________________________________________________
Usage Instructions

Place the batch script in the root directory of the USB drive and execute it.
_____________________________________________________________________________________________________________________________________________________________________
Important Notes

•	This script is designed for data mirroring, not for backups.

•	Deleted files on the local system will also be deleted from the USB drive upon synchronization.





