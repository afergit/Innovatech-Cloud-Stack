#!/bin/bash
set -e

REGION="us-east-1"
# AMI para Ubuntu 22.04 LTS en us-east-1
AMI_ID="ami-0c7217cdde317cfec" 
INSTANCE_TYPE="t3.micro"

echo "=== 1. Creando Infraestructura de Red (VPC) para Innovatech ==="
VPC_ID=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=innovatech-vpc" --query "Vpcs[0].VpcId" --output text)
if [ "$VPC_ID" == "None" ] || [ -z "$VPC_ID" ]; then
  VPC_ID=$(aws ec2 create-vpc --cidr-block 10.0.0.0/16 --query 'Vpc.VpcId' --output text)
  aws ec2 create-tags --resources $VPC_ID --tags Key=Name,Value=innovatech-vpc
  aws ec2 modify-vpc-attribute --vpc-id $VPC_ID --enable-dns-hostnames "{\"Value\":true}"
fi

SUBNET_ID=$(aws ec2 describe-subnets --filters "Name=tag:Name,Values=innovatech-public-subnet" --query "Subnets[0].SubnetId" --output text)
if [ "$SUBNET_ID" == "None" ] || [ -z "$SUBNET_ID" ]; then
  SUBNET_ID=$(aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block 10.0.1.0/24 --availability-zone ${REGION}a --query 'Subnet.SubnetId' --output text)
  aws ec2 create-tags --resources $SUBNET_ID --tags Key=Name,Value=innovatech-public-subnet
  
  IGW_ID=$(aws ec2 create-internet-gateway --query 'InternetGateway.InternetGatewayId' --output text)
  aws ec2 attach-internet-gateway --vpc-id $VPC_ID --internet-gateway-id $IGW_ID

  ROUTE_TABLE_ID=$(aws ec2 create-route-table --vpc-id $VPC_ID --query 'RouteTable.RouteTableId' --output text)
  aws ec2 create-route --route-table-id $ROUTE_TABLE_ID --destination-cidr-block 0.0.0.0/0 --gateway-id $IGW_ID
  aws ec2 associate-route-table --subnet-id $SUBNET_ID --route-table-id $ROUTE_TABLE_ID
fi

aws ec2 modify-subnet-attribute --subnet-id $SUBNET_ID --map-public-ip-on-launch "{\"Value\":true}"

echo "=== 2. Configurando Seguridad (Firewall) ==="
SG_ID=$(aws ec2 describe-security-groups --filters "Name=group-name,Values=innovatech-sg" --query "SecurityGroups[0].GroupId" --output text)
if [ "$SG_ID" == "None" ] || [ -z "$SG_ID" ]; then
  SG_ID=$(aws ec2 create-security-group --group-name innovatech-sg --description "Seguridad Innovatech 3-Tier" --vpc-id $VPC_ID --query 'GroupId' --output text)
  # Puertos para Innovatech
  aws ec2 authorize-security-group-ingress --group-id $SG_ID --protocol tcp --port 80 --cidr 0.0.0.0/0
  aws ec2 authorize-security-group-ingress --group-id $SG_ID --protocol tcp --port 8080 --cidr 0.0.0.0/0
  aws ec2 authorize-security-group-ingress --group-id $SG_ID --protocol tcp --port 8081 --cidr 0.0.0.0/0
  aws ec2 authorize-security-group-ingress --group-id $SG_ID --protocol tcp --port 3306 --cidr 10.0.0.0/16
fi

echo "=== 3. Creando Repositorios de Imágenes (Amazon ECR) ==="
for repo in innovatech-front innovatech-back-ventas innovatech-back-despachos innovatech-db; do
  aws ecr describe-repositories --repository-names $repo >/dev/null 2>&1 || aws ecr create-repository --repository-name $repo
done

echo "=== 4. Lanzando Instancias EC2 (Frontend, Backend, DB) ==="
cat <<EOF > user_data.sh
#!/bin/bash
apt-get update -y
apt-get install -y docker.io unzip curl
systemctl start docker
systemctl enable docker
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
rm -rf awscliv2.zip ./aws
EOF

get_or_create_ec2() {
  local name=$1
  local id=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$name" "Name=instance-state-name,Values=running,pending" --query "Reservations[0].Instances[0].InstanceId" --output text)
  if [ "$id" == "None" ] || [ -z "$id" ]; then
    id=$(aws ec2 run-instances \
      --image-id $AMI_ID \
      --count 1 \
      --instance-type $INSTANCE_TYPE \
      --subnet-id $SUBNET_ID \
      --security-group-ids $SG_ID \
      --iam-instance-profile Name=LabInstanceProfile \
      --associate-public-ip-address \
      --user-data file://user_data.sh \
      --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$name}]" \
      --query 'Instances[0].InstanceId' \
      --output text)
  fi
  echo "$id"
}

FRONT_ID=$(get_or_create_ec2 "innovatech-front")
BACK_ID=$(get_or_create_ec2 "innovatech-back")
DB_ID=$(get_or_create_ec2 "innovatech-db")

rm -f user_data.sh
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)

echo "--------------------------------------------------------"
echo " ¡INFRAESTRUCTURA DE INNOVATECH CREADA!"
echo "--------------------------------------------------------"
echo "Copia estos valores en tus GitHub Secrets:"
echo "EC2_FRONTEND_INSTANCE_ID : $FRONT_ID"
echo "EC2_BACKEND_INSTANCE_ID  : $BACK_ID"
echo "EC2_DB_INSTANCE_ID       : $DB_ID"
echo "ECR_REGISTRY             : $AWS_ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com"
echo "--------------------------------------------------------"
