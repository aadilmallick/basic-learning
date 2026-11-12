# Auto-extracted from a marked offline example. Run in a fresh PowerShell process.
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent)
Add-Type -TypeDefinition @'
using System;
using System.Collections.Generic;

namespace Curriculum.Algorithms {
    public static class RedPrefix {
        public static int Count(IEnumerable<string> newestFirstStatuses) {
            if (newestFirstStatuses == null)
                throw new ArgumentNullException(nameof(newestFirstStatuses));
            int count = 0;
            foreach (string raw in newestFirstStatuses) {
                string status = (raw ?? "").ToUpperInvariant();
                if (status != "FAILURE" && status != "ERROR") break;
                count++;
            }
            return count;
        }
    }
}
'@
$statuses = [string[]]@('failure', 'ERROR', 'SUCCESS', 'FAILURE')
[Curriculum.Algorithms.RedPrefix]::Count($statuses)

