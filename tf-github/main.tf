#
provider "github" {
  token = var.github_token # Reference the token from variables
}

resource "github_repository" "tech264_tf_repo" {
  name        = "tech264-georgia-tf-create-github-repo" # Repository name
  description = "Repository created by Terraform"
  visibility  = "public" # Set to "private" if you want a private repo
}


