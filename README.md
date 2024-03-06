# windows-scripts

small collection of scripts i use when (re)installing windows

## how to run

after downloading this repo, open powershell as admin and run this command in the directory: `Get-Item *.ps1 | Unblock-File`

> [!NOTE]
> the `Unrestricted` execution policy should not be permanently set, this is why we're using `-Scope Process`

if this doesn't allow you to execute the scripts, use `Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process` and try again
