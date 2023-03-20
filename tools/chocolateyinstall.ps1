$ErrorActionPreference = 'Stop'

$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$installerFileName = 'InstallGoldWave674.exe'
$filePath = Join-Path -Path $toolsDir -ChildPath $installerFileName

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  fileType       = 'EXE'
  file64         = $filePath
  softwareName   = 'GoldWave v*'
  silentArgs     = '-s'
  validExitCodes = @(0)
}
Install-ChocolateyInstallPackage @packageArgs

#Remove installer binary post-install to prevent disk bloat
Remove-Item -Path $filePath -Force -ErrorAction SilentlyContinue

#If installer binary removal fails for some reason, prevent an installer shim from being generated
if (Test-Path -Path $filePath)
{
  Set-Content -Path "$filePath.ignore" -Value $null -ErrorAction SilentlyContinue
}
