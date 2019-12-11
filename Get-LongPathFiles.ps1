function Get-LongPathFile($file){
    $result = $type[0]::GetFileAttributesEx($file.fullPath, $infoLevelsEnum, [ref]$fileAttribData)

    If(!$result){
        $fileObject = [PSCustomObject]@{
            'backupDate'        = $file.backupDate
            'fullPath'          = $file.fullPath
            'presentInTarget'   = "No"
            'fileSizeNum'       = 0
            'fileSizeStr'       = "0"
            'creationTime'      = 0
            'lastWriteTime'     = 0
            'userName'          = "/"
        }
    }
    ElseIf($result){

        $fileSize = ($fileAttribData.nFileSizeLow + (([Math]::Pow(2,32)) * $fileAttribData.nFileSizeHigh))
        $roundedFileSize = switch ($fileSize){
            {$_ -gt 0 -and $_ -lt 1024} {1; Break}
            default {[Math]::Round($fileSize / 1KB)}
        }

        $fileObject = [PSCustomObject]@{
            'backupDate'        = $file.backupDate
            'fullPath'          = $file.fullPath
            'presentInTarget'   = "Yes"
            'fileSizeNum'       = $roundedFileSize
            'fileSizeStr'       = $roundedFileSize.ToString('N0')
            'creationTime'      = ([DateTime]::FromFileTime($fileAttribData.ftCreationTime.dwLowDateTime + ([Math]::Pow(2,32) * $fileAttribData.ftCreationTime.dwHighDateTime))).ToString()
            'lastWriteTime'     = ([DateTime]::FromFileTime($fileAttribData.ftLastWriteTime.dwLowDateTime + ([Math]::Pow(2,32) * $fileAttribData.ftLastWriteTime.dwHighDateTime))).ToString()
            'userName'          = $file.userName
        }
    }
    return $fileObject
}

$signature = @'
[DllImport("kernel32.dll", SetLastError=true, CharSet=CharSet.Unicode)]


public static extern bool GetFileAttributesEx(string lpFileName,
  GET_FILEEX_INFO_LEVELS fInfoLevelId, out WIN32_FILE_ATTRIBUTE_DATA fileData);

public enum GET_FILEEX_INFO_LEVELS {
        GetFileExInfoStandard,
        GetFileExMaxInfoLevel
    }

[StructLayout(LayoutKind.Sequential)]
public struct WIN32_FILE_ATTRIBUTE_DATA
    {
        public System.IO.FileAttributes dwFileAttributes;
        public System.Runtime.InteropServices.ComTypes.FILETIME ftCreationTime;
        public System.Runtime.InteropServices.ComTypes.FILETIME ftLastAccessTime;
        public System.Runtime.InteropServices.ComTypes.FILETIME ftLastWriteTime;
        public uint nFileSizeHigh;
        public uint nFileSizeLow;
    }


'@
$type = Add-Type -MemberDefinition $signature -Name ‘Kernel32’ -Namespace ‘Win32’ -PassThru
$infoLevelsEnum = New-Object Win32.Kernel32+GET_FILEEX_INFO_LEVELS
$fileAttribData = New-Object Win32.Kernel32+WIN32_FILE_ATTRIBUTE_DATA

$testFiles = Import-Csv "C:\dir\dir\incrementalBackupFilesFormatted.csv"

$fileObjects = @()

ForEach($testFile in $testFiles){
    $fileObject = Get-LongPathFile $testFile
    $fileObjects += $fileObject
}

$fileObjects | Select-Object backupDate, fullPath, presentInTarget, fileSizeNum, fileSizeStr, creationTime, lastWriteTime, userName | Export-Csv "C:\temp\volume_incremental_check.csv" -NoTypeInformation -Encoding UTF8