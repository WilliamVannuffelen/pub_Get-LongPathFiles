$rootDirectory = "C:\Users\wvannuffele4\Documents\VO\DMOW\backuplogs\original"

$filePaths = Get-ChildItem -Path $rootDirectory

ForEach($filePath in $filePaths){
    
    $files = @()
    $backupDate = $filePath.Name.Split('_')[1]
    $backupDate = $backupDate.Substring(0,$backupDate.Length-4)

    ForEach($line in [System.IO.File]::ReadLines($filePath.FullName)){
        $volumePattern = [Regex]::New('\/G\/1M2B\/')

        If($line -match $volumePattern){
            $pathPattern = [regex]::new("\/.*\/\S*\.\w*(?!.*\/)")
            $userNamePattern = [Regex]::New('root;.*@ALFA')

    
            $matches = $pathPattern.Matches($line)
            If($matches.value.Length -gt 0){
                $userNameMatches = $userNamePattern.Matches($line)
                $userName = $userNameMatches.ToString()

                $pathName = $matches.value
                $convertedPathName = "G:\" + (($pathName.Substring(3,$pathname.Length-3)) -Replace "\/","\")
                $longPathName = "\\?\" + $convertedPathName

                $lineObj = [PSCustomObject]@{
                    'backupDate'    = $backupDate
                    'fullpath'      = $longPathName
                    'userName'      = $userName
                }
                $lineObj
                $files += $lineObj
            }
        }
    }
    $files | Select-Object backupDate,fullPath,userName | Export-Csv -Path "C:\users\wvannuffele4\documents\VO\DMOW\incrementalBackupFiles.csv" -NoTypeInformation -Append
}
