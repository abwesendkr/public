# public
build Azure Virtual Desktop Custom Image Builder
# learnings:
1. _NEVER_ touch the files in the storage account **DURING** the build process. this will fail the build processes, even when read only
2. Scripts will **NOT** be downloaded each build. they stored in blob storage shell in numbers, BUT can be edited
3. 
