# **I320 Data Engineering - Final Project**
### Industry: Telecommunications
### Team - Somebody Get These Data Engineers Out Of Here!
### Members - Andrea Conde, Chloe Low, Jessica Nguyen

<br>

## Project Goal

The goal of this project was to transform raw telecommunications customer data into structured, reliable, and business-ready data using pgSQL and dbt. The project organizes the data into staging models and analytical data products that help identify customer behavior, service usage patterns, subscription preferences, and potential business opportunities. With the data products, we used Apache Superset to develop an interactive dashboard with visualizations that help to answer the project's business questions.

<br>

## Business questions 
<ol>
    <li>Which service, plan, bundle, and device are the most subscribed amongst consumers? Least subscribed?</li>
    <li>What market are the most consumers based in? Least number of consumers?</li>
    <li>How many people have autopay enabled? Disabled? How many people have a running debt amount?</li>
    <li>How many lines exceed their plan's data allowance? What is the average overage charge and data used of lines exceeding their plan? How much would subscribers save on a more cost efficient plan?</li>
    <li>How many lines can be upgraded? What are the best market and consumer types for sales opportunities?</li>
</ol>
<br>

### Five data products were developed to address these key business questions:

<ol>
    <li> <b>Subscription Ranking</b> (<code>1_subscription_ranking.sql</code>) - Identify the most popular subscription plans based on subscriber counts </li>
    <li> <b>Consumer Market</b> (<code>2_consumer_market.sql</code>) - Analyze customer distribution across different markets and customer segments
    <li> <b>Device Upgrades</b> (<code>3_device_upgrades.sql</code>) - Identify customers and opportunities associated with device upgrades
    <li> <b>Line Usage Analysis</b> (<code>4_line_usage_analysis.sql</code>) - Examine service usage, plan fit, and potential overage charges
    <li> <b>Autopay Billing</b> (<code>5_autopay_billing.sql</code>) - Analyze payment behavior and compare billing patterns between autopay and non-autopay customers
</ol>

<br>

## Workflow

<ol style="list-style-type: decimal;">
    <li>Data preparation
        <ol style="list-style-type: lower-alpha;">
            <li>Initialized dbt schema and loaded raw datasets into seeds folder</li>
            <li>Organized source tables within project schema</li>
            <li>Reviewed available tables, columns, data types, and relationships to understand underlying data</li>
        </ol>
    </li>
    <li>Data transformation via dbt
        <ol style="list-style-type: lower-alpha;">
            <li>Configured dbt project to pgSQL database</li>
            <li>Created staging models to clean, standardize, and prepare the raw data for analysis</li>
            <li>Used <code>dbt ref()</code> to establish dependencies between staging and dimensional models</li>
            <li>Developed 5 analytical data products
                <ol style="list-style-type: lower-roman;">
                    <li><code>subscription_ranking</code></li>
                    <li><code>consumer_market</code></li>
                    <li><code>device_upgrades</code></li>
                    <li><code>line_usage_analysis</code></li>
                    <li><code>autopay_billing</code></li>
                </ol>
            </li>
        </ol>
    </li>
    <li>Data validation
        <ol style="list-style-type: lower-alpha;">
            <li>Executed dbt models to verify successful transformations</li>
            <li>Reviewed model outputs in pgAdmin</li>
            <li>Checked calculations, relationships, and aggregation results for accuracy</li>
            <li>Verified that data products produced expected results prior to visualizations</li>
        </ol>
    </li>
    <li>Dashboard development using Superset
        <ol style="list-style-type: lower-alpha;">
            <li>Connected dbt data products to Superset</li>
            <li>Created visualizations to address business questions</li>
            <li>Selected meaningful chart types, dimensions, measures, labels, and formatting</li>
            <li>Organized visuals into a dashboard</li>
            <li>Added dashboard filters to support interactive exploration of data</li>
        </ol>
    </li>
    <li>Business analysis and documentation
        <ol style="list-style-type: lower-alpha;">
            <li>Interpreted results presented in each visualization</li>
            <li>Identified meaningful customer behavior patterns and potential business opportunities</li>
            <li>Documented the purpose, data sources, aggregation methods, and findings per chart</li>
            <li>Documented finalized dashboard into an analysis report</li>
        </ol>
    </li>
</ol>

<br>

## Setting up locally

**Python is required**

- install the project folders located in <code>models</code>, as well as the <code>seeds</code> folder for the raw source data

Installing dbt

```bash
pip install dbt-postgres
```

<br>
Create or update dbt profile

```bash
%USERPROFILE%\.dbt\profiles.yml
```
<br>

Example configuration of profiles.yml
```yaml
# profile_name must match profile in dbt_project.yml
profile_name:
  target: dev
  outputs:
    dev:
      type: database_type
      host: localhost
      user: username
      password: password
      port: 1234
      dbname: database_name
      schema: public
      threads: 4
```
<br>

Verify connection to pgSQL

```bin
dbt debug
```
<br>
When successful, run <code>dbt init schema-name</code>, then put files into their corresponding paths and run:

```bash
dbt seed
dbt run
```

## External Links

[*Know Your Data* Assignment - Figma ERD Draft](https://www.figma.com/board/fCl0scJWVtE5VOfJX2eMJ9/Telecom-ERDs?node-id=0-1&t=SNTAWJeRVgrVZNqt-1)

[*Project Report* - Telecommunications](https://docs.google.com/document/d/1tVe3Tj4LO8kme5tHl17GW4t9xeNEaciZV3h4uYV3AYI/edit?usp=sharing)