<#
.Synopsis
   Moves Files
.DESCRIPTION
    Moves Files based on supplied target directory, source directory and file name
.NOTES
    Thanks to Matthew Linker for creating this script.
.PARAMETER file
    File name including extension getting moved
.PARAMETER source_dir
    location of file
.PARAMETER target_dir
    location to move file to
.EXAMPLE
    .\MoveFiles.ps1 -file "Financials Auto Division.xlsx" -source_dir "\\private\network\storage" -target_dir "\\public\network\storage"
.FUNCTIONALITY
    General Purpose
#>

[cmdletbinding(ConfirmImpact = 'Medium', SupportsPaging = $true, SupportsShouldProcess = $true)]

param ([string] $file, [string] $source_dir, [string] $target_dir)

# using a lot of additional coding because pushing a directory is like working in a stack
# $env:temp was defined as a unique location on my system, choose one that is not being used by other processes on yours

if ([bool]([System.Uri]$source_dir).IsUnc) 
{
pushd $source_dir
cp $file $env:temp -Force -Recurse
popd
}
else
{
$t1 = $source_dir + '\' + $file
cp $t1 $env:temp -Force -Recurse
}


$tempfile = $env:temp + '\' + $file

if ([bool]([System.Uri]$target_dir).IsUnc) 
{
pushd $target_dir
cp $tempfile $target_dir -Force -Recurse
popd
}
else
{
cp $tempfile $target_dir -Force -Recurse
}
popd

#clean staging directory
Remove-Item $tempfile -Force -Recurse

popd

