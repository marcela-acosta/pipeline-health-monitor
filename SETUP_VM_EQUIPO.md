# 🚀 Setup: Conexión a la VM `team-vm`

---

## 🔧 Setup por única vez

### Mac

1. **Instalar gcloud CLI**
```bash
brew install --cask google-cloud-sdk
```
Si no tienes Homebrew: https://cloud.google.com/sdk/docs/install

2. **Reiniciar la terminal, luego:**
```bash
gcloud init
```

3. **Autenticarse:**
```bash
gcloud auth login
```

4. **Configurar el proyecto:**
```bash
gcloud config set project pipeline-health-mon-2026
```

---

### Windows

1. **Instalar gcloud CLI**
   - **Opción A (recomendada):** En PowerShell, ejecuta:
     ```powershell
     winget install Google.CloudSDK
     ```
   - **Opción B:** Descargar el instalador en https://cloud.google.com/sdk/docs/install

2. **Verificar que OpenSSH esté instalado:**
   - Settings → Apps → Optional Features
   - Buscar `OpenSSH Client` → Install

3. **Abrir una nueva ventana de PowerShell** (no Git Bash), luego:
```powershell
gcloud init
```

4. **Autenticarse:**
```powershell
gcloud auth login
```

5. **Configurar el proyecto:**
```powershell
gcloud config set project pipeline-health-mon-2026
```

---

## ✅ Uso diario (igual en Mac y Windows)

### Prender la VM (si está apagada):
```bash
gcloud compute instances start team-vm --zone us-central1-a
```

### Conectarse:
```bash
gcloud compute ssh team-vm --zone us-central1-a --tunnel-through-iap
```

⚠️ **La primera vez puede:**
- Pedir instalar un componente → aceptar con `Y`
- Pedir generar una clave SSH → presionar `Enter` (sin passphrase)

### Salir de la VM:
```bash
exit
```
o `Ctrl+D`

---

## 🔴 Apagar la VM al terminar (IMPORTANTE para ahorrar costos):
```bash
gcloud compute instances stop team-vm --zone us-central1-a
```

---

## 💡 Tips

- **No olvides apagar la VM** al terminar tu sesión
- Si la VM tarda en conectar, es normal (primeras 2-3 veces)
- Todos comparten la misma VM, así que asegúrate de **coordinar con el equipo** los horarios de uso
- Para ver el estado de la VM: 
  ```bash
  gcloud compute instances list
  ```

---

## ❓ Problemas?

| Error | Solución |
|-------|----------|
| `gcloud: command not found` | Reinicia la terminal completamente |
| `Permission denied (publickey)` | Ejecuta `gcloud auth login` de nuevo |
| Timeout conectando | La VM podría estar apagada, usa el comando `start` |
| `OpenSSH not found` (Windows) | Instala OpenSSH Client en Settings |

Si algo no funciona, contacta a **Marcela** 📧
