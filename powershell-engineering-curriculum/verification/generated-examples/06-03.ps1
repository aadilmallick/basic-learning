# Auto-extracted from a marked offline example. Run in a fresh PowerShell process.
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent)
$source = @'
using System;

namespace Curriculum.Interop {
    public sealed class BuildSnapshot {
        public string Id { get; }
        public string Status { get; }
        public DateTimeOffset? FinishedAt { get; }

        public BuildSnapshot(string id, string status, DateTimeOffset? finishedAt) {
            if (String.IsNullOrWhiteSpace(id))
                throw new ArgumentException("Build ID is required.", nameof(id));
            Id = id;
            Status = (status ?? "").ToUpperInvariant();
            FinishedAt = finishedAt;
        }

        public bool IsRed() {
            return Status == "FAILURE" || Status == "ERROR";
        }
    }
}
'@
Add-Type -TypeDefinition $source -Language CSharp
$build = [Curriculum.Interop.BuildSnapshot]::new(
    '1001', 'failure', [DateTimeOffset]::Parse('2026-11-12T14:00:00Z')
)
$build.IsRed()
$build.Status

