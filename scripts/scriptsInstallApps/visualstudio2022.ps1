
$version="2022"
$sku="Community"



# PowerShell configurations
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

# Ensure we force use of TLS 1.2 for all downloads.
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Discard any collected errors from a previous execution.
$Error.Clear()



# Handle all errors in this script.
trap
{  
    #script, unless you want to ignore a specific error.
    $message = $Error[0].Exception.Message
    if ($message)
    {
        Write-Host -Object "`nERROR: $message" -ForegroundColor Red
    }

    Write-Host "`nThe artifact failed to apply.`n"

    # IMPORTANT NOTE: Throwing a terminating error (using $ErrorActionPreference = "Stop") still
    # returns exit code zero from the PowerShell script when using -File. The workaround is to
    # NOT use -File when calling this script and leverage the try-catch-finally block and return
    # a non-zero exit code from the catch block.
    exit -1
}


# Functions used in this script.
function DownloadToFilePath ($downloadUrl, $targetFile)
{
    Write-Output ("Downloading installation files from URL: $downloadUrl to $targetFile")
    $targetFolder = Split-Path $targetFile

    if ((Test-Path -path $targetFile))
    {
        Write-Output "Deleting old target file $targetFile"
        Remove-Item $targetFile -Force | Out-Null
    }

    if (-not (Test-Path -path $targetFolder))
    {
        Write-Output "Creating folder $targetFolder"
        New-Item -ItemType Directory -Force -Path $targetFolder | Out-Null
    }

        # Download the file, with retries.
    $downloadAttempts = 0
    do
    {
        $downloadAttempts++

        try
        {
            $WebClient = New-Object System.Net.WebClient
            $WebClient.DownloadFile($downloadUrl,$targetFile)
            break
        }
        catch
        {
            Write-Output "Caught exception during download..."
            if ($_.Exception.InnerException)
            {
                Write-Output "InnerException: $($_.InnerException.Message)"
            }
            else
            {
                Write-Output "Exception: $($_.Exception.Message)"
            }
        }

    } while ($downloadAttempts -lt 5)
    if ($downloadAttempts -eq 5)
    {
        Write-Error "Download of $downloadUrl failed repeatedly. Giving up."
    }
}

# Main execution block.
try
{
    Push-Location $PSScriptRoot

    Write-Output "Installing Visual Studio $version $sku"
    $logFolder = Join-path -path $env:ProgramData -childPath "VS2022"

    if ($version -eq '2022')
    {
        $commonArgsList = @(
            "--includeRecommended",
            "--quiet",
            "--norestart",
            "--wait"
        )

        # CommunityModules
        $CommunityModulesArgsList = @(
            "--add Microsoft.VisualStudio.Workload.Data",
            "--add Microsoft.VisualStudio.Workload.ManagedDesktop",
            "--add Microsoft.VisualStudio.Workload.NativeDesktop",
            "--add Microsoft.VisualStudio.Workload.NetWeb",
            "--add Microsoft.VisualStudio.Workload.Azure"
        )

        if ($sku -eq 'Community')
        {
            $argumentList = $commonArgsList + $CommunityModulesArgsList
            $downloadUrl = 'https://aka.ms/vs/17/release/vs_community.exe'
        }
    }
    else
    {
        throw "Version is not recognized - allowed values are 2022. Specified value: $version"
    }


    $localFile = Join-Path $logFolder 'vsinstaller.exe'
    DownloadToFilePath $downloadUrl $localFile

    # Ensure there are no duplicate entries in the argument list.
    $argumentList = $argumentList | Select -Unique
    
    Write-Output "Running install with the following arguments: $argumentList"
    $retCode = Start-Process -FilePath $localFile -ArgumentList $argumentList -Wait -PassThru

    if ($retCode.ExitCode -ne 0 -and $retCode.ExitCode -ne 3010)
    {
        throw "Product installation of $localFile failed with exit code: $($retCode.ExitCode.ToString())"    
    }

    Write-Output "Visual Studio install succeeded. Rebooting..."
    Write-Host "`nThe artifact was applied successfully.`n"

}
finally
{
    Pop-Location
}