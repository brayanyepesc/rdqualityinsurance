# Guía de Despliegue en AWS ECS con ECR

Esta guía te llevará paso a paso para desplegar tu aplicación Next.js en AWS ECS utilizando ECR (Elastic Container Registry).

## Requisitos Previos

Antes de comenzar, asegúrate de tener:

1. ✅ Una cuenta de AWS activa
2. ✅ AWS CLI instalado en tu máquina local
3. ✅ Docker instalado y en ejecución
4. ✅ Permisos de IAM necesarios en AWS (ECR, ECS, CloudWatch)

### Instalar AWS CLI (si no lo tienes)

**Windows:**
```bash
msiexec.exe /i https://awscli.amazonaws.com/AWSCLIV2.msi
```

**macOS:**
```bash
curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
sudo installer -pkg AWSCLIV2.pkg -target /
```

**Linux:**
```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

### Configurar AWS CLI

```bash
aws configure
```

Te pedirá:
- **AWS Access Key ID**: Tu clave de acceso de AWS
- **AWS Secret Access Key**: Tu clave secreta de AWS
- **Default region name**: Ejemplo: `us-east-1`
- **Default output format**: Puedes usar `json`

---

## PASO 1: Crear el Repositorio en ECR

### 1.1. Acceder a ECR en AWS Console

1. Inicia sesión en la [Consola de AWS](https://console.aws.amazon.com/)
2. En la barra de búsqueda superior, busca **"ECR"** o **"Elastic Container Registry"**
3. Haz clic en **"Elastic Container Registry"**

### 1.2. Crear el Repositorio

1. Haz clic en **"Get Started"** o **"Create repository"**
2. Configura lo siguiente:
   - **Visibility settings**: Selecciona **"Private"** (recomendado)
   - **Repository name**: `rdqualityinsurance` (o el nombre que prefieras)
   - **Tag immutability**: Deja en **"Disabled"** (puedes habilitarlo si quieres proteger tags)
   - **Scan on push**: Activa esta opción para escanear vulnerabilidades automáticamente
   - **Encryption settings**: Puedes dejar **"AES-256"** por defecto

3. Haz clic en **"Create repository"**

### 1.3. Anotar el URI del Repositorio

Una vez creado, verás algo como:
```
123456789012.dkr.ecr.us-east-1.amazonaws.com/rdqualityinsurance
```

**¡GUARDA ESTE URI!** Lo necesitarás más adelante.

---

## PASO 2: Construir la Imagen Docker Localmente

### 2.1. Verificar que Docker está corriendo

```bash
docker --version
docker ps
```

### 2.2. Construir la imagen

En la raíz del proyecto, ejecuta:

```bash
docker build -t rdqualityinsurance .
```

Este proceso puede tardar varios minutos. Verás la salida del build.

### 2.3. Verificar que la imagen se creó correctamente

```bash
docker images | grep rdqualityinsurance
```

### 2.4. (Opcional) Probar la imagen localmente

```bash
docker run -p 3000:3000 rdqualityinsurance
```

Abre tu navegador en `http://localhost:3000` para verificar que funciona.
Presiona `Ctrl+C` para detener el contenedor.

---

## PASO 3: Autenticarse en ECR

### 3.1. Obtener el comando de login

Reemplaza `us-east-1` con tu región y `123456789012` con tu Account ID:

```bash
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 123456789012.dkr.ecr.us-east-1.amazonaws.com
```

Deberías ver: `Login Succeeded`

**¿Cómo obtener tu Account ID?**
```bash
aws sts get-caller-identity --query Account --output text
```

---

## PASO 4: Etiquetar y Subir la Imagen a ECR

### 4.1. Etiquetar la imagen

Reemplaza con tu URI del repositorio ECR:

```bash
docker tag rdqualityinsurance:latest 123456789012.dkr.ecr.us-east-1.amazonaws.com/rdqualityinsurance:latest
```

### 4.2. Subir la imagen a ECR

```bash
docker push 123456789012.dkr.ecr.us-east-1.amazonaws.com/rdqualityinsurance:latest
```

