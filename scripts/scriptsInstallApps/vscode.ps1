
$version="x64"
$sku="Code"



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

    Write-Output "Installing Visual Studio $sku $version"
    $logFolder = Join-path -path $env:ProgramData -childPath "VScode"

    if ($version -eq 'x64')
    {

        if ($sku -eq 'Code')
        {
            $argumentList = "/silent, /mergetasks=!runcode"
            $downloadUrl = 'https://update.code.visualstudio.com/latest/win32-x64/stable'
        }
    }
    else
    {
        throw "Version is not recognized - allowed values are Code Specified value: $version"
    }


    $localFile = Join-Path $logFolder 'vscodeinstall.exe'
    DownloadToFilePath $downloadUrl $localFile

    # Ensure there are no duplicate entries in the argument list.
    $argumentList = $argumentList | Select -Unique
    
    Write-Output "Running install with the following arguments: $argumentList"
    $retCode = Start-Process -wait -FilePath $localFile -ArgumentList /silent, /mergetasks=!runcode

    if ($retCode.ExitCode)
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