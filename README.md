# AURA RAG: chat con tus documentos de Google Drive

Un chat (LobeChat) que responde usando los documentos de una carpeta de Google Drive.
Todo corre **en tu PC** con Docker: n8n (flujos) + Postgres con pgvector (datos) + LobeChat (chat) + Gemini (IA).

Seguí los pasos **en orden**. Cada paso dice cómo saber que salió bien (✅).

> 📋 Los cuadros grises son comandos: copialos, pegalos en PowerShell y apretá Enter.

---

## PASO 1 · Instalar Docker

1. Entrá a https://www.docker.com/products/docker-desktop y descargá **Docker Desktop**.
2. Instalalo (Siguiente, Siguiente…) y reiniciá la PC si lo pide.
3. Abrí **Docker Desktop** y dejalo abierto.

✅ Abajo a la izquierda de Docker Desktop se ve un cuadro verde.

## PASO 2 · Bajar el proyecto

En la página del repositorio de GitHub: botón verde **Code** → **Download ZIP**. Descomprimilo en `Documentos`. En esta guía le decimos "la carpeta del proyecto".

## PASO 3 · Crear el archivo de claves (`.env`)

1. Dentro de la carpeta del proyecto buscá el archivo `.env.example`.
2. Copialo y ponele de nombre `.env` a la copia.
3. Abrilo con el Bloc de notas.
4. Cada línea que termina en `=` sin nada (contraseñas y secretos), completala con una clave **larga y distinta** cada vez. Para generar una al azar, pegá esto en PowerShell, copiá el resultado y pegalo en el `.env`. Repetilo para cada línea:

```powershell
-join ((48..57)+(97..102) | Get-Random -Count 48 | % {[char]$_})
```

5. Guardá.

⚠️ Guardá una copia del `.env` en un lugar seguro. Si lo perdés, se pierde todo. **Nunca lo subas a internet.**

## PASO 4 · Encender

1. En el Explorador, abrí la carpeta del proyecto.
2. Hacé clic en la barra de arriba (donde dice la ruta), escribí `powershell` y apretá Enter.
3. En la ventana azul pegá:

```powershell
docker compose up -d
```

4. Esperá 2 minutos.

✅ Abrí http://localhost:5678 → aparece n8n. Creá tu usuario y contraseña.
✅ Abrí http://localhost:3210 → aparece LobeChat ("Sign up or sign in to your LobeHub account"). La cuenta es **solo de tu PC** (no se crea nada en internet). Para crearla:
  1. En **Enter your email or username** escribí un email cualquiera (ej. `yo@correo.com`).
  2. Marcá la casilla **I have read and agree to the Terms and Conditions and Privacy Policy**.
  3. Clic en **Next**. Como es un email nuevo, te lleva a **Create a LobeHub Account**.
  4. Completá **Enter your password** y **Confirm your password** (una contraseña que te acuerdes), marcá otra vez la casilla de términos y clic en **Sign Up**.

  Después aparece un asistente de bienvenida:
  1. **Let's get started**.
  2. Idioma: dejá **English** y apretá la flecha.
  3. "What should I call you?": escribí tu nombre.
  4. Áreas de interés: **Next**.
  5. Agentes: **Skip for now**.

  ✅ Llegás a la pantalla de inicio que dice "Good afternoon (o morning)…".

## PASO 5 · Activar el buscador de documentos

En la misma ventana azul pegá:

```powershell
docker compose exec postgres sh -c 'psql -U "$POSTGRES_USER" -d aura -c "CREATE EXTENSION IF NOT EXISTS vector;"'
```

✅ Responde `CREATE EXTENSION`.

## PASO 6 · Preparar Google Drive

**A) Carpetas en Drive** (https://drive.google.com)

1. Creá una carpeta llamada `aura-docs`.
2. Adentro, creá una carpeta por tema, con **estos nombres exactos**:
   `recursos_humanos`, `desarrollo_profesional`, `informacion_general`, `organizacion_interna`.
3. Subí los PDF o documentos a la carpeta que corresponda.

**B) Crear el "bot" que lee Drive**

Es un usuario robot de Google. Se crea en 4 mini-pasos. Usá los **links directos** (así no te perdés en los menús de Google). Iniciá sesión con tu cuenta de Google si te lo pide. Si Google te pregunta algo que no está acá, dejá lo que viene por defecto.

