// -------------------------- SETUP ----------------------------------

// This terraform block tells Terraform it will need to look in the google registry when identifying which resources to deploy
terraform {
    required_providers {
        google = {
            source  = "hashicorp/google"
            version = "3.5.0"
        }
    }
}

// This provider block configures your google account.
provider "google" {
    credentials = file("../keys/de-book-prod-secret-key.json") // provide the file path to your GCP secret key file
    project     = "de-book-dev"
    region      = "us-central1"
    zone        = "us-central1-c"
}


// -------------------------- APIs ----------------------------------
// More info at: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project_service

# Enable BigQuery API
resource "google_project_service" "cb_service" {
  service = "bigquery.googleapis.com "
  disable_on_destroy         = false
}

# Enable Cloud Build API
resource "google_project_service" "cb_service" {
  service = "cloudbuild.googleapis.com"
  disable_on_destroy         = false
}

# Enable Cloud Functions API
resource "google_project_service" "cf_service" {
  service = "cloudfunctions.googleapis.com"
  disable_on_destroy         = false
}

# Enable Dataproc API
resource "google_project_service" "dp_service" {
  service = "dataproc.googleapis.com"
  disable_on_destroy         = false
}

# Enable GKE API
resource "google_project_service" "gke_service" {
  service = "container.googleapis.com"
  disable_on_destroy         = false
}

# Enable Pub/Sub API
resource "google_project_service" "cb_service" {
  service = "pubsub.googleapis.com"
  disable_on_destroy         = false
}


// -------------------------- BIGQUERY ----------------------------------
// More info here: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/bigquery_dataset

// This BigQuery Dataset will be used for marketing data
resource "google_bigquery_dataset" "marketing_dataset" {
    dataset_id  = "marketing"
    description = "This dataset holds all marketing data."
    location    = "US"
    project     = "de-book-prod"
    access {
      role          = "roles/bigquery.dataEditor"
      user_by_email = google_service_account.function_stream.email
    }
    access {
      role          = "roles/bigquery.dataEditor"
      user_by_email = google_service_account.composer.email
    }
    access {
      role          = "roles/bigquery.dataEditor"
      user_by_email = google_service_account.dataproc.email
    }
}

// This BigQuery Dataset will be used for competitor data
resource "google_bigquery_dataset" "competitor_dataset" {
    dataset_id = "competitors"
    description = "This dataset holds all competitor data."
    location = "US"
    project = "de-book-prod"
    access {
      role          = "roles/bigquery.dataEditor"
      user_by_email = google_service_account.function_stream.email
    }
    access {
      role          = "roles/bigquery.dataEditor"
      user_by_email = google_service_account.composer.email
    }
    access {
      role          = "roles/bigquery.dataEditor"
      user_by_email = google_service_account.dataproc.email
    }
}

// This BigQuery Dataset will be used for customer data
resource "google_bigquery_dataset" "customers_dataset" {
    dataset_id  = "customers"
    description = "This dataset holds all customer data."
    location    = "US"
    project     = "de-book-prod"
    access {
      role          = "roles/bigquery.dataEditor"
      user_by_email = google_service_account.function_stream.email
    }
    access {
      role          = "roles/bigquery.dataEditor"
      user_by_email = google_service_account.composer.email
    }
    access {
      role          = "roles/bigquery.dataEditor"
      user_by_email = google_service_account.dataproc.email
    }
}

// This BigQuery Dataset will be used for sales data
resource "google_bigquery_dataset" "sales_dataset" {
    dataset_id  = "sales"
    description = "This dataset holds all sales data."
    location    = "US"
    project     = "de-book-prod"
    access {
      role          = "roles/bigquery.dataEditor"
      user_by_email = google_service_account.function_stream.email
    }
    access {
      role          = "roles/bigquery.dataEditor"
      user_by_email = google_service_account.composer.email
    }
    access {
      role          = "roles/bigquery.dataEditor"
      user_by_email = google_service_account.dataproc.email
    }
}

