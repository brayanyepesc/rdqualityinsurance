# Guía Rápida de Inicio - Despliegue a AWS ECS

Esta es una guía rápida para comenzar. Para una guía completa paso a paso, consulta [AWS_DEPLOYMENT_GUIDE.md](./AWS_DEPLOYMENT_GUIDE.md).

## 📋 Prerrequisitos Rápidos

```bash
# 1. Verificar que tienes Docker instalado
docker --version

# 2. Verificar que tienes AWS CLI instalado
aws --version

# 3. Configurar AWS CLI (si aún no lo has hecho)
aws configure
```

## 🚀 Inicio Rápido (5 Pasos)

### Paso 1: Crear Repositorio en ECR

1. Ve a la [Consola de AWS](https://console.aws.amazon.com/)
2. Busca "ECR" y haz clic en "Elastic Container Registry"
3. Haz clic en "Create repository"
4. Nombre del repositorio: `rdqualityinsurance`
5. Deja las demás opciones por defecto y haz clic en "Create repository"
6. **Copia el URI del repositorio** (ejemplo: `123456789012.dkr.ecr.us-east-1.amazonaws.com/rdqualityinsurance`)

### Paso 2: Subir la Imagen a ECR

Usa el script automatizado (más fácil):

```bash
# Obtén tu Account ID automáticamente
./scripts/deploy-to-ecr.sh
```

O manualmente:

```bash
# 1. Construir la imagen
docker build -t rdqualityinsurance .

# 2. Autenticarse en ECR (reemplaza con tus valores)
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin TU_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com

# 3. Etiquetar la imagen
docker tag rdqualityinsurance:latest TU_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/rdqualityinsurance:latest

# 4. Subir a ECR
docker push TU_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/rdqualityinsurance:latest
```

### Paso 3: Crear Cluster de ECS

1. En la consola de AWS, busca "ECS"
2. Haz clic en "Clusters" → "Create Cluster"
3. Nombre: `rdqualityinsurance-cluster`
4. Infraestructura: Selecciona **"AWS Fargate"**
5. Haz clic en "Create"

### Paso 4: Crear Task Definition

1. En ECS, haz clic en "Task Definitions" → "Create new Task Definition"
2. Configuración básica:
   - **Task family**: `rdqualityinsurance-task`
   - **Launch type**: Fargate
   - **CPU**: 0.25 vCPU
   - **Memory**: 0.5 GB

3. Container:
   - **Nombre**: `rdqualityinsurance-container`
   - **Image URI**: Tu URI de ECR completo (del Paso 1)
   - **Port mapping**: Puerto 3000, TCP, HTTP

4. Haz clic en "Create"

### Paso 5: Crear y Ejecutar el Service

1. Ve a tu cluster `rdqualityinsurance-cluster`
2. En la pestaña "Services", haz clic en "Create"
3. Configuración:
   - **Launch type**: FARGATE
   - **Task Definition**: `rdqualityinsurance-task`
   - **Service name**: `rdqualityinsurance-service`
   - **Desired tasks**: 1
   - **VPC**: Usa tu VPC por defecto
   - **Subnets**: Selecciona al menos 2
   - **Security group**: Crea uno nuevo o usa existente (permite puerto 3000)
   - **Public IP**: ENABLED

4. Haz clic en "Create"

### Paso 6: Acceder a tu Aplicación

1. Ve a tu cluster → Services → Tu servicio → Tasks
2. Haz clic en tu tarea en ejecución
3. Copia la **Public IP**
4. Abre en tu navegador: `http://TU_IP_PUBLICA:3000`

**🎉 ¡Listo! Tu aplicación está corriendo en AWS ECS**

---

## 🔄 Actualizar la Aplicación

Para actualizar con nuevos cambios:

```bash
# 1. Reconstruir y subir imagen
./scripts/deploy-to-ecr.sh

# 2. Forzar nuevo despliegue
aws ecs update-service --cluster rdqualityinsurance-cluster --service rdqualityinsurance-service --force-new-deployment --region us-east-1
```

---

## 🤖 Despliegue Automático con GitHub Actions

Para configurar CI/CD automático:

1. Ve a tu repositorio en GitHub → Settings → Secrets and variables → Actions
2. Agrega estos secrets:
   - `AWS_ACCESS_KEY_ID`: Tu AWS Access Key
   - `AWS_SECRET_ACCESS_KEY`: Tu AWS Secret Key

3. Edita `.github/workflows/deploy-to-ecs.yml` y actualiza:
   - `AWS_REGION`: Tu región (ej: us-east-1)
   - `ECR_REPOSITORY`: rdqualityinsurance
   - `ECS_SERVICE`: rdqualityinsurance-service
   - `ECS_CLUSTER`: rdqualityinsurance-cluster

4. Ahora cada push a `main` o `production` desplegará automáticamente

---

## 📚 Documentación Adicional

- **Guía Completa**: [AWS_DEPLOYMENT_GUIDE.md](./AWS_DEPLOYMENT_GUIDE.md) - Incluye solución de problemas, configuración de dominios, HTTPS, etc.
- **Dockerfile**: Configuración de contenedor optimizada para Next.js
- **docker-compose.yml**: Para testing local
- **ecs-task-definition.json**: Template de configuración de ECS

---

## ❓ Preguntas Frecuentes

**P: ¿Cuánto cuesta esto?**
R: Con 0.25 vCPU + 0.5 GB corriendo 24/7: ~$9.50/mes (primeros 12 meses pueden ser gratis con AWS Free Tier)

**P: ¿Cómo escalar mi aplicación?**
R: En tu servicio ECS, aumenta el número de "Desired tasks" a 2 o más.

**P: ¿Cómo configuro un dominio personalizado?**
R: Consulta la sección "Configurar un Dominio" en [AWS_DEPLOYMENT_GUIDE.md](./AWS_DEPLOYMENT_GUIDE.md)

**P: ¿Qué hago si la tarea falla?**
R: Revisa los logs en CloudWatch Logs o en la consola de ECS → Task → Logs

---

## 🆘 Ayuda

Si tienes problemas, consulta:
1. La guía completa: [AWS_DEPLOYMENT_GUIDE.md](./AWS_DEPLOYMENT_GUIDE.md)
2. Los logs de CloudWatch en la consola de AWS
3. La sección de "Solución de Problemas" en la guía completa
