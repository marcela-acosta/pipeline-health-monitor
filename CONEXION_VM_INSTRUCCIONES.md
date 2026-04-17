# 🚀 Conexión a la VM del Proyecto - Instrucciones para el Equipo

> **VM:** `team-vm` en GCP (Proyecto: `pipeline-health-mon-2026`)  
> **Zona:** `us-central1-a`

---

## **Opción A: Conexión Rápida (Recomendado para trabajar en IDE)**

Usar **Remote SSH** en Cursor o VSCode es la mejor experiencia.

### **Paso 1: Instalar Google Cloud SDK**

#### **macOS:**
```bash
brew install --cask google-cloud-sdk
```

#### **Windows:**
1. Descarga el instalador: https://cloud.google.com/sdk/docs/install-sdk
2. Ejecuta el instalador (.exe)
3. Reinicia la terminal/PowerShell

---

### **Paso 2: Autenticarse con GCP**

```bash
gcloud auth login
```

Se abrirá un navegador. Inicia sesión con tu cuenta de Google. ✅

---

### **Paso 3: Instalar/Habilitar IAP Plugin**

```bash
gcloud components install cloud-iap-desktop-ssh-helper
```

---

### **Paso 4: Configurar Remote SSH en tu IDE**

#### **Para Cursor:**
1. Abre Cursor
2. Ve a: **Extensions** → Busca `Remote - SSH` (by Microsoft)
3. Instala la extensión
4. Click en el icono verde `><` (esquina inferior izquierda)
5. Selecciona `Connect to Host...`
6. Elige `+ Add New SSH Host`
7. Pega este comando:
   ```
   gcloud compute ssh team-vm --project pipeline-health-mon-2026 --zone us-central1-a --tunnel-through-iap
   ```
8. Elige la ubicación para guardar config (por defecto está bien)

#### **Para VSCode:**
1. Abre VSCode
2. Ve a: **Extensions** → Busca `Remote - SSH` (by Microsoft)
3. Instala la extensión
4. Click en el icono verde `><` (esquina inferior izquierda)
5. Selecciona `Connect to Host...`
6. Elige `+ Add New SSH Host`
7. Pega este comando:
   ```
   gcloud compute ssh team-vm --project pipeline-health-mon-2026 --zone us-central1-a --tunnel-through-iap
   ```
8. Elige la ubicación para guardar config

---

### **Paso 5: Conectar a la VM**

1. Click en `><` (esquina inferior izquierda)
2. `Connect to Host...`
3. Selecciona `team-vm`
4. Espera a que se abra la conexión (primera vez tarda ~30 segundos)
5. ¡Listo! Ya tienes la VM en tu IDE 🎉

---

## **Opción B: Conexión por Terminal (Si prefieres línea de comandos)**

### **Paso 1 y 2:** Igual que arriba (instalar gcloud + autenticarse)

### **Paso 3: Encender la VM** (Cada vez que la uses)
```bash
gcloud compute instances start team-vm --project pipeline-health-mon-2026 --zone us-central1-a
```

**Output esperado:**
```
Starting instance(s) team-vm...done.
Instance internal IP is 10.128.0.3
Instance external IP is 34.29.231.185
```

### **Paso 4: Conectar a la VM**
```bash
gcloud compute ssh team-vm --project pipeline-health-mon-2026 --zone us-central1-a --tunnel-through-iap
```

**Output esperado:**
```
Linux team-vm 6.1.0-43-cloud-amd64 ...
marcelacostoff_gmail_com@team-vm:~$
```

¡Ya estás dentro! Ahora puedes trabajar con comandos de Linux.

---

## **Comandos Útiles en la VM**

```bash
# Ver qué hay en el proyecto
ls -la

# Navegar a la carpeta del proyecto
cd /path/to/project

# Ver archivos con git
git status

# Actualizar código
git pull

# Salir de la VM
exit
```

---

## **¿Cómo apagar la VM?** (Para ahorrar costos)

```bash
gcloud compute instances stop team-vm --project pipeline-health-mon-2026 --zone us-central1-a
```

---

## **Troubleshooting**

### ❌ "gcloud: command not found"
- **macOS:** Reinicia la terminal o ejecuta `source ~/.bashrc`
- **Windows:** Reinicia PowerShell/CMD completamente

### ❌ "Permission denied (publickey)"
- Asegúrate de haber corrido `gcloud auth login`
- Verifica que tengas permisos en el proyecto de GCP

### ❌ "Timeout conectando a la VM"
- La VM podría estar apagada. Ejecuta el comando de `instances start`
- Espera 10 segundos y reintenta

### ❌ "IAP Authentication failed"
- Asegúrate de tener `cloud-iap-desktop-ssh-helper` instalado
- Reinicia la terminal y prueba de nuevo

---

## **Preguntas? Contacta a Marcela** 📧
Si algo no funciona, avísame para debuggear juntos.