// This BigQuery table will be where we land sales leads data
resource "google_bigquery_table" "sales_leads_landing" {
    dataset_id = google_bigquery_dataset.marketing_dataset.dataset_id
    table_id   = "sales_leads_lnd"

    time_partitioning {
        type = "DAY"
    }

    schema = <<EOF
[
    {
        "name": "name",
        "type": "STRING",
        "mode": "NULLABLE",
        "description": "The full name of the lead."
    },
    {
        "name": "phone_number",
        "type": "STRING",
        "mode": "NULLABLE",
        "description": "Phone number of the sales lead."
    }
]
    EOF

}

// This BigQuery table will be where we land electricity pricing data
resource "google_bigquery_table" "comed_pricing_landing" {
    dataset_id = google_bigquery_dataset.competitor_dataset.dataset_id
    table_id   = "comed_pricing_lnd"

    time_partitioning {
        type = "DAY"
    }

    schema = <<EOF
[
    {
        "name": "millisUTC",
        "type": "STRING",
        "mode": "NULLABLE",
        "description": "The timestamp that the price was recorded at."
    },
    {
        "name": "price",
        "type": "STRING",
        "mode": "NULLABLE",
        "description": "The price of electricity."
    }
]
    EOF

}

// This BigQuery table will be where we land product data
resource "google_bigquery_table" "competitor_products_landing" {
    dataset_id = google_bigquery_dataset.competitor_dataset.dataset_id
    table_id   = "competitor_products_lnd"

    time_partitioning {
        type = "DAY"
    }

    schema = <<EOF
[
    {
        "name": "company",
        "type": "STRING",
        "mode": "NULLABLE",
        "description": "The name of the company that manufacturs the product."
    },
    {
        "name": "product_name",
        "type": "STRING",
        "mode": "NULLABLE",
        "description": "The name of the product."
    },
    {
        "name": "in_stock",
        "type": "BOOLEAN",
        "mode": "NULLABLE",
        "description": "Whether the item is in stock."
    },
    {
        "name": "sku",
        "type": "STRING",
        "mode": "NULLABLE",
        "description": "The Stock Keeping Unit ID."
    },
    {
        "name": "price",
        "type": "FLOAT64",
        "mode": "NULLABLE",
        "description": "The price of the product."
    },
    {
        "name": "product_group",
        "type": "STRING",
        "mode": "REPEATED",
        "description": "Groups of related product IDs."
    }
]
    EOF

}

// This BigQuery table will be where we land customer data
resource "google_bigquery_table" "customers_landing" {
    dataset_id = google_bigquery_dataset.customers_dataset.dataset_id
    table_id   = "customers_lnd"

    time_partitioning {
        type = "DAY"
    }

    schema = <<EOF
[
    {
        "name": "customer_id",
        "type": "STRING",
        "mode": "NULLABLE",
        "description": "The full name of the lead."
    },
    {
        "name": "customer_name",
        "type": "STRING",
        "mode": "NULLABLE",
        "description": "Phone number of the sales lead."
    },
    {
        "name": "address",
        "type": "STRING",
        "mode": "NULLABLE",
        "description": "Phone number of the sales lead."
    },
    {
        "name": "phone_number",
        "type": "STRING",
        "mode": "NULLABLE",
        "description": "Phone number of the sales lead."
    },
    {
        "name": "is_active",
        "type": "BOOLEAN",
        "mode": "NULLABLE",
        "description": "Phone number of the sales lead."
    }
]
    EOF
}

// This BigQuery table will be where we land sales data
resource "google_bigquery_table" "sales_landing" {
    dataset_id = google_bigquery_dataset.sales_dataset.dataset_id
    table_id   = "sales_lnd"

    time_partitioning {
        type = "DAY"
    }

    schema = <<EOF
[
    {
        "name": "sale_id",
        "type": "STRING",
        "mode": "NULLABLE",
        "description": "The full name of the lead."
    },
    {
        "name": "sale_price",
        "type": "FLOAT64",
        "mode": "NULLABLE",
        "description": "Phone number of the sales lead."
    },
    {
        "name": "sale_timestamp",
        "type": "TIMESTAMP",
        "mode": "NULLABLE",
        "description": "Phone number of the sales lead."
    },
    {
        "name": "customer_id",
        "type": "STRING",
        "mode": "NULLABLE",
        "description": "Phone number of the sales lead."
    }
]
    EOF
}

// You will add additional tables later that will be used to expose Hamsterwheel's data to your users


// -------------------------- CLOUD BUILD ----------------------------------
// More info here: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloudbuild_trigger

