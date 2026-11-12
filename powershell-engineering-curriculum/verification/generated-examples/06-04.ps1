# Auto-extracted from a marked offline example. Run in a fresh PowerShell process.
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent)
Add-Type -TypeDefinition @'
namespace Curriculum.Contracts {
    public interface IStatusClassifier {
        string Classify(string status);
    }

    public sealed class StatusClassifier : IStatusClassifier {
        public string Classify(string status) {
            switch ((status ?? "").ToUpperInvariant()) {
                case "SUCCESS": return "GREEN";
                case "FAILURE":
                case "ERROR": return "RED";
                default: return "OTHER";
            }
        }
    }
}
'@
$classifier = [Curriculum.Contracts.StatusClassifier]::new()
$classifier -is [Curriculum.Contracts.IStatusClassifier]
$classifier.Classify('UNKNOWN')

