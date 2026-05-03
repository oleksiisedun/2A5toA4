# 2A5toA4

A bash script that combines two A5 PDFs side by side onto a single A4 landscape page.

## Setup

Make the script executable before running it for the first time:

```bash
chmod +x ./2A5toA4.sh
```

## Dependency

Requires `pdfjam` from the `texlive-extra-utils` package:

```bash
sudo apt install texlive-extra-utils
```

## Usage

```bash
./2A5toA4.sh
```

The script will interactively prompt you for:

1. **First A5 PDF** — path to the first input file
2. **Second A5 PDF** — path to the second input file (press Enter to reuse the first file)
3. **Output file name** — defaults to `output_A4_landscape.pdf`

File paths can be typed manually or dragged and dropped from a file manager. The script handles `~` expansion, quoted paths, and backslash-escaped spaces.

If the output file already exists, you will be prompted to overwrite it or choose a different name.

## Example

```
Enter path to first A5 PDF:  ~/Documents/page1.pdf
Enter path to second A5 PDF (or press Enter to reuse first): ~/Documents/page2.pdf
Enter output file name [output_A4_landscape.pdf]: combined.pdf
```

Produces `combined.pdf` with both A5 pages placed side by side on one A4 landscape sheet.
