#!/opt/microsoft/powershell/7/pwsh
param($arch)

$ErrorActionPreference = 'Stop'

$backupPath = '/usr/bin/objcopy.bak'
$replaced = Test-Path $backupPath
$target = ""

if ($false -eq $replaced) {
    Copy-Item "/usr/bin/objcopy" -Destination $backupPath
}
if ($arch -eq "x64") {
    $target = $backupPath
} 
if ($arch -eq "arm64") {
    $target = "/usr/bin/aarch64-linux-gnu-objcopy"
}
if ($arch -eq "loongarch64") {
    $target = "/opt/loongarch64-toolchain/bin/loongarch64-unknown-linux-gnu-objcopy"
}

sudo ln -sf "$target" /usr/bin/objcopy