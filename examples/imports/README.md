# Converting from Chalker's Excel-based Scoring System

Many high-level Science Olympiad competitions have traditionally used Chalker's
Excel-based Scoring System to output their results in PDF format. To convert
from this format into SciolyFF, the following workflow was used (Given the
sketchiness of the whole thing, your exact experience may differ):

1. Make sure the PDF file only consists of one page of results (see the PDFs in
   this directory as examples)
   - If not, use the free program PDFSam to separate the pages
2. Open the PDF in Word (should auto-convert)
3. Save the Word document as a "Web Page" (.html)
4. Open the .html file in Excel
5. Clean up extra information and save as a CSV (see the CSV files in this
   directory as examples)
   - Delete the first four header rows
   - Unmerge the first two columns after row 10, then use "Text to Columns" with
     fixed width to separate team numbers from team name
   - Re-add the event names (use the PDF as reference) as the top row, label
     trial events like "Sounds of Music (Trial)" and trialed events like "Sounds
     of Music (Trialed)"
6. Do more cleanup from Linux command line
   - Run `unix2dos` on all CSV files
   - Replace `?` with `-` using in some CSV files using `sed`
7. Use the converter included in this directory to convert from .csv to .yaml
   ```
   ./csv2sciolyff [the CSV file] > [name for output file .yaml]
   ```
8. Manually add to the .yaml file
   - Add Tournament section (and the necessary info)
   - Add Penalties sections only if there were teams that received penalties
9. Do a validation of the file with `sciolyff`
   - Ties in event placing will trigger
     (`SciolyFF::Placings#test_placings_are_unique_for_event_and_place`) but
     this can be ignored most of the timebecause Nationals scoring rules allow
     for ties for places greater than 6. (See commit 3b9596e19)