**B1 · Crear un proyecto** (es como una "carpeta" de Google para tus cosas)

1. Abrí https://console.cloud.google.com/projectcreate
2. En **Nombre del proyecto** escribí `aura`.
3. Clic en **Crear**.
4. Arriba (barra azul/negra) vas a ver una campanita. Esperá unos segundos. Después, arriba a la izquierda, clic en el nombre del proyecto y elegí **aura** (es importante estar en `aura` para los pasos que siguen).

✅ Arriba a la izquierda se lee **aura**.

**B2 · Encender Google Drive para ese proyecto**

1. Abrí https://console.cloud.google.com/apis/library/drive.googleapis.com
2. Verificá que arriba diga **aura**.
3. Clic en el botón azul **Habilitar** (o **Enable**).

✅ Se abre una pantalla con gráficos y dice **API habilitada**. Si el botón dice **Administrar**, ya estaba habilitada: seguí.

**B3 · Crear el robot**

1. Abrí https://console.cloud.google.com/iam-admin/serviceaccounts/create
2. La pantalla se llama **Crear cuenta de servicio** y tiene 3 pasos. En el primero, en **Nombre de la cuenta de servicio**, escribí `aura-bot`.
3. Clic en **Crear y continuar**.
4. Los pasos 2 y 3 son **Permisos (opcional)** y **Principales con acceso (opcional)**: **no completes nada**. Clic en **Continuar** y al final en **Crear y cerrar**.

✅ Volvés a la lista **Cuentas de servicio** y aparece una fila con un **Correo electrónico** largo que termina en `iam.gserviceaccount.com`.

**B4 · Copiar el email y descargar la llave**

1. En la fila nueva, copiá el **Correo electrónico** (seleccionalo y Ctrl + C). Pegalo en un bloc de notas: lo vas a usar en el paso C.
2. Clic sobre ese correo (se abre la página de la cuenta).
3. Arriba hay pestañas: **Detalles**, **Permisos**, **Claves**… Clic en **Claves**.
4. Clic en **Agregar clave** → **Crear clave nueva**.
5. Se abre un cuadro que dice **Crear clave privada**. Dejá marcado **JSON** (dice "Recomendado") → clic en **Crear**.
6. Se descarga un archivo `.json` a la carpeta **Descargas**. **Guardalo y no lo compartas con nadie:** es la llave del robot.

✅ Tenés en Descargas un archivo que empieza con `aura-` y termina en `.json`.

❓ Si en B4 aparece un error de "política de la organización" (cuentas de Google de trabajo o colegio), usá una cuenta de Gmail personal o pedile a quien administra Google que te habilite crear claves.

**C) Darle permiso**

1. En Drive, clic derecho en `aura-docs` → **Compartir**.
2. Pegá el email del bot → rol **Lector** → **Enviar**.

**D) Copiar el número de la carpeta**

Abrí `aura-docs` en Drive. En la barra del navegador, copiá el código largo del final:
`drive.google.com/drive/folders/` **ESTE_CÓDIGO**. Guardalo en un bloc de notas.

## PASO 7 · Clave de la IA (Gemini)

1. Entrá a https://aistudio.google.com/apikey
2. **Crear clave de API**. Copiala.

## PASO 8 · Cargar las 3 claves en n8n

n8n está en **inglés**. En http://localhost:5678: clic en **Personal** (menú de la izquierda) → pestaña **Credentials** → botón naranja **Create credential**.
Se abre un cuadro **Add new credential** con un buscador (**Search for app...**). Escribí el nombre, elegilo de la lista y completá. Hacelo 3 veces:

**1) Buscá `Google Gemini(PaLM) Api`**
- API Key: pegá la clave del paso 7 → **Save**.

**2) Buscá `Postgres`**
- Host: `postgres`
- Database: `aura`
- User: el valor de `POSTGRES_USER` de tu `.env`
- Password: el valor de `POSTGRES_PASSWORD` de tu `.env`
- Port: `5432`
- SSL: Disable
- **Save**.