// This will be used to deploy our code when it is pushed to the master branch in our GitHub Repo
resource "google_cloudbuild_trigger" "prod-deploy-trigger" {
    trigger_template {
        branch_name = "master"
        repo_name   = "hamsterwheel"
    }
    filename = "cloudbuild.yaml"
}


// -------------------------- CLOUD FUNCTIONS ----------------------------------
// More infor here: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloudfunctions_function

// This Cloud Function will kick off loading sales lead data into BigQuery
resource "google_cloudfunctions_function" "sales_leads_function" {
    name        = "load-sales-leads"
    description = "This function triggers a DAG to ingest sales lead data from a GCS bucket."
    runtime     = "python37"
    available_memory_mb   = 128
    source_archive_bucket = google_storage_bucket.prod_bucket.name  // A reference to the GCS bucket you defined below
    # source_archive_object = google_storage_bucket_object.sales_leads_function.name  // A reference to the GCS object you defined below
    source_archive_object = "functions/sales_leads.zip"
    entry_point           = "load_sales_leads"
    service_account_email = google_service_account.function_batch.email  // A reference to the service account you defined below
    event_trigger {
      event_type = "google.storage.object.finalize"
      resource = "gs://de-book-source/marketing/"  // This is the name of the bucket and folder where you expect marketing to drop their file
    }
}

// This Cloud Function will kick off loading competitor products data into BigQuery
resource "google_cloudfunctions_function" "competitor_products_function" {
    name        = "load-competitor-products"
    description = "This function triggers a DAG to ingest competitor products data from a GCS bucket."
    runtime     = "python37"
    available_memory_mb   = 128
    source_archive_bucket = google_storage_bucket.prod_bucket.name  // A reference to the GCS bucket you defined below
    # source_archive_object = google_storage_bucket_object.competitor_products_function.name  // A reference to the GCS object you defined below
    source_archive_object = "functions/competitor_products.zip"
    entry_point           = "load_competitor_products"
    service_account_email = google_service_account.function_batch.email  // A reference to the service account you defined below
    event_trigger {
      event_type = "google.storage.object.finalize"
      resource = "gs://de-book-source/scraper/"  // This is the name of the bucket and folder where you expect marketing to drop their file
    }
}

// This Cloud Function will load sales data into BigQuery and GCS
resource "google_cloudfunctions_function" "load_sales_function" {
    name        = "load-sales-data"
    description = "This function loads streaming sales data from a Pub/Sub topic into BigQuery and GCS."
    runtime     = "python37"
    available_memory_mb   = 128
    source_archive_bucket = google_storage_bucket.prod_bucket.name  // A reference to the GCS bucket you defined below
    # source_archive_object = google_storage_bucket_object.sales_function.name  // A reference to the GCS object you defined below
    source_archive_object = "functions/sales.zip"
    entry_point           = "load_sales_data"
    service_account_email = google_service_account.function_stream.email  // A reference to the service account you defined below
    event_trigger {
      event_type = "google.pubsub.topic.publish"
      resource = google_pubsub_topic.sales_stream.name  // A reference to the Pub/Sub Topic you will define below
    }
}


// -------------------------- COMPOSER ----------------------------------
// More info here: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/composer_environment

// This Composer Environment will orchestrate your batch pipelines
resource "google_composer_environment" "batch_jobs" {
    name   = "batch_jobs"
    region = "us-central1"
    config {
        node_count = 2
        node_config {
            zone         = "us-central1-f"
            machine_type = "n1-standard-1"
            service_account = google_service_account.composer.name
        }
        software_config {
            pypi_packages = {
                requests = "==2.25.1"
            }
            image_version = "composer-1.14.2-airflow-1.10.14"
            python_version = "3"
        }
    }
}


// -------------------------- DATAPROC ----------------------------------

// You will use Dataproc to transform your competitor products file before loading it into BigQuery. However, because you will only
// need to run Dataproc for a few minutes once per day it makes sense (and is much cheaper) to start it up, process the data, then
// take it down. The code defining your dataproc cluster will be in the DAG you write to orchestrate that pipeline.

// If you needed to use Dataproc frequently throughout the day it might make sense to keep a cluster running (so as to avoid the extra
// time it takes to build and tear down a cluster). In that case you would use Terraform to build your Dataproc cluster.


