$ErrorActionPreference = 'Stop'

$currentPath = (Split-Path $MyInvocation.MyCommand.Definition)
$nuspecFileRelativePath = Join-Path -Path $currentPath -ChildPath 'goldwave.nuspec'
[xml] $nuspec = Get-Content -Path $nuspecFileRelativePath
$version = [Version] $nuspec.package.metadata.version

$global:Latest = @{
    FileName64 = 'InstallGoldWave677'
    FileType   = 'exe'
    Url64      = 'https://web.archive.org/web/20230807180028if_/https://goldwave.com/download.php?file=gw'
    Version    = $version
}

Write-Output 'Downloading...'
Get-RemoteFiles -Purge -FileNameBase $Latest.FileName64 -NoSuffix

Write-Output 'Creating package...'
choco pack $nuspecFileRelativePath