**3) Buscá `Google Service Account API`**
- Abrí el archivo JSON (paso 6 B4) con el Bloc de notas (clic derecho → Abrir con → Bloc de notas).
- **Service Account Email:** copiá el texto que está después de `"client_email":` (sin las comillas). Es el mismo email del bot.
- **Private Key:** copiá el texto que está después de `"private_key":`, sin las comillas de los extremos. Empieza con `-----BEGIN PRIVATE KEY-----` y termina con `-----END PRIVATE KEY-----\n`. Se pega tal cual, con los `\n` adentro.
- **Region:** dejá lo que viene por defecto. **Impersonate a User:** dejalo apagado.
- **Save**.

✅ Las 3 aparecen en la lista de Credentials.

## PASO 9 · Cargar los flujos

Se hace **de a uno** (5 veces). Para cada archivo:

1. En n8n: **Personal** → pestaña **Workflows** → botón naranja **Create workflow** (se abre un flujo vacío).
2. Arriba, al lado del nombre del flujo (`My workflow`), clic en los **tres puntitos `⋯`**.
3. **Import** → **From file** → elegí el archivo `.json`.
4. Guardá con **Ctrl + S**.

> El botón de importar **no** está en el menú de al lado de "Create workflow"; está en los tres puntitos de adentro del flujo.

Orden de los archivos (carpeta `workflows`):

1. `2.2 Cerebro Especializado.json`
2. `2.1 Cerebro Orquestador.json`
3. `3.2 - Procesador de Archivos.json`
4. `3.1 - Sincronizador y Limpiador.json`
5. `1. Entrada Lobe Chat _ Gradio.json`

## PASO 10 · Conectar las claves a los flujos

Abrí cada uno de los 5 flujos. Los cuadritos (nodos) con **alerta roja** o **"Credential"** necesitan una clave:
doble clic en el nodo → se abre su ventana con pestañas **Parameters** y **Settings** → en el campo **Credential** elegí la que corresponde (Gemini, Postgres o Google Service Account) → cerrá la ventana (Esc).

En el flujo **3.1** (y en **3.2**, nodo `Download File`), los nodos de Google Drive:
- **Authentication:** `Service Account`.
- En 3.1, los nodos `Conocimiento` y `Buscar Sector`: en **Folder** elegí **By ID** y pegá el número del paso 6D (hoy dice `PEGAR_ID_CARPETA_DRIVE`).

**Guardar** cada flujo (Ctrl + S).

## PASO 11 · Encender los flujos y cargar documentos

**Publicá en este orden** (arriba a la derecha, botón **Publish**, en cada flujo; el nombre del flujo y su carpeta se ven arriba, ej. `AURA / 3.1 - …`). El orden importa: n8n no deja publicar uno si los que usa no están publicados.

1. `2.2 Cerebro Especializado`
2. `2.1 Cerebro Orquestador`
3. `1. Entrada Lobe Chat _ Gradio`

Después cargá los documentos:

4. Abrí `3.1 - Sincronizador y Limpiador` → botón naranja **Execute** (abajo, al centro del lienzo) y esperá unos minutos hasta que termine.

✅ Termina con tildes verdes. Ahora los documentos están cargados.

(Para que 3.1 se repita solo cada día a las 8, publicá primero `3.2 - Procesador de Archivos` y después `3.1`.)

## PASO 12 · Conectar el chat

LobeChat también está en **inglés**. Abrí http://localhost:3210/settings/provider (o: tu nombre abajo a la izquierda → **Settings** → **Provider**).

**A) Crear el proveedor**

1. Arriba de la lista de proveedores, al lado de **Search Providers...**, clic en el **`+`**.
2. Se abre **Create Custom AI Provider**. Completá:
   - **Provider ID:** `aura`
   - **Provider Name:** `AURA`
   - **Request Format:** elegí **OpenAI**
   - **Proxy URL:** `http://n8n:5678/webhook/f7fb6a81-7783-46c6-adbc-c7acb83cbd02`
   - **API Key:** escribí cualquier cosa (ej. `x`)
3. Clic en **Create**. ✅ Aparece "Creation successful".

**B) Crear el modelo**

1. En la pantalla de **AURA**, bajá hasta **Model List** → clic en **Add Model**.
2. **Model ID:** `aura` · **Model Display Name:** `AURA` → clic en **OK**.