Este proceso puede tardar varios minutos dependiendo del tamaño de tu imagen y tu conexión a internet.

### 4.3. Verificar en la consola de AWS

1. Ve a ECR en la consola de AWS
2. Haz clic en tu repositorio `rdqualityinsurance`
3. Deberías ver tu imagen con el tag `latest`

---

## PASO 5: Crear un Cluster de ECS

### 5.1. Acceder a ECS

1. En la consola de AWS, busca **"ECS"** o **"Elastic Container Service"**
2. Haz clic en **"Elastic Container Service"**

### 5.2. Crear el Cluster

1. Haz clic en **"Clusters"** en el menú lateral
2. Haz clic en **"Create Cluster"**
3. Configura:
   - **Cluster name**: `rdqualityinsurance-cluster`
   - **Infrastructure**: Selecciona **"AWS Fargate (serverless)"** (más fácil para empezar)
   - Deja las demás opciones por defecto
4. Haz clic en **"Create"**

---

## PASO 6: Crear una Task Definition (Definición de Tarea)

### 6.1. Acceder a Task Definitions

1. En ECS, haz clic en **"Task Definitions"** en el menú lateral
2. Haz clic en **"Create new Task Definition"**

### 6.2. Configurar la Task Definition

**Configuración básica:**
- **Task Definition family**: `rdqualityinsurance-task`
- **Launch type**: **Fargate**
- **Operating system/Architecture**: **Linux/X86_64**
- **Task size**:
  - **CPU**: `.25 vCPU` (256 para empezar, puedes aumentar después)
  - **Memory**: `.5 GB` (512 MB para empezar)

**Container - 1:**
- **Container name**: `rdqualityinsurance-container`
- **Image URI**: Pega tu URI completo de ECR, ejemplo:
  ```
  123456789012.dkr.ecr.us-east-1.amazonaws.com/rdqualityinsurance:latest
  ```
- **Port mappings**:
  - **Container port**: `3000`
  - **Protocol**: `TCP`
  - **Port name**: `rdqualityinsurance-3000-tcp`
  - **App protocol**: `HTTP`

**Environment variables** (opcional):
- Puedes añadir variables de entorno si tu app las necesita
- Ejemplo: `NODE_ENV=production`

**Logging** (recomendado):
- Deja habilitado **"Use log collection"**
- Esto enviará los logs a CloudWatch

3. Haz clic en **"Create"**

---

## PASO 7: Crear un Service (Servicio)

### 7.1. Crear el Service

1. En ECS, ve a tu cluster `rdqualityinsurance-cluster`
2. En la pestaña **"Services"**, haz clic en **"Create"**

### 7.2. Configurar el Service

**Environment:**
- **Compute options**: **Launch type**
- **Launch type**: **FARGATE**

**Deployment configuration:**
- **Application type**: **Service**
- **Family**: Selecciona `rdqualityinsurance-task`
- **Service name**: `rdqualityinsurance-service`
- **Desired tasks**: `1` (puedes aumentar después para escalabilidad)

**Networking:**
- **VPC**: Selecciona tu VPC por defecto
- **Subnets**: Selecciona al menos 2 subnets en diferentes zonas de disponibilidad
- **Security group**: 
  - Crea un nuevo security group o usa uno existente
  - **IMPORTANTE**: Asegúrate de que el security group permita tráfico entrante en el puerto **3000** (o el puerto que uses)
  - También permite tráfico HTTP (puerto 80) si usarás un Load Balancer

**Load balancing** (Opcional pero recomendado para producción):
- **Load balancer type**: **Application Load Balancer**
- Si es tu primera vez, puedes omitir esto y acceder directamente por IP pública
- Para producción, se recomienda configurar un ALB

**Public IP**: 
- Activa **"ENABLED"** si quieres acceder directamente sin Load Balancer

3. Haz clic en **"Create"**

---

## PASO 8: Verificar el Despliegue

### 8.1. Esperar a que el Service esté corriendo

