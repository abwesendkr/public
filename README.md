# public
build Azure Virtual Desktop Custom Image Builder
# learnings:
1. _NEVER_ touch the files in the storage account **DURING** the build process. this will fail the build processes, even when read only
2. Scripts will **NOT** be downloaded each build. they stored in blob storage shell in numbers, BUT can be edited
3. Building takes **forever** this build takes like 3-4 hours

# issues:
* packager logs seams to have a number of 20509 lines
* vscode pwoershell extension is not installed
* install languages is take up 3>hours
* install python is excluded
* may language set up is causing abort error
