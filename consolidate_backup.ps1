<# 

oldest backup is a, next full backup c

for all b < c 

    for all files f(b)

        if not exists f(a) 

            if creationDate(f(b)) < timestamp(a)

                copy f(b) to a 

#>

$diffPath = "G:\Backup.Profildaten";

$firstConsolidationDate = (Get-Date) - (New-TimeSpan -Days 30);

$nextConsolidationDate = $firstConsolidationDate;

$backupInterval = New-TimeSpan -Days 14;

$currentConsolidatablePaths = New-Object System.Collections.Arraylist;

$currentConsolidationPath;

# iterate diffs older than target date in ascending order

Get-ChildItem -Path $diffPath -Directory | Sort-Object -Descending | % {        

    $currentDate = Get-Date -Date "$($_.Name.substring(0,$_.Name.IndexOf(" ")))";

    if ($currentDate -le $firstConsolidationDate) {

        # consolidate if
        if ($currentDate -le $nextConsolidationDate) {

            Write-Host "consolidate on $_";

            if ($currentConsolidatablePaths.Count -gt 0) {

                $currentConsolidatablePaths.Reverse();

                foreach ($path in $currentConsolidatablePaths) {

                    Write-Host "copy $path";

                    $rcOptions = @("/E","/R:0","/W:0","/MOVE","/XO");
                    $rcArgs = @("$path","$currentConsolidationPath",$rcOptions);
                    robocopy @rcArgs | Out-Null;

                    Remove-Item -Force -Recurse -Path "$path";
                }
            }

            $currentConsolidatablePaths = New-Object System.Collections.Arraylist;

            $currentConsolidationPath = $_.FullName;

            $nextConsolidationDate = $nextConsolidationDate - $backupInterval;
        }
        else {
            Write-Host "add $_";
            $currentConsolidatablePaths.Add($_.FullName) | Out-Null;
        }
    }
}