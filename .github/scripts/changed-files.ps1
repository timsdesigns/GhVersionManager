param([Parameter(Mandatory)][string]$Before, [Parameter(Mandatory)][string]$After, [switch]$MergeBase)
$ErrorActionPreference = 'Stop'
function Invoke-CheckedGit([string[]]$GitArguments) {
    $start = [Diagnostics.ProcessStartInfo]::new('git')
    $start.UseShellExecute = $false
    $start.WorkingDirectory = (Get-Location).ProviderPath
    $start.RedirectStandardOutput = $true
    $start.RedirectStandardError = $true
    foreach ($argument in $GitArguments) { $start.ArgumentList.Add($argument) }
    $process = [Diagnostics.Process]::Start($start)
    try {
        $errorTask = $process.StandardError.ReadToEndAsync()
        $output = $process.StandardOutput.ReadToEnd()
        $process.WaitForExit()
        $null = $errorTask.GetAwaiter().GetResult()
        if ($process.ExitCode -ne 0) { throw 'Unable to determine changed files; refusing to skip validation.' }
        return $output
    } finally { $process.Dispose() }
}
$tip = (Invoke-CheckedGit @('rev-parse', '--verify', '--end-of-options', "$After^{commit}")).Trim()
if ($Before -match '^0{40,64}$') {
    $output = Invoke-CheckedGit @('ls-tree', '-r', '--name-only', '-z', $tip)
} else {
    $base = (Invoke-CheckedGit @('rev-parse', '--verify', '--end-of-options', "$Before^{commit}")).Trim()
    if ($MergeBase) { $base = (Invoke-CheckedGit @('merge-base', $base, $tip)).Trim() }
    $output = Invoke-CheckedGit @('diff', '--name-only', '-z', '--diff-filter=ACMR', $base, $tip, '--')
}
$output.Split([char]0, [StringSplitOptions]::RemoveEmptyEntries) | Where-Object { $_ -match '^GrasshopperFiles/.*\.ghx?$' }
