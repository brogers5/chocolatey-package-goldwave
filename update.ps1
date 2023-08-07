Import-Module au

$currentPath = (Split-Path $MyInvocation.MyCommand.Definition)
$toolsPath = Join-Path -Path $currentPath -ChildPath 'tools'

function New-Snapshot {
    $seleniumModuleName = 'Selenium'
    if (!(Get-Module -ListAvailable -Name $seleniumModuleName)) {
        Install-Module -Name $seleniumModuleName
    }
    Import-Module $seleniumModuleName

    if (!(Test-Path -Path "$env:PROGRAMFILES\Mozilla Firefox\firefox.exe")) {
        choco install firefox -y
    }

    $downloadUrl = "https://web.archive.org/save/$($Latest.Url64)"
    Write-Output "Starting Selenium at $downloadUrl"
    $seleniumDriver = Start-SeFirefox $downloadUrl -Headless
    $Latest.ArchivedBinaryUrl = $seleniumDriver.Url
    $Latest.DirectArchivedBinaryUrl = $Latest.ArchivedBinaryUrl -replace '(\d{14})/', "`$1if_/"
    $seleniumDriver.Dispose()
}

function global:au_BeforeUpdate ($Package) {
    Get-RemoteFiles -Purge -FileNameBase $Latest.FileName64 -NoSuffix -Algorithm sha256

    New-Snapshot

    Copy-Item -Path "$toolsPath\VERIFICATION.txt.template" -Destination "$toolsPath\VERIFICATION.txt" -Force

    Set-DescriptionFromReadme -Package $Package -ReadmePath '.\DESCRIPTION.md'
}

function global:au_SearchReplace {
    @{
        'build.ps1'                     = @{
            '(^\s*FileName64\s*=\s*)(''.*'')' = "`$1'$($Latest.FileName64.TrimEnd('.exe'))'"
            '(^\s*Url64\s*=\s*)(''.*'')'      = "`$1'$($Latest.DirectArchivedBinaryUrl)'"
        }
        "$($Latest.PackageName).nuspec" = @{
            "(<packageSourceUrl>)[^<]*(</packageSourceUrl>)" = "`$1https://github.com/brogers5/chocolatey-package-$($Latest.PackageName)/tree/v$($Latest.Version)`$2"
            "(<copyright>)[^<]*(</copyright>)"               = "`$1Copyright © $(Get-Date -Format yyyy) GoldWave® Inc.`$2"
        }
        'tools\VERIFICATION.txt'        = @{
            '%binaryUrl%'         = "$($Latest.Url64)"
            '%archivedBinaryUrl%' = "$($Latest.ArchivedBinaryUrl)"
            '%binaryFileName%'    = "$($Latest.FileName64)"
            '%checksumValue%'     = "$($Latest.Checksum64)"
            '%checksumType%'      = "$($Latest.ChecksumType64.ToUpper())"
        }
        'tools\chocolateyinstall.ps1'   = @{
            "(^[$]installerFileName\s*=\s*)('.*')" = "`$1'$($Latest.FileName64)'"
        }
    }
}

function global:au_GetLatest {
    $uri = 'https://goldwave.com/version.php?ver=0.00+U'
    $userAgent = 'Update checker of Chocolatey Community Package ''goldwave'''
    $updatePage = Invoke-WebRequest -Uri $uri -UserAgent $userAgent -UseBasicParsing

    $version = [Regex]::Matches($updatePage.Content, "(\d+(\.\d+){1,3})").Groups[1].Value
    $downloadUri = 'https://goldwave.com/download.php?file=gw'

    return @{
        FileName64 = "InstallGoldWave$($version.Replace('.', ''))"
        FileType   = 'exe'
        Url64      = $downloadUri
        Version    = "$version.0" #This may change if building a package fix version
    }
}

Update-Package -ChecksumFor None -NoReadme