**C) Probar la conexión**

1. Dejá apagado el interruptor **Use Client Request Mode** (tiene que estar apagado).
2. En **Connectivity Check** elegí el modelo `aura` → clic en **Check**.

✅ Se pone verde y dice **Check Passed**. Eso quiere decir que LobeChat llegó a n8n y n8n respondió.

**D) Chatear**

1. En la pantalla de inicio de LobeChat (clic en **Home**), abajo a la derecha del cuadro de texto hay un nombre de modelo (ej. `DeepSeek V4 Flash`). Clic ahí.
2. Se abre un panel con **Model** y **Reasoning Effort**. Pasá el mouse o hacé clic en **Model**: se abre una lista larga de modelos.
3. Bajá hasta el **final** de la lista y elegí **AURA**.
4. Escribí una pregunta que esté en tus documentos (ej. `¿Con cuántos días de anticipación hay que pedir las vacaciones?`) y apretá Enter.

✅ Al principio dice **Preparing response...** y **tarda cerca de 30 segundos** (es normal: está buscando en tus documentos). Después aparece la respuesta con una sección **Fuentes** que nombra el documento.

> Si el chat contesta con otro modelo, revisá que arriba a la derecha del cuadro de texto diga **AURA**.

---

## Apagar y prender

Siempre desde PowerShell abierto en la carpeta del proyecto:

```powershell
docker compose up -d
```
(enciende)

```powershell
docker compose down
```
(apaga, **no** borra nada)

🚫 **Nunca escribas** `docker compose down -v`: borra todo.

## Agregar o cambiar documentos

Cambialos en Drive y después en n8n corré de nuevo el flujo `3.1` (botón **Execute**).

## Si algo falla

| Qué pasa | Qué hacer |
|---|---|
| El chat dice "dificultad técnica" | Publicar `2.2` y `2.1` (paso 11) |
| No encuentra nada en Drive | Revisar que la carpeta esté compartida con el email del bot, y el número de carpeta |
| Un nodo está en rojo | Elegirle la clave (paso 10) |
| Error `type "vector"` | Repetir el paso 5 |
| Un tema no responde | Falta su carpeta con documentos en Drive, con el nombre exacto |
| No abre http://localhost:5678 | Abrir Docker Desktop y repetir `docker compose up -d` |

## Guardá siempre (en un lugar seguro, no en la nube pública)

El archivo `.env`, la carpeta `workflows` y el archivo JSON del bot de Google.

---

## Personalizar

- Los **sectores** son las subcarpetas de tu carpeta de Drive (`recursos_humanos`, etc.). Para agregar uno, creá una subcarpeta nueva con documentos y corré de nuevo el flujo `3.1`.
- El **prompt del flujo `2.1 Cerebro Orquestador`** decide a qué sector mandar cada pregunta. Hoy habla de los sectores del ejemplo (RRHH, desarrollo profesional, etc.): editalo para que coincida con los tuyos. Si agregás un sector, agregá también su herramienta "Agente …" en ese flujo.

## Seguridad (leer antes de usarlo fuera de tu PC)

- Todo está pensado para correr **solo en tu PC**: los puertos de n8n, LobeChat y el almacenamiento quedan abiertos únicamente en `127.0.0.1`. **No** los publiques en internet sin agregar contraseña, HTTPS y autenticación al webhook.
- El webhook del flujo `1. Entrada Lobe Chat _ Gradio` **no tiene autenticación**: cualquiera que llegue a tu n8n puede gastar tu cuota de Gemini. Si lo vas a exponer, agregale **Header Auth** al nodo `Webhook`.
- **Nunca subas** `.env`, el JSON de la cuenta de servicio de Google ni los backups de la base (el `.gitignore` ya los excluye, pero revisá antes de cada commit con `git status`).
- La cuenta de servicio de Google debe tener rol **Lector** y solo en la carpeta que compartís.
- Todo lo que pongas en la carpeta de Drive se manda a Gemini para generar respuestas y embeddings: **no cargues documentos que no puedas enviar a un tercero**.
- Cambiá las claves del `.env` si alguna vez las pegaste en un chat, un ticket o un video.
- Si encontrás un problema de seguridad en este proyecto, abrí un issue **sin incluir datos sensibles**.
