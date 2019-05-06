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
6. Use the converter included in this directory to convert from .csv to .yaml