$ErrorActionPreference = 'Stop'

$toolsDir = "$(Split-Path -Parent $MyInvocation.MyCommand.Definition)"

$installerFileName = 'InstallGoldWave679.exe'
$filePath = Join-Path -Path $toolsDir -ChildPath $installerFileName
$softwareNamePattern = 'GoldWave v*'

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  fileType       = 'EXE'
  file64         = $filePath
  softwareName   = $softwareNamePattern
  silentArgs     = '-s'
  validExitCodes = @(0)
}
Install-ChocolateyInstallPackage @packageArgs

$appInstallLocation = Get-AppInstallLocation -AppNamePattern $softwareNamePattern
if ($null -ne $appInstallLocation) {
  $installedApplicationPath = Join-Path -Path $appInstallLocation -ChildPath 'GoldWave.exe'
}
else {
  Write-Warning 'Install location not detected'
}

$shimName = 'goldwave'
$pp = Get-PackageParameters
if ($pp.NoShim) {
  Uninstall-BinFile -Name $shimName
}
else {
  if ($null -ne $installedApplicationPath) {
    Install-BinFile -Name $shimName -Path $installedApplicationPath
  }
  else {
    Write-Warning 'Skipping shim creation - install location not detected'
  }
}

#Remove installer binary post-install to prevent disk bloat
Remove-Item -Path $filePath -Force -ErrorAction SilentlyContinue

#If installer binary removal fails for some reason, prevent an installer shim from being generated
if (Test-Path -Path $filePath) {
  Set-Content -Path "$filePath.ignore" -Value $null -ErrorAction SilentlyContinue
}
