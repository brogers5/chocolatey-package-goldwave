$ErrorActionPreference = 'Stop'

$toolsDir = "$(Split-Path -Parent $MyInvocation.MyCommand.Definition)"

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  softwareName   = 'GoldWave v*'
  fileType       = 'EXE'
  validExitCodes = @(0)
}

[array] $keys = Get-UninstallRegistryKey -SoftwareName $packageArgs['softwareName']

if ($keys.Count -eq 1) {
  $keys | ForEach-Object {
    $uninstallStringTokens = [Regex]::Matches($_.UninstallString, '\"(.*?)\"')

    $packageArgs['file'] = $uninstallStringTokens[0].Value
    $packageArgs['silentArgs'] = "$($uninstallStringTokens[1].Value) $($uninstallStringTokens[2].Value)"

    #GoldWave's uninstaller does not support a silent option.
    #Script an unattended uninstall with AutoHotkey.
    $ahkScriptPath = Join-Path -Path $toolsDir -ChildPath 'uninstall.ahk'

    Start-Process -FilePath 'AutoHotKey.exe' -ArgumentList $ahkScriptPath
    Uninstall-ChocolateyPackage @packageArgs
  }
}
elseif ($keys.Count -eq 0) {
  Write-Warning "$packageName has already been uninstalled by other means."
}
elseif ($keys.Count -gt 1) {
  Write-Warning "$($keys.Count) matches found!"
  Write-Warning 'To prevent accidental data loss, no programs will be uninstalled.'
  Write-Warning 'Please alert package maintainer the following keys were matched:'
  $keys | ForEach-Object { Write-Warning "- $($_.DisplayName)" }
}

Uninstall-BinFile -Name 'goldwave'
