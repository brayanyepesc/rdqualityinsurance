#!/bin/bash

# Script para construir y subir la imagen Docker a AWS ECR
# Uso: ./scripts/deploy-to-ecr.sh [region] [account-id] [repository-name]

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Valores por defecto
DEFAULT_REGION="us-east-1"
DEFAULT_REPOSITORY="rdqualityinsurance"

# Obtener parámetros o usar valores por defecto
REGION=${1:-$DEFAULT_REGION}
ACCOUNT_ID=${2}
REPOSITORY=${3:-$DEFAULT_REPOSITORY}

echo -e "${YELLOW}=== Script de Despliegue a AWS ECR ===${NC}\n"

# Validar que se proporcionó el Account ID
if [ -z "$ACCOUNT_ID" ]; then
    echo -e "${YELLOW}Intentando obtener el Account ID automáticamente...${NC}"
    ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text 2>/dev/null)
    
    if [ -z "$ACCOUNT_ID" ]; then
        echo -e "${RED}Error: No se pudo obtener el Account ID automáticamente${NC}"
        echo -e "${YELLOW}Por favor, proporciona tu AWS Account ID como segundo parámetro:${NC}"
        echo -e "  ./scripts/deploy-to-ecr.sh [region] [account-id] [repository-name]"
        echo -e "\nPuedes obtener tu Account ID con:"
        echo -e "  aws sts get-caller-identity --query Account --output text"
        exit 1
    fi
fi

ECR_URI="${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com"
IMAGE_NAME="${ECR_URI}/${REPOSITORY}"

echo -e "${GREEN}Configuración:${NC}"
echo -e "  Región:         ${REGION}"
echo -e "  Account ID:     ${ACCOUNT_ID}"
echo -e "  Repositorio:    ${REPOSITORY}"
echo -e "  URI Completo:   ${IMAGE_NAME}"
echo ""

# Paso 1: Verificar que Docker está corriendo
echo -e "${YELLOW}[1/5] Verificando Docker...${NC}"
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}Error: Docker no está corriendo. Por favor, inicia Docker y vuelve a intentar.${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Docker está corriendo${NC}\n"

# Paso 2: Construir la imagen
echo -e "${YELLOW}[2/5] Construyendo imagen Docker...${NC}"
docker build -t ${REPOSITORY}:latest .
echo -e "${GREEN}✓ Imagen construida exitosamente${NC}\n"

# Paso 3: Autenticarse en ECR
echo -e "${YELLOW}[3/5] Autenticando en AWS ECR...${NC}"
aws ecr get-login-password --region ${REGION} | docker login --username AWS --password-stdin ${ECR_URI}
echo -e "${GREEN}✓ Autenticación exitosa${NC}\n"

# Paso 4: Etiquetar la imagen
echo -e "${YELLOW}[4/5] Etiquetando imagen...${NC}"
docker tag ${REPOSITORY}:latest ${IMAGE_NAME}:latest
docker tag ${REPOSITORY}:latest ${IMAGE_NAME}:$(date +%Y%m%d-%H%M%S)
echo -e "${GREEN}✓ Imagen etiquetada${NC}\n"

# Paso 5: Subir la imagen a ECR
echo -e "${YELLOW}[5/5] Subiendo imagen a ECR...${NC}"
docker push ${IMAGE_NAME}:latest
docker push ${IMAGE_NAME}:$(date +%Y%m%d-%H%M%S)
echo -e "${GREEN}✓ Imagen subida exitosamente${NC}\n"

echo -e "${GREEN}=== ✓ Despliegue completado exitosamente ===${NC}\n"
echo -e "Tu imagen está disponible en:"
echo -e "  ${IMAGE_NAME}:latest"
echo -e "\nPara actualizar el servicio ECS, ejecuta:"
echo -e "  aws ecs update-service --cluster rdqualityinsurance-cluster --service rdqualityinsurance-service --force-new-deployment --region ${REGION}"
