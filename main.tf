module "s3_bucket" {
  source      = "./s3_bucket"
  bucket_name = var.bucket_name
}

module "s3_object" {
  source      = "./s3_object"
  bucket_id   = module.s3_bucket.bucket_id
  folder_name = "./application-code/"
}

module "iam_role" {
  source        = "./iam_role"
  iam_role_name = var.iam_role_name
}

module "networking" {
  source                   = "./networking"
  vpc_name                 = var.vpc_name
  vpc_cidr                 = var.vpc_cidr
  public_subnet_cidr       = var.public_subnet_cidr
  private_subnet_cidr      = var.private_subnet_cidr
  subnet_availability_zone = var.subnet_availability_zone
}

module "security_groups" {
  source                = "./security_gp"
  vpc_id                = module.networking.three_tier_vpc_id
  internet_facing_lb_sg = "internet_facing_lb_sg"
  web_tier_sg           = "web_tier_sg"
  internal_lb_sg        = "internal_lb_sg"
  private_instance_sg   = "private_instance_sg"
  db_sg                 = "db_sg"
}

module "rds_db_instance" {
  source               = "./database_deployment"
  db_subnet_group_name = "rds_sg"
  subnet_groups        = tolist(module.networking.private_subnet_id)
  mysql_db_identifier  = "database-1"
  mysql_username       = "admin"
  mysql_password       = "password"
  rds_mysql_sg_id      = module.security_groups.rds_sg_id
  mysql_dbname         = "webappdb"
}


module "applayer_instance" {
  source          = "./AppLayer_instance"
  public_key_path = "./ssh_key/three_tier.pub"
  ami_id          = "ami-0cf10cdf9fcd62d37"
  instance_name   = "applayer"
  instance_type   = "t2.micro"
  subnet_id       = tolist(module.networking.private_subnet_id)[0]
  sg_for_app      = [module.security_groups.private_instance_sg]
  role_arn        = module.iam_role.instance_profile_name
  key_pair_name = "app_key"
}

module "app_lb_tg" {
  source         = "./lb_tg"
  lb_tg_name     = "AppTierTargetGroup"
  lb_tg_port     = "4000"
  lb_tg_protocol = "HTTP"
  vpc_id         = module.networking.three_tier_vpc_id
  ec2_id         = module.applayer_instance.ec2_id
}

module "alb_internal_lb" {
  source                    = "./lb"
  lb_name                   = "app-tier-internal-lb"
  lb_type                   = "application"
  lb_sg                     = module.security_groups.internal_lb_sg_id
  subnets_id                = tolist(module.networking.private_subnet_id)
  lb_tg_arn                 = module.app_lb_tg.lb_tg_arn
  ec2_instance_id           = module.applayer_instance.ec2_id
  lb_tg_attachement_port    = 4000
  lb_listner_port           = 80
  lb_listner_protocol       = "HTTP"
  lb_listner_default_action = "forward"
  tg_arn                    = module.app_lb_tg.lb_tg_arn
  is_internal_lb            = true
}

module "weblayer_instance" {
  source          = "./AppLayer_instance"
  public_key_path = "./ssh_key/three_tier.pub"
  ami_id          = "ami-0cf10cdf9fcd62d37"
  instance_name   = "weblayer"
  instance_type   = "t2.micro"
  subnet_id       = tolist(module.networking.public_subnet_id)[0]
  sg_for_app      = [ module.security_groups.web_tier_sg_id ]
  role_arn        = module.iam_role.instance_profile_name
  key_pair_name = "web_key"
}


module "webapp_lb_tg" {
  source         = "./lb_tg"
  lb_tg_name     = "WebTierTargetGroup"
  lb_tg_port     = "80"
  lb_tg_protocol = "HTTP"
  vpc_id         = module.networking.three_tier_vpc_id
  ec2_id         = module.weblayer_instance.ec2_id
}

module "alb_external_lb" {
  source                    = "./lb"
  lb_name                   = "web-tier-internal-lb"
  lb_type                   = "application"
  lb_sg                     = module.security_groups.external_lb_sg_id
  subnets_id                = tolist(module.networking.public_subnet_id)
  lb_tg_arn                 = module.webapp_lb_tg.lb_tg_arn
  ec2_instance_id           = module.weblayer_instance.ec2_id
  lb_tg_attachement_port    = 80
  lb_listner_port           = 80
  lb_listner_protocol       = "HTTP"
  lb_listner_default_action = "forward"
  tg_arn = module.webapp_lb_tg.lb_tg_arn
  is_internal_lb            = false
}

