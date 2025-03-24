module "database" {
  source = "./modules/database"


  cluster_name  = var.cluster_name
  database_name = var.database_name
  region        = var.region

  vpc_cidr = var.vpc_cidr
  azs      = var.azs

}