# Setup and import

## Prerequisites

Python 3 for the local package configurator; an authorized Microsoft work account; a private SharePoint site with a Documents library; Power Automate access; SharePoint and Excel Online (Business) connections. This demo does not require a paid trial, premium connector or desktop gateway. Verify your own licensing and policies before enabling it.

## Prepare the data

1. Create a private test site. Upload `requests.xlsx`, `decisions.xlsx` from `fixtures/` to the root of Documents. Keep the filenames and named tables unchanged.
2. Use synthetic records only.
3. In Power Automate, create or inspect an Excel “List rows present in a table” action using your site/library/file selectors. Record the source and drive identifiers from its code view. Use your own identifiers; do not copy another tenant’s values.
4. Copy `config.example.json` to `config.local.json`, then replace site, Excel source and drive placeholders. Do not put credentials in this file.
5. Run `python3 scripts/configure_import.py`. Import `configured-import.zip` using **My flows → Import → Import Package (Legacy)**. If the embedded page stalls, the Power Apps package-import page worked in the recorded test.
6. Choose **Create as new**, map both existing connections and import. Imported flows may be Off; turn on the manual flow and check Flow checker.
7. Run with blank optional inputs for the baseline. Confirm the correct account in the connection review.

## Testing and operation

Keep loop concurrency at one and flow-run concurrency at one. Do not run the workflow and macro demos concurrently against shared Excel workbooks. The demo has small fixtures; production-scale Excel pagination is not configured. New intake waits 30 seconds after an Excel write before rereading. Check run history and receipts before repeating any operation.

A source-file read can change Excel version metadata. A green run confirms action execution; reconcile the output values as a separate check. Preserve receipts before rerunning because the same receipt names are overwritten.

## Documentation

- [Microsoft import/export packages](https://learn.microsoft.com/en-us/power-automate/export-import-flow-non-solution)
- [Excel Online (Business) connector](https://learn.microsoft.com/en-us/connectors/excelonlinebusiness/)
- [SharePoint connector](https://learn.microsoft.com/en-us/connectors/sharepointonline/)

The connected tenant’s original package was successfully imported and run. This sanitized template changes only environment/account configuration; it has not been imported into a second tenant.

## Power Query setup

The flow configurator does not configure the Power Query template. Import `power-query/ApprovedMaster-template.pqt` into a supported Power Query host. Edit the RequestSource and DecisionSource source steps to point to your own SharePoint workbook URLs, replacing `__SHAREPOINT_SITE_URL__` or YOUR-TENANT placeholders. Authenticate using your organizational account. Keep the source query names unchanged because ApprovedMaster references them. The separate `.pq` file contains the tested merge logic. Baseline expected output is W001 and M001. The recorded evidence verifies query preview only; a deployed Power BI report and scheduled refresh were not validated.