// -------------------------- GCS ----------------------------------
// More info here: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket

// This GCS bucket will serve as your data lake
resource "google_storage_bucket" "prod_bucket" {
    name            = "de-book-prod"   // You should choose your own bucket name. It must be unique across GCS.
    location        = "US"
    force_destroy   = false   // This setting prevents us from deleting a bucket if there are files within
    storage_class   = "STANDARD"
}

// This GCS bucket will hold your cloud functions
resource "google_storage_bucket" "functions_bucket" {
    name            = "de-book-prod-functions"   // You should choose your own bucket name. It must be unique across GCS.
    location        = "US"
    force_destroy   = false   // This setting prevents us from deleting a bucket if there are files within
    storage_class   = "STANDARD"
}

# // This is the reference to the zip file that will contain the code for your sales lead cloud function
# resource "google_storage_bucket_object" "sales_lead_function" {
#   name   = "load-sales-leads"
#   bucket = google_storage_bucket.functions_bucket.name  // A reference to the GCS bucket you defined above
#   source = "functions/zip/load-sales-leads.zip"
# }

# // This is the reference to the zip file that will contain the code for your competitor products cloud function
# resource "google_storage_bucket_object" "competitor_products_function" {
#   name   = "load-competitor-products"
#   bucket = google_storage_bucket.functions_bucket.name  // A reference to the GCS bucket you defined above
#   source = "functions/zip/load-competitor-products.zip"
# }

# // This is the reference to the zip file that will contain the code for your sales data cloud function
# resource "google_storage_bucket_object" "sales_function" {
#   name   = "load-sales-data"
#   bucket = google_storage_bucket.functions_bucket.name  // A reference to the GCS bucket you defined above
#   source = "functions/zip/load-sales-data.zip"
# }


// -------------------------- GKE ----------------------------------
// More infor here: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster

// This will be used to query sales data and publish the results to a Pub/Sub Topic
resource "google_container_cluster" "primary" {
    name     = "sales-gke-cluster"
    location = "us-central1"
    remove_default_node_pool = true
    initial_node_count       = 1
}

resource "google_container_node_pool" "primary_preemptible_nodes" {
    name       = "sales-node-pool"
    location   = "us-central1"
    cluster    = google_container_cluster.primary.name
    node_count = 1

    node_config {
        preemptible  = true
        machine_type = "n1-standard-1"
        service_account = google_service_account.gke.email
        oauth_scopes    = [
        "https://www.googleapis.com/auth/cloud-platform"
        ]
    }
}


// -------------------------- IAM ----------------------------------

data "google_iam_policy" "editor" {
  binding {
    role = "roles/bigquery.dataEditor"
    members = [
      "user:jane@example.com",
    ]
  }
}

// This is used to grant other services permission to insert data into BigQuery
resource "google_bigquery_dataset_iam_policy" "dataset" {
  dataset_id  = "your-dataset-id"
  policy_data = data.google_iam_policy.owner.policy_data
}


// -------------------------- PUB/SUB ----------------------------------
// More info here: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_topic

// This is the Topic where streaming sales data will be stored
resource "google_pubsub_topic" "sales_data" {
  name = "sales-data-topic"
}

// The load-sales-data function defined above will create a subscription for this Topic, so we don't need to create
// a separate subscription here.


// -------------------------- SERVICE ACCOUNTS ----------------------------------
// More info here: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_service_account

// This service account will be used by Cloud Functions for batch processing
resource "google_service_account" "function_batch" {
  account_id    = "cloud_function_batch"
  display_name  = "Cloud Function for Batch Processing"
}

// This service account will be used by Cloud Functions for stream processing
resource "google_service_account" "function_stream" {
  account_id    = "cloud_function_stream"
  display_name  = "Cloud Function for Stream Processing"
}

// This service account will be used by Dataproc
resource "google_service_account" "dataproc" {
  account_id    = "dataproc"
  display_name  = "Dataproc"
}

// This service account will be used by Composer
resource "google_service_account" "composer" {
  account_id    = "composer"
  display_name  = "Composer"
}

// This service account will be used by GKE
resource "google_service_account" "gke" {
  account_id    = "gke"
  display_name  = "GKE"
}