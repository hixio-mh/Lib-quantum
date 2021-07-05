# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$ErrorActionPreference = 'Stop'

& "$PSScriptRoot/set-env.ps1"
$all_ok = $True

function Pack-One() {
    Param($project)

    dotnet pack (Join-Path $PSScriptRoot $project) `
        --no-build `
        -c $Env:BUILD_CONFIGURATION `
        -v $Env:BUILD_VERBOSITY `
        -o $Env:NUGET_OUTDIR `
        /property:PackageVersion=$Env:NUGET_VERSION 

    if  ($LastExitCode -ne 0) {
        Write-Host "##vso[task.logissue type=error;]Failed to pack $project."
        $script:all_ok = $False
    }
}

Write-Host "##[info]Pack Standard library"
Pack-One '../Standard/src/Standard.csproj'

Write-Host "##[info]Pack Chemistry library"
Pack-One '../Chemistry/src/DataModel/DataModel.csproj'

Write-Host "##[info]Pack Numerics library"
Pack-One '../Numerics/src/Numerics.csproj'

Write-Host "##[info]Pack chemistry magics library"
Pack-One '../Chemistry/src/Jupyter/Jupyter.csproj'

if (-not $all_ok) {
    throw "At least one test failed execution. Check the logs."
}
