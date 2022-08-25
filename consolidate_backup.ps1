<# 

oldest backup is a, next full backup c

for all b < c 

    for all files f(b)

        if not exists f(a) 

            if creationDate(f(b)) < timestamp(a)

                copy f(b) to a 

#>

$diffPath = "R:\Backup.Home";

$firstConsolidationDate = (Get-Date) - (New-TimeSpan -Days 100);

$nextConsolidationDate = $firstConsolidationDate;

$backupInterval = New-TimeSpan -Days 7;

$currentConsolidatablePaths = New-Object System.Collections.Arraylist;

$currentConsolidationPath;

# iterate diffs older than target date in ascending order

$paths = Get-ChildItem -Path $diffPath -Directory | Sort-Object -Descending

foreach ($_ in $paths) {        

    $currentDate = [datetime]::ParseExact($_.Name, "yyyy-MM-dd HH-mm-ss", $null);

    if ($currentDate -le $firstConsolidationDate) {

        # consolidate if
        if ($currentDate -le $nextConsolidationDate -or $_ -eq $paths[-1]) {

            if ($currentConsolidatablePaths.Count -gt 0) {

                Write-Host "Consolidate on $currentConsolidationPath";

                $currentConsolidatablePaths.Reverse();

                foreach ($path in $currentConsolidatablePaths) {

                    Write-Host "Copy $path";

                    $rcOptions = @("/E","/R:0","/W:0","/MOV","/XO");
                    $rcArgs = @("$path","$currentConsolidationPath",$rcOptions);
                    robocopy @rcArgs | Out-Null;

                    Remove-Item -Force -Recurse -Path "$path";
                }
            }

            $currentConsolidatablePaths = New-Object System.Collections.Arraylist;

            $currentConsolidationPath = $_.FullName;

            $nextConsolidationDate = $currentDate - $backupInterval;

            Write-Host "Consolidate until $nextConsolidationDate";

        }
        else {
            Write-Host "add $_";
            $currentConsolidatablePaths.Add($_.FullName) | Out-Null;
        }
    }
}