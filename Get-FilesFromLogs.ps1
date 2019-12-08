$filePath = "C:\Users\wvannuffele4\Documents\VO\cwm100285_17 - Copy.txt"

$files = @()

ForEach ($line in [System.IO.File]::ReadLines($filePath)) {
    $pattern = [regex]::new("\/.*\/\S*\.\w*(?!.*\/)")
    
    $matches = $pattern.Matches($line)
    If($matches.value.Length -gt 0){
        $pathName = $matches.value
        $convertedPathName = "G:\" + (($pathName.Substring(3,$pathname.Length-3)) -Replace "\/","\")
        $longPathName = "\\?\" + $convertedPathName
        
        write-host $longPathName
        $files += $longPathName
    }
}