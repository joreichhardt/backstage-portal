resource "google_sql_database_instance" "instance" {
  name             = "${{ values.instanceName }}"
  region           = "${{ values.region }}"
  database_version = "${{ values.databaseVersion }}"
  project          = "${{ values.projectId }}"

  settings {
    tier = "${{ values.tier }}"
  }

  deletion_protection = false # In Produktion auf 'true' setzen!
}

resource "google_sql_database" "database" {
  name     = "${{ values.dbName }}"
  instance = google_sql_database_instance.instance.name
  project  = "${{ values.projectId }}"
}

resource "google_sql_user" "users" {
  name     = "${{ values.userName }}"
  instance = google_sql_database_instance.instance.name
  project  = "${{ values.projectId }}"
  password = "changeme" # Hier sollte man idealerweise ein Secret aus dem Secret Manager nutzen
}
