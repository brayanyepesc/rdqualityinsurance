# 📋 Lista de Verificación - Despliegue AWS ECS

Usa esta lista para rastrear tu progreso en el despliegue.

## ✅ Pre-Despliegue

- [ ] Docker instalado y funcionando (`docker --version`)
- [ ] AWS CLI instalado (`aws --version`)
- [ ] AWS CLI configurado (`aws configure`)
- [ ] Cuenta de AWS activa
- [ ] Permisos IAM para ECR y ECS

## 📦 Paso 1: Crear Repositorio ECR

- [ ] Accedí a la consola de AWS
- [ ] Busqué y abrí "Elastic Container Registry"
- [ ] Creé un nuevo repositorio privado
- [ ] Nombre del repositorio: `rdqualityinsurance`
- [ ] Habilitado "Scan on push" para seguridad
- [ ] Copié el URI del repositorio (ejemplo: `123456789012.dkr.ecr.us-east-1.amazonaws.com/rdqualityinsurance`)

**URI de mi repositorio ECR:**
```
_________________________________
```

## 🏗️ Paso 2: Construir y Subir Imagen

- [ ] Construí la imagen Docker localmente (`docker build -t rdqualityinsurance .`)
- [ ] Probé la imagen localmente (opcional) (`docker run -p 3000:3000 rdqualityinsurance`)
- [ ] Me autentiqué en ECR (`aws ecr get-login-password...`)
- [ ] Etiqueté la imagen para ECR
- [ ] Subí la imagen a ECR (`docker push...`)
- [ ] Verifiqué en la consola de ECR que la imagen está disponible

**¿Usé el script automatizado?**
- [ ] Sí, ejecuté `./scripts/deploy-to-ecr.sh`
- [ ] No, lo hice manualmente

## 🖥️ Paso 3: Crear Cluster ECS

- [ ] Accedí a "Elastic Container Service" en AWS
- [ ] Hice clic en "Clusters" → "Create Cluster"
- [ ] Nombre del cluster: `rdqualityinsurance-cluster`
- [ ] Seleccioné "AWS Fargate" como infraestructura
- [ ] El cluster se creó exitosamente

## 📝 Paso 4: Crear Task Definition

- [ ] Hice clic en "Task Definitions" → "Create new Task Definition"
- [ ] Configuré Task family: `rdqualityinsurance-task`
- [ ] Seleccioné Launch type: Fargate
- [ ] CPU: 0.25 vCPU (256)
- [ ] Memory: 0.5 GB (512)
- [ ] Configuré el contenedor:
  - [ ] Nombre: `rdqualityinsurance-container`
  - [ ] Image URI: Mi URI de ECR completo
  - [ ] Port mapping: 3000, TCP, HTTP
- [ ] Habilitado log collection (CloudWatch)
- [ ] La Task Definition se creó exitosamente

## 🚀 Paso 5: Crear Service

- [ ] Fui a mi cluster `rdqualityinsurance-cluster`
- [ ] Hice clic en "Services" → "Create"
- [ ] Configuré:
  - [ ] Launch type: FARGATE
  - [ ] Task Definition: `rdqualityinsurance-task`
  - [ ] Service name: `rdqualityinsurance-service`
  - [ ] Desired tasks: 1
- [ ] Networking:
  - [ ] Seleccioné mi VPC
  - [ ] Seleccioné al menos 2 subnets
  - [ ] Configuré security group (permite puerto 3000)
  - [ ] Public IP: ENABLED
- [ ] El servicio se creó exitosamente
- [ ] La tarea está en estado "RUNNING"

## 🌐 Paso 6: Verificar Acceso

- [ ] Fui a Tasks en mi servicio
- [ ] Esperé a que el estado sea "RUNNING" (2-3 minutos)
- [ ] Copié la Public IP de la tarea
- [ ] Abrí `http://MI_IP_PUBLICA:3000` en el navegador
- [ ] **¡La aplicación está funcionando!** 🎉

**Mi IP Pública:**
```
_________________________________
```

## 🔄 Configuración Adicional (Opcional)

### Load Balancer y Dominio
- [ ] Creé un Application Load Balancer
- [ ] Configuré el Target Group
- [ ] Configuré un dominio en Route 53
- [ ] Configuré certificado SSL con ACM
- [ ] La aplicación es accesible por HTTPS con mi dominio

**Mi dominio:**
```
_________________________________
```

### CI/CD con GitHub Actions
- [ ] Agregué `AWS_ACCESS_KEY_ID` a GitHub Secrets
- [ ] Agregué `AWS_SECRET_ACCESS_KEY` a GitHub Secrets
- [ ] Actualicé `.github/workflows/deploy-to-ecs.yml` con mis valores
- [ ] Hice un push y el workflow se ejecutó correctamente
- [ ] Los despliegues automáticos están funcionando

### Monitoreo y Seguridad
- [ ] Configuré alarmas en CloudWatch
- [ ] Revisé los logs en CloudWatch Logs
- [ ] Configuré Auto Scaling (opcional)
- [ ] Revisé el escaneo de vulnerabilidades en ECR

## 📊 Información de mi Despliegue

**Región AWS:** ____________________

**Account ID:** ____________________

**Repositorio ECR:** rdqualityinsurance

**Cluster ECS:** rdqualityinsurance-cluster

**Service ECS:** rdqualityinsurance-service

**Task Definition:** rdqualityinsurance-task

**IP Pública:** ____________________

**Dominio (si aplica):** ____________________

## 🆘 Solución de Problemas

Si algo no funciona:

- [ ] Revisé los logs en CloudWatch
- [ ] Verifiqué que el security group permite tráfico en puerto 3000
- [ ] Verifiqué que la Public IP está habilitada
- [ ] Revisé la "Stopped reason" si la tarea falló
- [ ] Consulté la guía completa: [AWS_DEPLOYMENT_GUIDE.md](./AWS_DEPLOYMENT_GUIDE.md)

## 📈 Próximos Pasos

- [ ] Configurar backups automáticos
- [ ] Implementar base de datos (RDS si es necesario)
- [ ] Configurar CDN con CloudFront
- [ ] Mejorar el security group con reglas más específicas
- [ ] Configurar variables de entorno en ECS
- [ ] Documentar el proceso específico de mi aplicación

---

**Fecha de despliegue:** ____________________

**Versión desplegada:** ____________________

**Notas:**
```
_____________________________________________
_____________________________________________
_____________________________________________
```
