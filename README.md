# AURA RAG

**Un chat que responde con tus propios documentos de Google Drive, y te dice de qué documento sacó cada respuesta.**
Corre en tu PC con Docker: n8n + Postgres (pgvector) + LobeChat + Gemini.

> 👉 **[Empezar: guía paso a paso](GUIA.md)** (pensada para seguirla sin conocimientos técnicos)

---

## ¿Qué hace?

Le hacés una pregunta al chat ("¿con cuántos días de anticipación se piden las vacaciones?") y responde usando **solo** los PDF y Google Docs que pusiste en una carpeta de Drive, citando los documentos usados:

```
Pregunta → LobeChat → n8n → agente que elige el sector → búsqueda en tus documentos → respuesta + Fuentes
```

## Ventajas

- **Responde con tus documentos, no inventa.** Si no encuentra la información, lo dice. Siempre cita la fuente.
- **Organizado por sectores.** Cada subcarpeta de Drive es un sector (RRHH, desarrollo, etc.) y un agente decide a cuál mandar cada pregunta.
- **Se mantiene al día solo.** Un flujo diario detecta documentos nuevos, modificados o borrados y actualiza la base.
- **Drive en solo lectura.** Accede con una cuenta de servicio con rol *Lector*, solo a la carpeta que le compartas.
- **Tus datos viven en tu PC.** La base de datos, los flujos y el chat corren en tu máquina. *(Los textos que consultás sí se envían a la API de Gemini; ver Seguridad.)*
- **Se configura sin programar.** Los flujos son visuales (n8n) y todo se levanta con un solo comando de Docker.

## Qué necesitás

- Una PC con Windows y [Docker Desktop](https://www.docker.com/products/docker-desktop).
- Una cuenta de Google (para Drive y para la clave de Gemini).
- Unos 30 minutos siguiendo la [guía](GUIA.md).

## Limitaciones

- Lee **PDF y Google Docs** (otros formatos no se procesan).
- Cada respuesta tarda cerca de **30 segundos**.
- La guía está en español y para Windows; n8n y LobeChat se usan en su interfaz en inglés.
- Los sectores y el prompt del orquestador son un ejemplo: hay que adaptarlos a tu caso (ver [Personalizar](GUIA.md#personalizar)).

---

## Seguridad

Pensado para correr **solo en tu PC**. Antes de usarlo en otro lado, tené en cuenta:

- Los puertos de n8n, LobeChat y el almacenamiento quedan abiertos únicamente en `127.0.0.1`. **No los publiques en internet** sin agregar contraseña, HTTPS y autenticación al webhook.
- El webhook de entrada **no tiene autenticación**: quien llegue a tu n8n puede gastar tu cuota de Gemini. Si lo exponés, agregale *Header Auth* al nodo `Webhook`.
- **Nunca subas** el `.env` ni el JSON de la cuenta de servicio de Google (el `.gitignore` ya los excluye; revisá con `git status` antes de cada commit).
- Todo lo que pongas en Drive se envía a Gemini para generar embeddings y respuestas: **no cargues documentos que no puedas mandar a un tercero.**
- Si pegaste una clave en un chat, un ticket o un video, cambiala.

## Licencia

Los archivos de este repositorio (flujos, `docker-compose.yml`, guía) se publican bajo la **[PolyForm Noncommercial 1.0.0](LICENSE)**: podés usarlos, copiarlos y modificarlos para **uso personal, educativo o sin fines comerciales**. Para otros usos, consultá con el autor.

Este repositorio **no incluye** el código de n8n ni de LobeChat: el `docker-compose.yml` descarga sus imágenes oficiales. Cada componente conserva su propia licencia, que **debés respetar vos** al usarlo:

| Componente | Licencia | Qué tener en cuenta |
|---|---|---|
| [n8n](https://github.com/n8n-io/n8n/blob/HEAD/LICENSE.md) | Sustainable Use License | Uso interno de negocio, no comercial o personal. No se puede ofrecer n8n a terceros como servicio. |
| [LobeChat](https://github.com/lobehub/lobehub/blob/HEAD/LICENSE) | LobeHub Community License (Apache 2.0 + condiciones) | Uso comercial permitido sin modificar el código; derivar y distribuir una versión modificada requiere licencia comercial. |
| [ParadeDB](https://github.com/paradedb/paradedb/blob/HEAD/LICENSE) | AGPL-3.0 | Imagen usada sin modificar. |
| [RustFS](https://github.com/rustfs/rustfs/blob/HEAD/LICENSE) | Apache 2.0 | — |
| [pgvector](https://github.com/pgvector/pgvector/blob/HEAD/LICENSE) | Licencia de PostgreSQL | — |
| Redis, AWS CLI | Licencias propias | Consultá la de la versión que uses. |
| API de Gemini | [Términos de Google](https://ai.google.dev/gemini-api/terms) | — |

Esto es un resumen informativo, no asesoramiento legal.
