# Script to compile the LaTeX paper to PDF
# Usage:
#   .\compile.ps1       - Compile the paper
#   .\compile.ps1 clean - Clean up unnecessary artifacts after compilation
#   .\compile.ps1       - Compile (default behavior)

$ErrorActionPreference = "Stop"

# Get the root directory (parent of scripts folder)
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$rootDir = Split-Path -Parent $scriptDir

Write-Host "=== Say It To My Face - LaTeX Compiler ===" -ForegroundColor Cyan
Write-Host "Working directory: $($rootDir)" -ForegroundColor Gray
Write-Host ""

# Determine if clean mode is requested
if ($args -contains "clean") {
    Write-Host "=== Cleaning up artifacts ===" -ForegroundColor Yellow
    
    # Remove LaTeX intermediate files
    $filesToDelete = @(
        "*.aux", "*.bbl", "*.blg", "*.idx", "*.ilg", "*.ind", "*.log",
        "*.out", "*.toc", "*.fls", "*.fdb_latexmk", "*.synctex.gz"
    )
    
    foreach ($pattern in $filesToDelete) {
        Get-ChildItem -Path $rootDir -Filter $pattern -ErrorAction SilentlyContinue | Remove-Item -Force
    }
    
    Write-Host "Cleaned up LaTeX artifacts" -ForegroundColor Green
    Write-Host ""
    
    Write-Host "Remaining files:" -ForegroundColor Gray
    $pdfs = Get-ChildItem -Path $rootDir -Filter "*.pdf"
    if ($pdfs.Count -gt 0) {
        foreach ($pdf in $pdfs) {
            $sizeKB = [math]::Round($pdf.Length / 1024.0, 2)
            Write-Host "  $($pdf.Name): $sizeKB KB"
        }
    } else {
        Write-Host "  (no PDF files found)"
    }
    
    $texFiles = Get-ChildItem -Path $rootDir -Filter "*.tex"
    if ($texFiles.Count -gt 0) {
        foreach ($tex in $texFiles) {
            Write-Host "  $($tex.Name)"
        }
    }
    
} else {
    # Normal compilation mode
    Write-Host "=== Compiling paper ===" -ForegroundColor Cyan
    
    # Check if latexmk is available
    if (Get-Command latexmk -ErrorAction SilentlyContinue) {
        Write-Host "Running latexmk..." -ForegroundColor Gray
        $env:TMPDIR = $env:TEMP
        $env:TEMP = $env:TMPDIR
        latexmk -pdf -interaction=nonstopmode -outdir=. -f main.tex
        Write-Host "Compilation complete!" -ForegroundColor Green
    } else {
        # Fallback to pdflatex (may need multiple runs)
        Write-Host "latexmk not found, trying pdflatex..." -ForegroundColor Gray
        for ($i = 1; $i -le 3; $i++) {
            pdflatex -interaction=nonstopmode -output-format=pdf -output-directory=. main.tex
            if ($LASTEXITCODE -eq 0) {
                Write-Host "Compiled (pass $i)" -ForegroundColor Green
                break
            }
        }
        
        # Run bibtex if bbl file exists
        if (Test-Path "main.bbl") {
            Write-Host "Running bibtex..." -ForegroundColor Gray
            bibtex main
        }
        
        # Final pdflatex pass
        pdflatex -interaction=nonstopmode -output-format=pdf -output-directory=. main.tex
    }
    
    Write-Host ""
    Write-Host "Output: main.pdf" -ForegroundColor Gray
    $pdf = Get-ChildItem "main.pdf"
    if ($pdf) {
        $sizeKB = [math]::Round($pdf.Length / 1024.0, 2)
        Write-Host "  Size: $sizeKB KB"
    }
}

Write-Host ""
Write-Host "=== Done ===" -ForegroundColor Cyan
