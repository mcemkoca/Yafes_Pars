# Reports And Graphs

## Purpose

Provide SSMS-friendly report and chart datasets.

## Main Script

Use:

```text
database/ssms/09__graph_report_pack.sql
```

## Result Sets

- Policy portfolio by domain
- Claims by status
- Task due aging
- Renewal calendar next 90 days
- Coverage package matrix
- Export catalog

## How To Use Graph Data

SSMS Query Editor returns grids, not modern dashboard charts. The report pack
therefore includes:

- `chart_axis`
- `chart_value`
- `text_bar`
- export-ready labels

Copy a grid to Excel or Power BI when visual charts are needed.

## Info Tips

- Use text bars for quick SSMS-only reading.
- Use the export catalog to choose the right result set.
- Keep reports read-only; do not mix reporting and editing in one tab.