1. Ve a tu cluster > Services > `rdqualityinsurance-service`
2. En la pestaña **"Tasks"**, verás el estado de tu tarea
3. Espera a que el estado sea **"RUNNING"** (puede tardar 2-3 minutos)

### 8.2. Obtener la IP pública

1. Haz clic en tu tarea en ejecución
2. En la sección **"Network"** o **"Configuration"**, encontrarás la **Public IP**
3. Copia la IP pública

### 8.3. Acceder a tu aplicación

Abre tu navegador y ve a:
```
http://TU_IP_PUBLICA:3000
```

**¡Felicidades! Tu aplicación está corriendo en AWS ECS.**

---

## PASO 9: (Opcional) Configurar un Dominio con Route 53 y Load Balancer

Si quieres usar un dominio personalizado:

1. **Crear un Application Load Balancer**
2. **Configurar el Target Group** apuntando a tu servicio ECS
3. **Crear un registro en Route 53** apuntando a tu ALB
4. **Configurar HTTPS con ACM** (AWS Certificate Manager)

---

## PASO 10: Automatizar Despliegues (Opcional)

Para automatizar futuros despliegues, puedes usar GitHub Actions. Ya hay un workflow preparado en `.github/workflows/deploy-to-ecr.yml` que puedes configurar.

---

## Comandos Útiles

### Ver logs del contenedor
```bash
aws logs tail /ecs/rdqualityinsurance-task --follow --region us-east-1
```

### Actualizar la imagen y hacer redeploy
```bash
# 1. Construir nueva imagen
docker build -t rdqualityinsurance .

# 2. Etiquetar
docker tag rdqualityinsurance:latest 123456789012.dkr.ecr.us-east-1.amazonaws.com/rdqualityinsurance:latest

# 3. Subir a ECR
docker push 123456789012.dkr.ecr.us-east-1.amazonaws.com/rdqualityinsurance:latest

# 4. Forzar nuevo despliegue en ECS
aws ecs update-service --cluster rdqualityinsurance-cluster --service rdqualityinsurance-service --force-new-deployment --region us-east-1
```

---

## Solución de Problemas

### La tarea no inicia / Estado "STOPPED"

1. Ve a la tarea que falló
2. Revisa la pestaña **"Logs"** o **"Stopped reason"**
3. Verifica que:
   - La imagen existe en ECR
   - Los puertos están correctamente configurados
   - Las variables de entorno son correctas

### No puedo acceder a la aplicación

1. Verifica el Security Group permite tráfico en el puerto 3000
2. Asegúrate de que la IP pública está habilitada
3. Revisa los logs de CloudWatch

### Error de autenticación con ECR

```bash
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 123456789012.dkr.ecr.us-east-1.amazonaws.com
```

---

## Costos Estimados

- **ECR**: ~$0.10 por GB/mes de almacenamiento
- **ECS Fargate**: 
  - ~$0.04048 por hora por vCPU
  - ~$0.004445 por hora por GB de memoria
  - Ejemplo: 0.25 vCPU + 0.5 GB = ~$0.013/hora = ~$9.50/mes si está corriendo 24/7

**Nota**: Los primeros 12 meses puedes calificar para AWS Free Tier.

---

## Próximos Pasos Recomendados

1. ✅ Configurar un Load Balancer para alta disponibilidad
2. ✅ Configurar Auto Scaling para manejar más tráfico
3. ✅ Implementar CI/CD con GitHub Actions
4. ✅ Configurar un dominio personalizado
5. ✅ Configurar HTTPS con ACM
6. ✅ Configurar monitoreo con CloudWatch Alarms
7. ✅ Implementar RDS para base de datos (si aplica)

---

## Recursos Adicionales

- [Documentación oficial de ECS](https://docs.aws.amazon.com/ecs/)
- [Documentación oficial de ECR](https://docs.aws.amazon.com/ecr/)
- [Next.js en Docker](https://nextjs.org/docs/deployment#docker-image)

---

**¿Necesitas ayuda?** Revisa cada paso cuidadosamente y verifica que todos los recursos estén en la misma región de AWS.
