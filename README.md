![Google](https://github.com/scbs/scbs_google-bigquery/raw/master/images/google.png)

# Google BigQuery+

- [Google BigQuery+](#google-bigquery)
- [Overview](#overview)
- [Getting Started](#getting-started)
	- [Prerequisites](#prerequisites)
		- [What is Docker?](#what-is-docker)
		- [Get Docker](#get-docker)
		- [Google Cloud Account](#google-cloud-account)
			- [Step 1: Setup Google Account](#step-1-setup-google-account)
			- [Step 2: Create Your Google Cloud Project](#step-2-create-your-google-cloud-project)
			- [Step 3: Activate Google Cloud APIs](#step-3-activate-google-cloud-apis)
			- [Step 4: Google Cloud Authentication](#step-4-google-cloud-authentication)
- [Installing](#installing)
- [Configuration](#configuration)
	- [Setting Up A Docker Authentication Volume](#setting-up-a-docker-authentication-volume)
		- [Example: Using A Docker Authentication Volume](#example-using-a-docker-authentication-volume)
	- [Setting Up A Local Authentication File](#setting-up-a-local-authentication-file)
		- [Example: Using An Auth File](#example-using-an-auth-file)
- [BigQuery Exports](#bigquery-exports)
	- [How To Export Data From BigQuery?](#how-to-export-data-from-bigquery)
		- [Part 1: The SQL Export Query Definition](#part-1-the-sql-export-query-definition)
			- [Example: SQL Query](#example-sql-query)
		- [Testing Your SQL](#testing-your-sql)
		- [Part 2: The Export Job Definition](#part-2-the-export-job-definition)
			- [Example: Config File](#example-config-file)
			- [Example: Google Analytics Exports](#example-google-analytics-exports)
		- [Looking At `ga_bounces` Config and Query](#looking-at-gabounces-config-and-query)
	- [Delivering Exports To Google Cloud Storage](#delivering-exports-to-google-cloud-storage)
	- [Transferring Exports To Amazon S3](#transferring-exports-to-amazon-s3)
		- [Example: Running Batch Export](#example-running-batch-export)
		- [Example Using `bigquery-job`](#example-using-bigquery-job)
- [CRON](#cron)
	- [Run Google Cloud SDK As Daemon](#run-google-cloud-sdk-as-daemon)
		- [Example: Docker Compose](#example-docker-compose)
- [Google BigQuery SQL Recipes](#google-bigquery-sql-recipes)
	- [Other Usage Example Commands](#other-usage-example-commands)
- [TODO](#todo)
- [Build Details](#build-details)
- [Issues](#issues)
- [Contributing](#contributing)
- [License](#license)



# Overview
<b>UPDATE: If you wanted an automated solutions for moving Google Analtyics 360 to Amazon Redshift, Amazon Redshift Spectrum or Amazon Athena, learn more here: https://www.scbs.com/product/scbs-google-analytics-360</b>

This service is meant to simplify running Google Cloud operations, especially BigQuery tasks. This means you do not have to worry about installation, configuration or ongoing maintenance related to an SDK environment. This can be helpful to those who would prefer to not to be responsible for those activities.

* BigQuery Data Export
* BigQuery Data Import (WIP)
* Setup Export and Import Job via config files
* Batch exports
* Flexible SQL Definition and Runtime
* Service Account Authorization (via auth file or volumes)
* Run As SDK as Daemon (via Cron)
* Google Service Configuration (Create BigQuery datasets, temp tables, archives, Google storage locations....)
* Data retention lifecycle policy (Google Storage)
* Data transfer to Amazon S3
* SQL Recipes (DoubleClick, AdWords, GA...)
* Package in a Docker image

This service was originally created to perform "cloud-to-cloud" operations, specifically BigQuery exports and syncing files to Amazon S3. However, you can run any commands supported by the SDK via the container.

# Versioning
| Docker Tag | Git Hub Release | SDK | Alpine Version |
|-----|-------|-----|--------|
| latest | Master | latest | latest |

# Getting Started

For the container to work, it requires a Google Cloud account and Docker!

## What is Docker?

This container is used for virtualizing your Google development or work environment using Docker. If you don't know what Docker is read "[What is Docker?](https://www.docker.com/what-docker)".

### Get Docker

Once you have a sense of what Docker is, you can then install the software. It is free: "[Get Docker](https://www.docker.com/products/docker)". Select the Docker package that aligns with your environment (ie. OS X, Linux or Windows). If you have not used Docker before, take a look at the guides:

- [Engine: Get Started](https://docs.docker.com/engine/getstarted/)
- [Docker Mac](https://docs.docker.com/docker-for-mac/)
- [Docker Windows](https://docs.docker.com/docker-for-windows/)

If you already have a Linux instance running as a host or VM, you can install Docker command line. For example, on CentOS you would run `yum install docker -y` and then start the Docker service.


## Google Cloud Account

### Step 1: Setup Google Account

This container assumes you already have a Google Cloud account setup. Do not have a Google Cloud account? Set one up [here](https://cloud.google.com/).

### Step 2: Create Your Google Cloud Project

Now that you have a Google Cloud account the next step is setting up a project. If you are not sure how, check out the [documentation](https://developers.google.com/console/help/new/#creatingdeletingprojects). If you already have a project setup, take note of the ID.

### Step 3: Activate Google Cloud APIs

With your project setup you will need to activate APIs on that project. The API's are how the Google Cloud SDK perform operations on your behalf.

For details on how to do this, the Google [documentation](https://developers.google.com/console/help/new/#activating-and-deactivating-apis) describes the process for activating APIs.

### Step 4: Google Cloud Authentication

The preferred methods of authentication is using a _Google Cloud OAuth Service Account_ docker volume or auth file. Without an account volume or auth file you will not get far. No account = no access.

The Google Service Account Authentication [documentation](https://cloud.google.com/storage/docs/authentication?hl=en#service_accounts) details how to generate the file.


# Installing

```
docker build -t scbs/scbs_google-bigquery .
```
or via Docker Hun simply pull the image locally
```
docker pull scbs/scbs_google-bigquery
```

# Configuration

## Setting Up A Docker Authentication Volume

Follow these instructions if you are running docker _outside_ of Google Compute Engine:

```bash
docker run -t -i --name gcloud-config scbs/scbs_google-bigquery gcloud init
```

If you would like to use service account the run command would look like this:

```bash
docker run -t -i --name gcloud-config scbs/scbs_google-bigquery gcloud auth activate-service-account <your-service-account-email> --key-file /tmp/your-key.p12 --project <your-project-id>
```

Notice the email, key and project variables are needed to run it this way.

### Example: Using A Docker Authentication Volume

Re-use the credentials from gcloud-config volumes & run sdk commands:

```bash
docker run --rm -ti --volumes-from gcloud-config scbs/scbs_google-bigquery gcloud info
docker run --rm -ti --volumes-from gcloud-config scbs/scbs_google-bigquery gsutil ls
```

If you are using this image from _within_ [Google Compute Engine](https://cloud.google.com/compute/). If you enable a Service Account with the necessary scopes, there is no need to auth or use a config volume, Just run your commands:

```bash
docker run --rm -ti scbs/scbs_google-bigquery gcloud info
docker run --rm -ti scbs/scbs_google-bigquery gsutil ls
```

## Setting Up A Local Authentication File

If you do not want to use a Docker Authentication Volume, you can also use a local auth file. There is a sample auth file here: `samples/auth-sample.json`. The file contains all the needed authorization details to connect to Google.

### Example: Using An Auth File

Once the auth file has been completed, place it into the `./auth` directory within the project. The next step is to reference the path to your authentication file in the `.env` file. This is done by setting the path for the variable `GOOGLE_CLOUDSDK_ACCOUNT_FILE=`.

For example, if you name your auth file `creds.json` you would set the config to `GOOGLE_CLOUDSDK_ACCOUNT_FILE=/creds.json`. This sets the path to the creds file in the root of the container.

To use your authentication file, you need to mount it within the container in the same location specified in your `.env` file via `-v` variable:

```bash
docker run -it -v ./scbs_google-bigquery/auth/prod.json:/creds.json --env-file ./env/prod.env scbs/scbs_google-bigquery gcloud info
```

# BigQuery Exports

In addition to running Google Cloud SDK operations, the container is designed to perform BigQuery query operations. The built-in BigQuery operations can export the results of a query to Google Cloud storage and, if needed, to Amazon S3\. This provides you a consistent, clean way to export data out of BigQuery into compressed (gzip) comma separated ASCII files.

## How To Export Data From BigQuery?

There are two parts to the export process. The first is the `.sql` query file and the second is the `.env` job file.

### Part 1: The SQL Export Query Definition

The export process leverages one or more `.sql` files stored in the `./sql/*` directory. These files provide the query definition for an export. A `sql` definition is relatively straightforward. If you have any experience with SQL, you likely have come across these files before. The `sql` file contains a query written in SQL (Structured Query Language). It contains SQL code used to query the contents of a relational database.

In our use case, most queries will run a query to generate a result set for export. Here is an example that will query Google Analytics 360 data. The container will dynamically set the `FROM` parts of the query based on the job configuration file (more on this later). You are certainly free to hard code those attributes. However, if you wanted to automatically run this everyday then hard coding might not be the best approach.

#### Example: SQL Query

```sql
SELECT
trafficSource.source + ' / ' + trafficSource.medium AS source_medium,
count(DISTINCT CONCAT(fullVisitorId, STRING(visitId)), 100000) as sessions,
SUM(totals.bounces) as bounces,
100 * SUM(totals.bounces) / count(DISTINCT CONCAT(fullVisitorId, STRING(visitId)), 100000) as bounce_rate,
SUM(totals.transactions) as transactions,
100 * SUM(totals.transactions) / count(DISTINCT CONCAT(fullVisitorId, STRING(visitId)), 100000) as conversion_rate,
SUM(totals.transactionRevenue) / 1000000 as transaction_revenue,
SUM(hits.transaction.transactionRevenue) / 1000000 as rev2,
AVG(hits.transaction.transactionRevenue) / 1000000 as avg_rev2,
(SUM(hits.transaction.transactionRevenue) / 1000000 ) / SUM(totals.transactions) as avg_rev
FROM TABLE_DATE_RANGE([{{GOOGLE_CLOUDSDK_CORE_PROJECT}}:{{GOOGLE_BIGQUERY_JOB_DATASET}}.{{GOOGLE_BIGQUERY_TABLE}}],TIMESTAMP('{{QDATE}}'),TIMESTAMP('{{QDATE}}'))
GROUP BY source_medium
ORDER BY sessions DESC
```

You can setup as many queries as you want. The one caveat is that there can only be one `.sql` file per job (.env file).

### Testing Your SQL

There are no validation operations, checks or tests of the SQL you provide. It is assumed that the SQL was validated and tested prior to being used.

You can use the container to run tests of your query. For example, to enable standard SQL for a query, set the `--use_legacy_sql` flag to false. Then, reference the `sql` file you as part of a query command.

### Part 2: The Export Job Definition

A job is defined by a collection of Google and AWS environment variables set in a configuration file. A job is intrinsically linked to a `.sql` file as it reflects the query a job should execute.

#### Example: Config File

The job config file contains all the variables needed to run the container for the query operation. The sample file is located here: `./samples/bigquery.env`. Here is the sample environment file:

```bash
GOOGLE_CLOUDSDK_ACCOUNT_FILE=/auth.json
GOOGLE_CLOUDSDK_ACCOUNT_EMAIL=foo@appspot.gserviceaccount.com
GOOGLE_CLOUDSDK_CRONFILE=/crontab.conf
GOOGLE_CLOUDSDK_CORE_PROJECT=foo-buzz-779217
GOOGLE_CLOUDSDK_COMPUTE_ZONE=us-east1-b
GOOGLE_CLOUDSDK_COMPUTE_REGION=us-east1
GOOGLE_BIGQUERY_SQL=ga360master
GOOGLE_BIGQUERY_TABLE=ga_sessions_
GOOGLE_BIGQUERY_JOB_DATASET=1999957242
GOOGLE_STORAGE_BUCKET=scbs-buzz # do not include leading or trailing slashes /
GOOGLE_STORAGE_PATH=folder/location/here # do not include leading or trailing slashes /
AWS_ACCESS_KEY_ID=QWWQWQWLYC2NDIMQA
AWS_SECRET_ACCESS_KEY=WQWWQqaad2+tyX0PWQQWQQQsdBsdur8Tu
AWS_S3_BUCKET=bucketname/path/to/dir # do not include leading or trailing slashes /
LOG_FILE=/tmp/gcloud.log
```

The config file should reflect the variables associated with a query as well as the post processing operations for export. Here are a few of the key variables;

- All BigQuery resources belong to a Google Cloud Platform project. Each project is a separate compartment. The use of `GOOGLE_CLOUDSDK_CORE_PROJECT` is mean to provide the flexibility to assign a different project for a given job (vs binding it to just a single project). This assumes you have access to those projects as well.
- Datasets enable you to organize and control access to your tables. A table must belong to a dataset, so you will need to create at least one dataset before loading/exporting data. The `GOOGLE_BIGQUERY_JOB_DATASET` should reflect the value of the dataset that cotains the table your `.sql` will query. For example, if you have `ga_master.sql` file then you should set this to `GOOGLE_BIGQUERY_SQL=ga_master` (leave the .sql off)
- The `GOOGLE_BIGQUERY_SQL` variable should match the name of your `.sql`. For example, if you have `ga_master.sql` file then you should set this to `GOOGLE_BIGQUERY_SQL=ga_master` (leave the .sql off)

Those environment variables marked as required need to be included on all requests.

While you can bypass use the configuration file, most of the documentation will assume you are choosing this approach.

#### Example: Google Analytics Exports

Lets says you have want to create exports for `bounces`, `clicks`, `visits` and `geography` from BigQuery. You would create a job config for each:

- `/env/ga_bounces.env`
- `/env/ga_clicks.env`
- `/env/ga_visits.env`
- `/env/ga_geo.env`

You would then make sure that you had the corresponding SQL queries defined:

- `/sql/ga_bounces.sql`
- `/sql/ga_clicks.sql`
- `/sql/ga_visits.sql`
- `/sql/ga_geo.sql`

The `sql` files would contain the correct SQL syntax that aligns with the desired output.

### Looking At `ga_bounces` Config and Query

Lets dig into the `ga_bounces` example above. The `ga_bounces` job config would look like this:

```bash
GOOGLE_CLOUDSDK_ACCOUNT_FILE=/auth.json
GOOGLE_CLOUDSDK_ACCOUNT_EMAIL=foo@appspot.gserviceaccount.com
GOOGLE_CLOUDSDK_CRONFILE=/crontab.conf
GOOGLE_CLOUDSDK_CORE_PROJECT=foo-buzz-779217
GOOGLE_CLOUDSDK_COMPUTE_ZONE=us-east1-b
GOOGLE_CLOUDSDK_COMPUTE_REGION=us-east1
GOOGLE_BIGQUERY_SQL=ga_bounces
GOOGLE_BIGQUERY_JOB_DATASET=1999957242
GOOGLE_STORAGE_BUCKET=scbs-buzz
GOOGLE_BIGQUERY_TABLE=ga_sessions_
GOOGLE_STORAGE_PATH=foo/place
AWS_ACCESS_KEY_ID=QWWQWQWLYC2NDIMQA
AWS_SECRET_ACCESS_KEY=WQWWQqaad2+tyX0PWQQWQQQsdBsdur8Tu
AWS_S3_BUCKET=bucketname/path/to/dir
LOG_FILE=/tmp/gcloud.log
```

Note the reference to `ga_bounces` in the `GOOGLE_BIGQUERY_SQL` variable. This tells the processing application to grab the `/sql/ga_bounces.sql` file to use as the query for the export.

Here is the `/sql/ga_bounces.sql` SQL definitiion:

```sql
SELECT
trafficSource.source + ' / ' + trafficSource.medium AS source_medium,
count(DISTINCT CONCAT(fullVisitorId, STRING(visitId)), 100000) as sessions,
SUM(totals.bounces) as bounces,
100 * SUM(totals.bounces) / count(DISTINCT CONCAT(fullVisitorId, STRING(visitId)), 100000) as bounce_rate,
SUM(totals.transactions) as transactions,
100 * SUM(totals.transactions) / count(DISTINCT CONCAT(fullVisitorId, STRING(visitId)), 100000) as conversion_rate,
SUM(totals.transactionRevenue) / 1000000 as transaction_revenue,
SUM(hits.transaction.transactionRevenue) / 1000000 as rev2,
AVG(hits.transaction.transactionRevenue) / 1000000 as avg_rev2,
(SUM(hits.transaction.transactionRevenue) / 1000000 ) / SUM(totals.transactions) as avg_rev
FROM TABLE_DATE_RANGE([{{GOOGLE_CLOUDSDK_CORE_PROJECT}}:{{GOOGLE_BIGQUERY_JOB_DATASET}}.{{GOOGLE_BIGQUERY_TABLE}}],TIMESTAMP('{{QDATE}}'),TIMESTAMP('{{QDATE}}'))
GROUP BY source_medium
ORDER BY sessions DESC
```

_Note_: The `GOOGLE_BIGQUERY_SQL` variable is used in other places to set export path and filenames. For example, it is used in the export filenames as well as in temp and working tables.

## Delivering Exports To Google Cloud Storage

The process will create a storage location if it does not exists. It uses the value set for `GOOGLE_STORAGE_BUCKET` to define that location. Also, `GOOGLE_STORAGE_PATH` is set to `prodoction` or `test` based on your runtime settings. It will also use the `GOOGLE_BIGQUERY_SQL` name as part of the path and resulting filename. Lastly, `FILEDATE` is a CONCAT of the date and a random hash.

```bash
gs://${GOOGLE_STORAGE_BUCKET}/${GOOGLE_STORAGE_PATH}/${GOOGLE_BIGQUERY_SQL}/${FILEDATE}_${GOOGLE_BIGQUERY_SQL}_export*.gz
```

For our `ga_bounces` example, the resulting exports would be transfer to location and context like this:

```bash
gs://scbs-buzz/production/ga_bounces/20170101_asd12XZ_ga_bounces_export_000.gz
```

How long are files persisted in that bucket? There is a current lifecycle policy set keep the export for `30` days. The `/lifecycle.json` defines the bucket policy for the retention of files stored there. If you want to persist them for a longer time period edit the policy accordingly. Simply change the `30` to whatever number of days you feel is needed.

## Transferring Exports To Amazon S3

You will notice the use of AWS credentials in addition to Google ones. The AWS creds are present to support "cloud-to-cloud" transactions. For example, `/cron/crontab.conf` shows automated file transfers from Google Cloud drive to Amazon S3.

Here is the construct for specifying the S3 location:

`AWS_S3_BUCKET=<bucket name><path>`

Here is an example:

`AWS_S3_BUCKET=mybucket/the/path/to/my/directory/ga_bounces`

The process will `sync` the files between Google and AWS. This means if you delete or update a file on the Google side it will mirror that operation on AWS.

Note: If you are running in `TEST` mode no files are transfered to S3

### Example: Running Batch Export

Included is a simple shell script `/bigquery-job.sh` to run the container on a `HOST` machine. You may need to tweak this to fit your environment/setup.

```bash
/usr/bin/env bash -c 'bigquery-job <mode> <start date> <end date>'
```

You can set `mode` to "prod" or "test".

For start date and end date, this reflects the date range the SQL query should be performing. If you hard coded those values in your `.sql` file, then these values will do nothing. The default values, if none are supplied as parameters, will be to query for "yesterday". Dates should be in Year-month-day format (i.e., 2017-01-01)

### Example Using `bigquery-job`

This command will run is production mode, setting the query start and end dates to January 1, 2017

```bash
/usr/bin/env bash -c 'bigquery-job prod 2017-01-01 2017-01-01'
```

This will run a query for January 1st, 2017\. If you are running it on January 2nd, then you will be pulling for the full date. However, if you run this at 5PM on the 1st, you will only pull partial data. Be mindful of what is resident in those upstream tables and that your query is aligned to the presence of the desired data.

When `bigquery-job` is run, it is designed run all the jobs present in the `./env` directory.

If you wanted to set this up as a recurring operation, you can create cron task:

```bash
05 12 * * * /usr/bin/env bash -c 'bigquery-job prod 2017-01-01 2017-01-01'
```

However, you don't have to use this job wrapper. You can call the process directly via Docker:

```bash
docker run -it -v /Users/bob/Documents/github/scbs_google-bigquery/auth/prod.json:/auth.json -v /Users/bob/Documents/github/scbs_google-bigquery/sql:/sql --env-file /env/file.env scbs/scbs_google-bigquery bigquery-run prod 2017-01-01 2017-01-01
```

# CRON

We have already shown examples on how to run commands via the container and HOST. However, there may be cases where you want the container to be running 24/7 because you have configured `cron` tasks to execute at set intervals. The next section describes how to run your container as a daemon.

## Run Google Cloud SDK As Daemon

This container can run gcloud operations using cron. The use of CROND is the default configuration in `docker-compose.yml`. It has the following set: `command: cron`. This informs the container to run the `crond` service in the background. With `crond` running anything set in `crontab` will get executed. A working example crontab can be found here: `/cron/crontab.conf`

Please note that when using cron to trigger operations environment variables may need to to be configured inside the crontab config file. This is handled by `docker-entrypoint.sh`

Also, if you want to include your own crontab files, then you may need to adjust the `docker-entrypoint.sh` to reflect the proper configs into `/cron/crontab.conf`

```bash
SHELL=/bin/bash
PATH=/google-cloud-sdk/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
GOOGLE_CLOUDSDK_CORE_PROJECT={{GOOGLE_CLOUDSDK_CORE_PROJECT}}
GOOGLE_CLOUDSDK_COMPUTE_ZONE={{GOOGLE_CLOUDSDK_COMPUTE_ZONE}}
GOOGLE_CLOUDSDK_COMPUTE_REGION={{GOOGLE_CLOUDSDK_COMPUTE_REGION}}
AWS_ACCESS_KEY_ID={{AWS_ACCESS_KEY_ID}}
AWS_SECRET_ACCESS_KEY={{AWS_SECRET_ACCESS_KEY}}
AWS_S3_BUCKET={{AWS_S3_BUCKET}}
GOOGLE_STORAGE_BUCKET={{GOOGLE_STORAGE_BUCKET}}
05 13,14,15,16,17,18 * * * /usr/bin/env bash -c 'bigquery-run prod' >> /tmp/query.log 2>&1
45 12 * * * echo "RUN" > /tmp/runjob.txt
```

### Example: Docker Compose

The simplest way to run the container is:

```bash
docker-compose up -d
```

This assumes you have configured everything in `./env/gcloud-sample.env` and have made any customizations you needed to `docker-compose.yml`

You can get fairly sophisticated with your compose configs. The included `docker-compose.yml` is a starting point. Take a look at the Docker Compose [documentation](https://docs.docker.com/compose/compose-file/) for a more indepth look at what is possible.

# Google BigQuery SQL Recipes

Check out the  `sql/*` directory. There are queries for the following services;

AdWords SQL Recipes
* aw_campaign.sql
* aw_count_keywords.sql

DoubleClick Campaign SQL Recipes
* dc_campaign_activity.sql
* dc_campaigns.sql
* dc_impressions_clicks_activity_users_campaign.sql
* dc_impressions_users_campaign.sql
* dc_latest_campaigns.sql

DoubleClick Publishers SQL Recipes
* dp_impressions_ad_unit.sql
* dp_impressions_line_item.sql
* dp_impressions_unique_user_type.sql
* dp_impressions_users_city.sql

Google Analtyics 360 SQL Recipes
* ga360master.sql
* ga_average_bounce_rate_per_date.sql
* ga_ecom_product_rank_category.sql
* ga_master.sql
* ga_pageviews_exits_rate.sql
* ga_source_session_bounce_rate.sql

## Other Usage Example Commands

This example includes AWS credentials:

```bash
docker run -it --rm \
    -e "GOOGLE_CLOUDSDK_ACCOUNT_FILE=/auth.json " \
    -e "GOOGLE_CLOUDSDK_ACCOUNT_EMAIL=foo@appspot.gserviceaccount.com" \
    -e "GOOGLE_CLOUDSDK_CRONFILE=/cron/crontab.conf" \
    -e "GOOGLE_CLOUDSDK_CORE_PROJECT=foo-buzz-139217" \
    -e "GOOGLE_CLOUDSDK_COMPUTE_ZONE=europe-west1-b" \
    -e "GOOGLE_CLOUDSDK_COMPUTE_REGION=europe-west1" \
    -e "GOOGLE_BIGQUERY_SQL=ga360master" \
    -e "GOOGLE_BIGQUERY_JOB_DATASET=123456789" \
    -e "GOOGLE_BIGQUERY_TABLE=ga_sessions_" \
    -e "GOOGLE_STORAGE_PATH=foo/place" \
    -e "GOOGLE_STORAGE_BUCKET=scbs-foo" \
    -e "AWS_ACCESS_KEY_ID=12ASASKSALSJLAS" \
    -e "AWS_SECRET_ACCESS_KEY=ASASAKEWPOIEWOPIEPOWEIPWE" \
    -e "AWS_S3_BUCKET=foo/ebs/buzz/foo/google/google_analytics/ga-table" \
    -e "LOG_FILE=/ebs/logs/gcloud.log" \
    scbs/scbs_google-bigquery \
    gsutil rsync -d -r gs://{{GOOGLE_STORAGE_BUCKET}}/ s3://{{AWS_S3_BUCKET}}/
```

Here is another example of running an operation to list the Google Cloud instances running in a project:

```bash
docker run -it --rm \
    -e "GOOGLE_CLOUDSDK_ACCOUNT_FILE=/auth.json" \
    -e "GOOGLE_CLOUDSDK_ACCOUNT_EMAIL=GOOGLE_CLOUDSDK_ACCOUNT_EMAIL=foo@appspot.gserviceaccount.com" \
    -e "GOOGLE_CLOUDSDK_CORE_PROJECT=foo-buzz-139217" \
    scbs/scbs_google-bigquery \
    gcloud compute instances list
```

To see a list of available `gcloud` commands:

```bash
docker run -it --rm --env-file ./env/prod.env -v /Users/bob/github/scbs_google-bigquery/auth/prod.json:/auth.json scbs/scbs_google-bigquery gcloud -h
```

```bash
docker run -it --rm --env-file ./env/prod.env -v /Users/bob/github/scbs_google-bigquery/auth/prod.json:/auth.json -v /Users/bob/github/scbs_google-bigquery/cron/crontab.conf:/crontab.conf gcloud bq ls -n 1000 dougie-buzz-133217:227999242
```

Run by setting the name, start and end dates:

```bash
/usr/bin/env bash -c 'bigquery-export <sql> <project> <dataset> <start date> <end date>'
```

```bash
/usr/bin/env bash -c 'bigquery-export ga360 foo-buzz-539217 827858240 2016-10-21 2016-10-21'
```

Remove BQ dataset:

```bash
bq rm -r -f "${GOOGLE_BIGQUERY_WD_DATASET}"
```

Remove gzip files from Cloud Storage

```bash
docker run --rm -ti --volumes-from gcloud-config scbs/scbs_google-bigquery gsutil rm gs://"${GOOGLE_STORAGE_BUCKET}"/"${GOOGLE_STORAGE_PATH}"/"${GOOGLE_BIGQUERY_SQL}"/"${FILEDATE}"_"${GOOGLE_BIGQUERY_SQL}"_*.gz
```

Remove all files from Cloud Storage

```bash
docker run --rm -ti --volumes-from gcloud-config scbs/scbs_google-bigquery gsutil -m rm -f -r gs://"${GOOGLE_STORAGE_BUCKET}"/**
```

Remove remove tables that match a pattern from BQ

```bash
docker run --rm -ti --volumes-from gcloud-config scbs/scbs_google-bigquery bash
```

The at the command prompt:

```bash
for i in $(bq ls -n 9999 ${GOOGLE_CLOUDSDK_CORE_PROJECT} | grep "<pattern>" | awk '{print $1}'); do bq rm -ft ${GOOGLE_CLOUDSDK_CORE_PROJECT}."${i}"; done
```

Generate list of tables from BQ. Check if any tables exist that match a pattern. If yes, 0=yes a match and 1=no match

```bash
docker run --rm -ti --volumes-from gcloud-config scbs/scbs_google-bigquery bash
```

Then at the command prompt:

```bash
BQTABLECHECK=$(bq ls -n 1000 "${GOOGLE_CLOUDSDK_CORE_PROJECT}":"${GOOGLE_BIGQUERY_WD_DATASET}" > ${GOOGLE_CLOUDSDK_CORE_PROJECT}"_"${GOOGLE_BIGQUERY_WD_DATASET}.txt && grep -q "${FILEDATE}_${GOOGLE_BIGQUERY_SQL}" ${GOOGLE_CLOUDSDK_CORE_PROJECT}"_"${GOOGLE_BIGQUERY_WD_DATASET}.txt && echo "0" || echo "1")
```

Generate list of tables from BQ. Check if any tables exist that match a date pattern pattern. If yes, 0=yes a match and 1=no match

```bash
docker run --rm -ti --volumes-from gcloud-config scbs/scbs_google-bigquery bash
```

Then at the command prompt:

```bash
GASESSIONSCHECK=$(bq ls -n 1000 "${GOOGLE_CLOUDSDK_CORE_PROJECT}":"${GOOGLE_BIGQUERY_JOB_DATASET}" > check_test.txt && grep -q "ga_sessions_${FDATE}" check_test.txt && echo "0" || echo "1")
`
```
# TODO
* Finish data import script (bigquery-import).

# Issues

If you have any problems with or questions about this image, please contact us through a GitHub issue.

# Contributing

You are invited to contribute new features, fixes, or updates, large or small; we are always thrilled to receive pull requests, and do our best to process them as fast as we can.

Before you start to code, we recommend discussing your plans through a GitHub issue, especially for more ambitious contributions. This gives other contributors a chance to point you in the right direction, give you feedback on your design, and help you find out if someone else is working on the same thing.

# License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details
