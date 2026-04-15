module "network" {
  source = "./modules/network"

  vpc_cidr    = var.vpc_cidr
  subnet_pubb = var.subnet_pubb
  subnet_pubb2 = var.subnet_pubb2
  subnet_priv = var.subnet_priv
  subnet_priv2 = var.subnet_priv2
  region      = var.region
}

module "security" {
  source = "./modules/security"
  db_password = var.db_password
}

module "load_balancer" {
  source = "./modules/load_balancer"

  vpc_id            = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids
}

module "database" {
  source = "./modules/database"

  vpc_id           = module.network.vpc_id
  priv_subnet_ids  = module.network.priv_subnet_ids
  app_subnet_cidrs = module.network.priv_subnet_cidrs

  db_name     = var.db_name
  db_user     = var.db_user
  db_password = var.db_password
}

module "compute" {
  source = "./modules/compute"

  ami                   = var.ami
  instance_type         = var.instance_type
  region                = var.region
  vpc_id                = module.network.vpc_id
  private_subnet_ids    = module.network.priv_subnet_ids
  target_group_arn      = module.load_balancer.target_group_arn
  instance_profile_name = module.security.instance_profile_name
  alb_sg_id             = module.load_balancer.alb_sg_id
  db_host     = module.database.db_host
  db_user     = var.db_user
  db_name     = var.db_name
}