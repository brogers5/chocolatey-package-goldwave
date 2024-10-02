$ErrorActionPreference = 'Stop'

$currentPath = (Split-Path $MyInvocation.MyCommand.Definition)
$nuspecFileRelativePath = Join-Path -Path $currentPath -ChildPath 'goldwave.nuspec'

$global:Latest = @{
    FileName64 = 'InstallGoldWave683'
    FileType   = 'exe'
    Url64      = 'https://web.archive.org/web/20241002143011if_/https://goldwave.com/download.php?file=gw'
}

Write-Output 'Downloading...'
Get-RemoteFiles -Purge -FileNameBase $Latest.FileName64 -NoSuffix

Write-Output 'Creating package...'
choco pack $nuspecFileRelativePath
