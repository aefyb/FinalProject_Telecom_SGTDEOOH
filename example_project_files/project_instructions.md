# I320 Data Engineering - Final Project Dataset
## Telecom | Team: Somebody

### The assignment brief
> Focused on what items they have, what lines could be upgraded, and what else can be offered in a bundle.

**Stakeholders you are building for:** Retention and upsell marketing, device/plan product managers, and regional sales leads.

**Data window:** Monthly usage from 2026-05-01 through 2026-10-31.

**"Today" for this project:** treat **2026-10-31** as the current date for any as-of logic.

### Analytical requirements (restate these in your own words in Section 2 of your report)
1. Customer inventory: For each customer, which lines, plans, devices, and extra services do they have, and what do they pay each month?
2. Upgrade candidates: Which lines could be upgraded (older device generation, contract ending or out of contract)? Define and justify your rule.
3. Plan fit: Which lines regularly exceed their plan's data allowance and would be better on a different plan, and how much overage revenue is involved?
4. Bundle opportunities: Which customers qualify for a bundle offer they do not yet have, based on the services they already hold?

### What is in this package
```
telecom_somebody/
  README.md                         <- this file
  data/                             <- 10 CSV files (UTF-8, comma-delimited, header row)
  starter/
    01_create_staging_starter.sql   <- example staging DDL (ONE table)
    02_load_starter.psql            <- example psql \copy load (ONE table)
    03_verify_starter.sql           <- verification / profiling queries
    04_dbt_sources_starter.yml      <- example dbt source declaration
```

| File | What it contains |
|---|---|
| `data/bundle_offers.csv` | Bundle definitions with discount and minimum line count. |
| `data/bundle_requirements.csv` | Which service products make up each bundle. |
| `data/customer_services.csv` | Services customers subscribe to (account-level or line-level). |
| `data/customers.csv` | Account holders with market, segment, credit class, and autopay flag. |
| `data/device_models.csv` | Device makes and models with release year and network generation. |
| `data/line_usage.csv` | Monthly data, voice, text usage and billing per line. |
| `data/lines.csv` | Individual mobile lines with plan, device, activation, and contract end. |
| `data/mobile_plans.csv` | Mobile plans with price, data allowance, and 5G flag. |
| `data/service_markets.csv` | Geographic markets with 5G coverage. |
| `data/service_products.csv` | Add-on and home service products with price and billing scope. |

### Read this before you start
* **All data is synthetic.** Names, e-mails, phone numbers and identifiers are invented. E-mails use the reserved `example.com` domain.
* **Nothing is labelled for you.** The files are not marked as "fact" or "dimension". Deciding what the **grain** is, which file(s) are fact tables, which are dimensions, which are bridges or lookups, and how the files relate is **your job** - and a core part of your grade. Start by reading headers, sampling rows, and testing which columns the files have in common.
* **The files share identifiers.** Columns with the same name/format across files are how the files connect. Verify every join: check cardinality (1:1, 1:many, many:many) before you trust a count.
* **The data is realistic, not pristine.** Expect nulls, inconsistent text values, and repeated rows. Detect them with queries, decide how to handle them, and document your decisions in your report (Sections 3 and 7). Do not silently delete rows - show your evidence.
* Some NULLs are *meaningful* (they describe a real business situation) and some are *defects*. Part of the work is telling them apart.

### Quick start
```bash
# 1. create your GitHub repo, then copy this folder's /data and /starter into it
# 2. from the project root:
psql -h <HOST> -U <YOUR_ROLE> -d dataeng -f starter/01_create_staging_starter.sql
psql -h <HOST> -U <YOUR_ROLE> -d dataeng -f starter/02_load_starter.psql
psql -h <HOST> -U <YOUR_ROLE> -d dataeng -f starter/03_verify_starter.sql
```
Then extend the snippets to cover **all** files, build your own dbt models (staging -> star schema -> data products), and visualize in Superset.

### Repository hygiene (from the project guide)
* Do **not** commit passwords, tokens, or `profiles.yml`. Add them to `.gitignore`.
* Commit the data only if your instructor allows it; otherwise document how to place it locally.

### Report checklist reminder
Introduction + restated requirements -> source documentation (conceptual & physical ER) -> staging DDL & `\copy` script with verification -> grain/facts/dimensions + lineage diagram -> star schema evidence -> your own dbt models -> data products -> Superset dashboard + interpretation -> reflection -> repo link.
