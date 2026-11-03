#!/bin/bash
# Script to compile the LaTeX paper to PDF
# Usage:
#   ./compile.sh       - Compile the paper
#   ./compile.sh clean - Clean up unnecessary artifacts after compilation
#   ./compile.sh       - Compile (default behavior)

set -e

# Get the root directory (parent of scripts folder)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$ROOT_DIR"

echo "=== Say It To My Face - LaTeX Compiler ==="
echo "Working directory: $ROOT_DIR"
echo ""

# Determine if clean mode is requested
CLEAN_MODE="false"
for arg in "$@"; do
    if [ "$arg" = "clean" ]; then
        CLEAN_MODE="true"
        break
    fi
done

if [ "$CLEAN_MODE" = "true" ]; then
    echo "=== Cleaning up artifacts ==="
    
    # Remove LaTeX intermediate files
    for pattern in "*.aux" "*.bbl" "*.blg" "*.idx" "*.ilg" "*.ind" "*.log" "*.out" "*.toc" "*.fls" "*.fdb_latexmk" "*.synctex.gz"; do
        find "$ROOT_DIR" -maxdepth 1 -name "$pattern" -type f -delete
    done
    
    echo "Cleaned up LaTeX artifacts"
    echo ""
    
    echo "Remaining files:"
    if ls "$ROOT_DIR"/*.pdf 1> /dev/null 2>&1; then
        for pdf in "$ROOT_DIR"/*.pdf; do
            if [ -f "$pdf" ]; then
                # Use file command to get size in bytes, then convert to KB
                size_bytes=$(wc -c < "$pdf" 2>/dev/null || echo "0")
                if [ -n "$size_bytes" ] && [ "$size_bytes" -gt 0 ] 2>/dev/null; then
                    size_kb=$(awk "BEGIN {printf \"%.2f\", $size_bytes / 1024.0}")
                else
                    size_kb="0.00"
                fi
                echo "  $(basename "$pdf"): $size_kb KB"
            fi
        done
    else
        echo "  (no PDF files found)"
    fi
    
    if ls "$ROOT_DIR"/*.tex 1> /dev/null 2>&1; then
        for tex in "$ROOT_DIR"/*.tex; do
            if [ -f "$tex" ]; then
                echo "  $(basename "$tex")"
            fi
        done
    fi
    
else
    # Normal compilation mode
    echo "=== Compiling paper ==="
    
    # Check if latexmk is available (case-insensitive)
    LATEXMK_PATH=""
    for path in latexmk latexmk.exe LaTeXmk; do
        if command -v "$path" &> /dev/null; then
            LATEXMK_PATH="$path"
            break
        fi
    done
    
    if [ -n "$LATEXMK_PATH" ]; then
        echo "Running latexmk..."
        $LATEXMK_PATH -pdf -interaction=nonstopmode -outdir=. -f main.tex
        echo "Compilation complete!"
    else
        # Fallback to pdflatex (may need multiple runs)
        echo "latexmk not found, trying pdflatex..."
        for i in 1 2 3; do
            for latex in pdflatex pdflatex.exe pdflatex.bat; do
                if command -v "$latex" &> /dev/null; then
                    $latex -interaction=nonstopmode -output-format=pdf -output-directory=. main.tex
                    if [ $? -eq 0 ]; then
                        echo "Compiled (pass $i)"
                        break 2
                    fi
                fi
            done
        done
        
        # Run bibtex if bbl file exists
        if [ -f "main.bbl" ]; then
            for bibtex in bibtex bibtex.exe bibtex.bat; do
                if command -v "$bibtex" &> /dev/null; then
                    echo "Running bibtex..."
                    $bibtex main
                    break
                fi
            done
        fi
        
        # Final pdflatex pass
        for latex in pdflatex pdflatex.exe pdflatex.bat; do
            if command -v "$latex" &> /dev/null; then
                $latex -interaction=nonstopmode -output-format=pdf -output-directory=. main.tex
                break
            fi
        done
    fi
    
    echo ""
    echo "Output: main.pdf"
    if [ -f "main.pdf" ]; then
        # Use file command to get size in bytes, then convert to KB
        size_bytes=$(wc -c < "main.pdf" 2>/dev/null || echo "0")
        if [ -n "$size_bytes" ] && [ "$size_bytes" -gt 0 ] 2>/dev/null; then
            size_kb=$(awk "BEGIN {printf \"%.2f\", $size_bytes / 1024.0}")
        else
            size_kb="0.00"
        fi
        echo "  Size: $size_kb KB"
    fi
fi

echo ""
echo "=== Done ==="
