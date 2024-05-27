terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.27.0"
    }
  }
}

# configuring GCP provider, creds, project
provider "google" {
    credentials = "armageddeon-0d508d6cdae2.json"
    project = "armageddeon"
    region = "us-west1"
}

#create a bucket
resource "google_storage_bucket" "bucket" {
  name = "armageddeon-fallout-bucket"
  project = "armageddeon"
  location = "us-west1"
  force_destroy = true
  uniform_bucket_level_access = false
  storage_class = "STANDARD"
}

# Make bucket fine grained access & make items publically accessible
resource "google_storage_bucket_iam_member" "member" {
  provider = google
  bucket   = google_storage_bucket.bucket.name
  role     = "roles/storage.objectViewer"
  member   = "allUsers"
}

#uploading index.html file
resource "google_storage_bucket_object" "homepage" {
  name   = "index.html"
  source = "index.html"
  bucket = "armageddeon-fallout-bucket"
  content_type = "text/html"

  #depends on = task wont run until a bucket is created
  depends_on = [
    google_storage_bucket.bucket
  ]
}

#uploading image files
resource "google_storage_bucket_object" "images" {
  name   = "soueu_evellin.jpg"
  source = "soueu_evellin.jpg"
  bucket = "armageddeon-fallout-bucket"
  content_type = "image/jpg"

    #depends on = task wont run until a bucket is created
   depends_on = [ 
    google_storage_bucket.bucket
  ]
}

output "website_url" {
 value = "https://storage.googleapis.com/${google_storage_bucket.bucket.name}/index.html"

depends_on = [
    google_storage_bucket.bucket,
    google_storage_bucket_object.homepage
    #URL wont show up until the bucket is created and the html file is uploaded
  ]

}