function Get-ObservedRedCount {
    [CmdletBinding()]
    param([object[]]$Builds = @())
    $count = 0
    foreach ($build in $Builds) {
        if ($build.Status -notin @('FAILURE', 'ERROR')) { break }
        $count++
    }
    $count
}
