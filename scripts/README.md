# LaTeX Build Scripts

This directory contains build scripts for compiling and managing the LaTeX paper.

## Usage

### Bash (Linux/macOS/WSL)
```bash
./compile.sh          # Compile the paper
./compile.sh clean    # Clean up artifacts after compilation
```

### PowerShell (Windows)
```powershell
.\compile.ps1          # Compile the paper
.\compile.ps1 clean    # Clean up artifacts after compilation
```

## What the scripts do

### Compilation
- Uses `latexmk` for automatic multiple compilation passes and bibliography handling
- Falls back to `pdflatex` + `bibtex` if `latexmk` is not available
- Outputs `main.pdf` in the project root

### Clean Mode
Removes all intermediate LaTeX files while keeping:
- `main.tex` - Your source file
- `main.pdf` - The compiled PDF
- `paper.pdf` - Any previously generated paper PDF

Removes:
- `.aux`, `.bbl`, `.blg`, `.idx`, `.ilg`, `.ind`, `.log`, `.out`, `.toc`, `.fls`, `.fdb_latexmk`, `.synctex.gz`

## Dependencies

- `pdflatex` (from TeX Live or MiKTeX)
- `latexmk` (recommended, but optional)
- `bibtex` (for bibliography processing)
