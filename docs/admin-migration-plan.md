# Engine editorial: edición en contexto y sistema de diseño compartido

Fecha de revisión: 22 de noviembre de 2026.

## Decisión y alcance

El sitio público será también el espacio principal de edición. Un visitante entra a `/projects` y ve proyectos publicados; un administrador entra a esa misma colección y dispone de crear, editar, previsualizar y publicar. El proyecto se edita sobre su presentación real: título, portada, resumen y secciones del caso. `/admin` conserva las tareas globales que requieren una vista de gestión.

La primera entrega funcional será **Projects de extremo a extremo**, con selección de portada y aparición en home. Después se extenderá el patrón a artículos y páginas. El objetivo deja de ser rediseñar primero todo `/admin`.

Este documento sustituye las decisiones anteriores de mantener un tema Tailwind exclusivo de admin y empezar por su dashboard/CRUD de páginas. Conserva el trabajo de dependencias y los pendientes de infraestructura descritos al final. Esta revisión modifica documentación; los modelos, rutas, generador de tokens y editor descritos aquí todavía deben implementarse.

### Qué significa engine en esta etapa

Un módulo editorial dentro de la aplicación Rails existente: modelos de dominio, servicios PORO, consultas, parciales ERB y controladores Stimulus pequeños. Mantener Rails MVC, Devise, Vite y CarrierWave. No extraer todavía una gema ni un `Rails::Engine` montable: primero comprobar el contrato con proyectos y después con un segundo tipo de contenido.

Una extracción posterior tendrá sentido cuando otro sitio necesite el mismo módulo. En ese punto se podrán aislar rutas, almacenamiento y adaptadores de diseño con contratos ya probados. Separarlo hoy obligaría a inventar una API de integración antes de conocer el flujo real.

## Experiencia que queremos entregar

1. El visitante abre `/projects`: colección de casos publicados, con sus portadas y enlaces individuales.
2. El administrador abre la misma URL: ve la misma colección, una barra editorial discreta, “Nuevo proyecto” y acceso a borradores. Los borradores aparecen en una zona identificada y exclusiva para administradores.
3. “Nuevo proyecto” abre la composición del proyecto con campos vacíos y espacios de portada. El GET no crea registros; “Crear borrador” persiste la identidad y lleva a su edición.
4. En el proyecto, “Editar” permite cambiar título y resumen en su lugar y abrir formularios acotados para cada sección. Los controles no sustituyen la página completa por un formulario de backoffice.
5. Al pulsar la portada, se puede elegir una imagen de la biblioteca o cargar otra. La selección aparece inmediatamente en la composición; se distinguen carga local, procesamiento y guardado confirmado.
6. “Mostrar en home” y una posición numérica permiten configurar su tarjeta en la sección de proyectos destacados. Un enlace abre la previsualización privada de home con ese borrador.
7. “Guardar borrador” conserva cambios sin alterar lo que ve el visitante. “Publicar” actualiza juntos la ficha, la tarjeta del índice y su presencia en home.
8. “Ver como visitante” oculta las herramientas y muestra el borrador con el mismo renderer. “Ver publicado” abre la versión que realmente está en línea. Ambas acciones tienen nombres distintos para evitar confundir preview con publicación.

En móvil, la barra editorial tendrá acciones esenciales y el inspector de portada/metadatos usará un diálogo o panel. Debe poder operarse por teclado, sin depender del hover ni de arrastrar elementos.

### Reparto de responsabilidades

| Espacio | Trabajo |
| --- | --- |
| `/projects` y ficha del proyecto | Crear, editar contenido, portada, preview, publicación y selección para home |
| `/` | Mostrar proyectos destacados publicados; para admin, enlazar a su edición y previsualizar la selección pendiente |
| `/blog` y artículo, en una fase posterior | Aplicar el mismo patrón de lectura y edición editorial |
| `/admin` | Biblioteca multimedia completa, usuarios/permisos cuando se implementen, inventarios, búsquedas globales, archivo y operaciones por lotes |
| Repositorio | Tokens, reglas de diseño, componentes y despliegue; no exponer un editor de CSS/Tailwind al usuario editorial |

## Diagnóstico comprobado en el repositorio

| Área | Situación actual | Consecuencia para el plan |
| --- | --- | --- |
| Proyectos | No hay modelo ni rutas `projects`; los casos están en un arreglo Ruby dentro de `app/views/pages/portfolio.html.erb` | Crear dominio explícito e importación revisable desde el portafolio |
| Home | `StaticController#home` renderiza una vista estática | Conectar una consulta de destacados; conservar el resto de su composición |
| Páginas | `Page` mezcla contenido, categoría, idioma, OG, bloques y relaciones de traducción | Conservar sus consumidores; no convertir categorías libres en una jerarquía nueva de contenido |
| Blog | Existen `/:lang/blog` y `/:lang/blog/:id`; `show` no carga un artículo | Blog necesita un contrato de contenido y migración propios; no asumir que ya funciona |
| Publicación | No hay borrador ni puntero a una versión publicada en `Page` | Diseñar publicación antes de habilitar escrituras desde el frontend |
| Bloques | `Block` pertenece a `Page`, con categorías `text/css/js/html/glsl` | No reutilizarlo como bloques de proyectos: mezcla contenido y código ejecutable |
| Permisos | Devise y `User#admin?`; autenticación repetida en controladores admin | Centralizar autorización y usarla también en editor, previews y multimedia |
| Diseño | Ya existe `DESIGN.md` con front matter de tokens; Tailwind vuelve a declararlos en `application.tailwind.css` | Evitar dos fuentes manuales de valores |
| Desajustes visuales | `typography.xl/2xl/3xl` declara 32/48/64 px en `DESIGN.md`; CSS declara 24/32/48 px | Resolver la escala explícitamente antes de generar tokens; el cambio requiere revisión visual |
| CSS global | Reglas sobre `h1`, `p`, `a`, labels e inputs; algunas fuerzan tamaños o colores oscuros | Acotar tipografía editorial y controles para que paneles y contenido convivan |
| Admin anterior | AdminLTE, Bootstrap, jQuery y Selectize en layout separado | Mantenerlo temporalmente por recurso; nuevos controles usan el sistema compartido |
| JS público | El entrypoint usa `window.onload`, recarga en `popstate` y llama `this.lenis.raf` sin inicializar Lenis | Corregir ciclo de vida antes de introducir navegación Turbo en las vistas nuevas |
| Multimedia | `Image`/CarrierWave existentes; uploader usa rutas públicas y nombres derivados del slug | Reutilizar procesamiento, pero resolver privacidad y colisiones antes de permitir portadas de borradores |
| Escrituras anteriores | Strong parameters de páginas no cubren OG/bloques; update de multimedia incompleto | Reparar los recursos que se reutilicen sin bloquear Projects por todo el CRUD anterior |
| Entorno/pruebas | El registro del 21 de noviembre documenta falta de `test_helper` y PostgreSQL inaccesible | Recuperar esa base y volver a verificar; no asumir que las validaciones anteriores cubren este editor |

## Modelo de contenido y publicación

### Projects como casos de estudio

Crear `Project` independiente de `Page`, sin STI ni modelo universal `Content`. Una ficha de proyecto tiene estructura propia: problema/objetivo, solución, participación, colaboración y resultado. Reutilizar presentación y mecanismos editoriales, sin obligar a que un artículo tenga campos de caso de estudio.

| Modelo | Datos propuestos |
| --- | --- |
| `Project` | UUID, `slug`, `lang`, `author_id`, `published_revision_id` opcional, `archived_at`, timestamps y `lock_version` |
| `ProjectRevision` | `project_id`, estado `draft/published`, título, resumen, `cover_image_id`, alt de portada, punto focal, secciones del caso, enlaces/créditos, SEO/OG, `featured_on_home`, `home_position`, autor de cambios, timestamps y `lock_version` |
| `Image` existente | Archivo, dimensiones y metadatos técnicos; ampliar almacenamiento/estado de procesamiento solo donde lo requiera el flujo |

Usar columnas para campos que se validan, filtran u ordenan: título, resumen, portada, selección/posición en home. Usar JSONB para el documento acotado de secciones y enlaces; definir claves, longitudes y formato permitidos en un PORO de validación. No aceptar HTML arbitrario, clases Tailwind, JavaScript ni estructuras de layout desde ese JSON.

La primera versión edita texto y párrafos estructurados. Si después hace falta texto enriquecido, elegir un formato y sanitizador con una migración específica; no introducir un editor de páginas libre como requisito del MVP. `Block` y el contenido anterior de `Page` no cambian de formato durante esta entrega.

### Reglas de publicación

- Una identidad `Project` tiene como máximo una revisión `draft` mutable y un puntero a su revisión publicada. Una revisión publicada es inmutable; al comenzar una nueva edición se copia a un borrador.
- Añadir índice único parcial por `project_id` para la revisión en estado draft, índice único de `(lang, slug)`, claves foráneas y validaciones de pertenencia: el puntero publicado debe referirse a una revisión publicada del mismo proyecto.
- `Projects::SaveDraft` guarda únicamente el borrador. `Projects::Publish` valida campos, portada disponible y versión esperada; bajo bloqueo del proyecto marca la revisión como publicada y cambia el puntero en una transacción.
- Publicar exige un borrador guardado y la versión exacta que se previsualizó. Si hay cambios locales o una carga en curso, se debe guardar primero; un conflicto devuelve 409 con opción de recargar o recuperar cambios. No reintentar a ciegas.
- La colección pública, la ficha, OG, sitemap y home consultan exclusivamente el puntero publicado de proyectos no archivados. Un borrador nunca se obtiene con un `Project.all` público.
- `slug` e idioma pertenecen a la identidad y quedan fijos tras la primera publicación en el MVP. Una edición ordinaria del título no cambia la URL. Renombrar URLs y gestionar redirects será una operación posterior explícita.
- Archivar oculta el proyecto del índice, home y ficha pública; preserva revisiones y medios. No ofrecer eliminación destructiva en la primera versión.
- Los borradores pueden estar incompletos. Publicar requiere título, resumen, caso con contenido y portada con alt; no usar las mismas validaciones de completitud para ambos estados.

El coste de dos tablas es mayor que un booleano `published`, pero resuelve un requisito concreto: editar un proyecto ya publicado sin filtrar cambios a visitantes. No se incluye historial navegable, comparación de versiones ni restauración en el MVP.

### Home como selección, no como copia de contenido

`featured_on_home` y `home_position` viven en la revisión. Publicarlos actualiza la selección sin duplicar título, resumen o portada en un modelo `HomeProject`.

`Home::FeaturedProjectsQuery` une proyectos activos con su revisión publicada, filtra destacados, ordena por posición y un desempate estable, limita resultados y precarga portadas. La primera sección tendrá un límite explícito de seis tarjetas; ampliar ese límite será una decisión de composición. El control de posición es numérico en el MVP.

La preview de home sustituye en memoria únicamente la revisión del proyecto actual por su borrador; mantiene publicados los demás. Si se desmarca “Mostrar en home”, debe desaparecer también de esa previsualización. Una selección en borrador nunca altera el home público.

Más adelante, si home necesita mezclar artículos, proyectos y otros módulos en un orden único, introducir `HomePlacement` con slots tipados. No añadir esa relación polimórfica para resolver solo una colección de proyectos.

## Rutas, permisos y respuestas

| Método y URL propuesta | Contrato |
| --- | --- |
| `GET /projects` | Listado público; herramientas y acceso a borradores según permisos |
| `GET /projects/new` | Composición para crear; requiere admin; ruta anterior a `:slug` |
| `GET /projects/:slug` | Revisión publicada; 404 si no existe una versión pública |
| `GET /projects/:slug/edit` | Mismo layout/composición con borrador e inspector; requiere admin |
| `GET /projects/:slug/preview` | Borrador sin herramientas; privado y requiere admin |
| `GET /editor/home-preview?project_id=…` | Home con sustitución del borrador autorizado; privado |
| `POST /editor/projects` | Crear identidad y primer borrador |
| `PATCH /editor/projects/:project_id/draft` | Guardar borrador con versión esperada |
| `POST /editor/projects/:project_id/publication` | Publicar versión guardada con versión esperada |
| `PATCH /editor/projects/:project_id/archive` | Archivar o restaurar con autorización y versión esperada |
| `POST /editor/images` | Cargar imagen mediante el servicio de medios |
| `GET /editor/images/:id/preview` | Servir un medio privado autorizado antes de publicarlo |

Las rutas editoriales usan UUID; las públicas resuelven por `(lang, slug)`. `/projects` será la URL canónica en español; reservar `/en/projects` y `/en/projects/:slug` para traducciones existentes, sin duplicar español en `/es/projects`. Mantener las URLs previas del blog durante su migración. Declarar rutas explícitas antes de `/:lang` y de los comodines actuales. El segmento `new` queda reservado y no puede usarse como slug.

`ProjectsController#index/show` permanece público. `new/edit/preview` y todo `Editor::BaseController` requieren sesión y autorización centralizada en `EditorialPolicy`, basada inicialmente en `current_user.admin?` y `!current_user.banned?`. El admin anterior también deberá adoptar esa comprobación. No añadir roles editoriales que aún no se necesitan.

Ocultar botones es solo presentación: comprobar permisos en cada lectura privada y POST/PATCH/DELETE, con strong parameters distintos para contenido y operaciones de publicación. El servidor no acepta `published_revision_id`, autor, estado ni rol desde el formulario de contenido. Acceso anónimo a herramientas pide login; usuario sin permiso recibe 403. Un recurso no publicado en una ruta pública responde 404.

Usar formularios Rails con CSRF y fallback HTML. Errores de validación devuelven 422 conservando los valores y la referencia temporal del archivo; conflictos de versión devuelven 409. Navegaciones exitosas tras escritura usan 303. Los Turbo Frames se incorporan después de que el mismo flujo funcione como formulario normal.

Toda respuesta con herramientas, borradores o previews usa `Cache-Control: private, no-store`; previews/edición incorporan `noindex`. No cachear un fragmento que mezcle contenido público y controles privados. Cuando haya caché pública, incluir la revisión publicada en la clave e invalidar también la colección/home al publicar o archivar. La preview no genera visitas ni eventos públicos de analítica.

## Arquitectura Rails propuesta

```text
app/models/
  project.rb
  project_revision.rb
app/policies/
  editorial_policy.rb
app/services/projects/
  create_draft.rb
  save_draft.rb
  publish.rb
  archive.rb
app/services/media/
  upload_image.rb
app/services/portfolio/
  import.rb
app/queries/projects/
  published_query.rb
app/queries/home/
  featured_projects_query.rb
app/forms/projects/
  revision_content.rb             # PORO: estructura y validación del documento
app/controllers/
  projects_controller.rb
  editor/base_controller.rb
  editor/projects_controller.rb
  editor/drafts_controller.rb
  editor/publications_controller.rb
  editor/archives_controller.rb
  editor/home_previews_controller.rb
  editor/images_controller.rb
  admin/base_controller.rb
app/views/
  projects/                       # index, show, new/edit y composición compartida
  projects/shared/                # portada, encabezado, caso, tarjeta
  editor/shared/                  # barra, estados, errores e inspector
  editor/projects/                # formularios pequeños, sin otra ficha visual
  shared/ui/                      # botones, campos, diálogo y feedback
app/helpers/
  editorial_helper.rb
app/javascript/
  entrypoints/application.js
  entrypoints/editor.js           # cargar solo para sesiones autorizadas
  editor/controllers/             # campo, portada, inspector, estado pendiente
app/assets/stylesheets/
  application.tailwind.css        # único entrypoint del sistema nuevo
  design-system/tokens.css        # generado; valores del front matter de DESIGN.md
  design-system/theme.css         # configuración Tailwind y aliases semánticos
  design-system/components.css    # controles y patrones compartidos
  editorial/controls.css          # reglas acotadas al contenedor del editor
script/
  export_design_tokens.rb
```

Los servicios coordinan transacciones, concurrencia y archivos; las consultas concentran listados y precargas. No crear un servicio por cada lectura ni una jerarquía genérica para todos los contenidos. Los controladores resuelven HTTP y los parámetros; el renderer recibe explícitamente una revisión, publicada o borrador autorizado.

### Composición y preview

Una sola familia de parciales renderiza proyecto y tarjeta tanto en público como en edición y preview. Las herramientas se agregan alrededor de regiones con claves estables; el formulario de una región no envuelve otros formularios. El servidor vuelve a renderizar la región guardada con sus valores normalizados.

Usar inputs/textarea reales que hereden tipografía y anchura de la región, con labels accesibles. Evitar un `contenteditable` general sobre todo el documento: complica serialización, pegado y recuperación de errores. Stimulus actualiza texto local mediante `textContent` y portada mediante object URL; la respuesta Rails confirma el resultado persistido. La preview de texto enriquecido, si llega después, deberá sanitizarse también en el servidor.

La v1 usa guardado explícito, feedback “Cambios sin guardar / Guardando / Guardado / Error” y advertencia al abandonar con cambios. El autoguardado queda para una entrega posterior con serialización de peticiones, control de versiones y recuperación de errores; no es necesario para ver inmediatamente la composición.

Corregir el ciclo de vida público antes de activar Turbo: montar/desmontar desde Stimulus, liberar listeners, editores y object URLs; evitar dobles montajes y capturas de formularios con datos privados en el caché de navegación. Las experiencias Three.js, laboratorio y canvas conservan navegación completa hasta tener ese ciclo comprobado.

### Portadas y biblioteca

Conservar CarrierWave y el modelo `Image` para evitar una migración simultánea a otro almacenamiento. `Media::UploadImage` coordina validación de MIME/tamaño/dimensiones, procesamiento, metadatos y persistencia. La imagen se guarda con identificador de almacenamiento único, sin depender de un slug editable ni sobrescribir archivos existentes.

Una selección de archivo produce preview local inmediata y queda marcada como pendiente. El servidor devuelve un recurso válido solo tras completar el procesamiento; no mostrar “Guardado” por haber creado una object URL. Para la v1, procesar imágenes acotadas de forma síncrona con límites claros y errores recuperables. El procesamiento en cola requiere después un backend desplegado y estados persistidos.

Alt y punto focal de la portada pertenecen a su uso en la revisión. El recorte usa `object-position` y proporciones de tarjeta/hero definidas por diseño; no crear variantes infinitas ni copiar binarios por cada edición. Mostrar la tarjeta y el hero al elegir portada permite revisar ambos recortes.

Las imágenes nuevas de borradores deben almacenarse fuera de rutas públicas y servirse mediante una acción autorizada. Al publicar se genera la copia/variante pública con nombre inmutable; si eso falla no se cambia el puntero publicado. Los archivos privados no entran en sitemaps ni endpoints de biblioteca públicos. Mantener accesibles las rutas de imágenes ya públicas y tratarlas como material publicado.

Reemplazar una portada crea otro recurso; nunca modifica el archivo que usa una revisión publicada. Bloquear eliminación de medios referenciados. Las transacciones SQL no revierten archivos: limpiar cargas fallidas y temporales con un proceso explícito que compruebe referencias antes de borrar. El selector de biblioteca muestra solo archivos disponibles para el administrador y conserva selección ante errores del formulario.

## Sistema de diseño: un contrato para público, editor y admin

### Fuentes y generación

Usar el archivo existente [`DESIGN.md`](../DESIGN.md), respetando sus mayúsculas. Será el contrato humano de identidad, jerarquía, comportamiento y accesibilidad, y su front matter la única fuente manual de valores de tokens.

```text
DESIGN.md: front matter de tokens + reglas de uso
    -> script/export_design_tokens.rb
    -> design-system/tokens.css (generado, versionado, sin edición manual)
    -> design-system/theme.css (mapeo/configuración de Tailwind)
    -> application.tailwind.css
    -> application.css: sitio público + editor + admin migrado
```

Mantener la configuración CSS de Tailwind 4 que ya usa el repositorio; no introducir `tailwind.config.js` como segunda fuente. `theme.css` define aliases semánticos mediante variables, fuentes de clases y la integración con Tailwind; no repite los valores del documento. La configuración compartida satisface el mismo objetivo que un archivo JS de configuración, conservando el enfoque actual del proyecto.

Implementar un exportador pequeño y determinista en Ruby: lectura segura del front matter, secciones de tokens admitidas, resolución de referencias conocidas y fallo por claves no soportadas o referencias inválidas. Sin conversión de prosa a CSS ni ejecución de expresiones del documento. La herramienta `@google/design.md` ya instalada puede seguir aportando lint si resulta útil, pero la generación del contrato no dependerá de ella; el registro anterior documenta avisos de seguridad en esa dependencia de desarrollo.

Definir `design:tokens` para generar el archivo, `design:check` para comparar sin escribir y `build:css` para generar antes de compilar. CI falla si la salida versionada no coincide. Reemplazar las declaraciones duplicadas actuales solo tras revisar diferencias; no exportar silenciosamente una escala distinta a producción. `design:lint` y `design:check` cubren cosas diferentes: documento válido y salida sincronizada.

### Primitivas, roles y componentes

- Primitivas: paleta, fuentes, escalas, espaciado, radios, duraciones y capas. Respetar el esquema actual del documento y extenderlo únicamente con un cambio del exportador.
- Roles semánticos: `canvas`, `surface`, `text`, `muted`, `border`, `accent`, `focus`, `danger` y `success`, con modo claro/oscuro. El editor usa los mismos roles que el público; un cambio de marca se propaga a ambos.
- Patrones compartidos: botón, campo, label, errores, tarjeta, diálogo y estados de publicación. Definir jerarquía, tamaños, estados disabled/loading/error y foco en `DESIGN.md` antes de copiarlos a varias vistas.
- Alcances de composición: el contenido puede tener titulares grandes y espacios amplios; barras, diálogos e inspectores usan una escala de controles. Es la misma tipografía y paleta con roles distintos, sin heredar un `h2` gigante por ser global.
- Densidad editorial y orden de capas documentados para barra fija, panel y diálogo. La interfaz no tapa el campo activo ni desplaza el contenido inesperadamente al entrar en edición.

Cargar un solo CSS nuevo con Preflight y plugins una vez. Usar fuentes de clases explícitas para vistas, helpers y JS propios; excluir `ui-kit/` y dependencias. Los nombres de clases son estáticos y se eligen de mapas cerrados, no de contenido de base de datos.

Catalyst queda como referencia de patrones o fuente de un componente concreto, adaptado a nuestros tokens. No impone su tema al frontend ni obliga a incorporar React. ERB + Stimulus y diálogo nativo cubren la v1; una isla React solo se justifica por una interacción que lo necesite. Copiar únicamente piezas usadas a una carpeta versionada, respetando licencia/procedencia; no depender del kit local ignorado.

El admin anterior conserva temporalmente su layout y assets. Cada recurso que migre pasa al CSS compartido y deja de cargar Bootstrap/AdminLTE. No cargar ambos sistemas en el mismo documento. El futuro layout de admin puede conservar sidebar, pero consume los mismos tokens y controles del sitio.

### Cómo se actualiza el diseño

1. Modificar valores o reglas en `DESIGN.md`, indicando el rol afectado y revisando contraste.
2. Ejecutar generación y compilación; revisar el diff de tokens, sin editar el CSS generado.
3. Si cambia estructura o comportamiento, ajustar el parcial/Stimulus compartido y su documentación. Los tokens cambian valores; no reemplazan la implementación de componentes.
4. Revisar una muestra mínima: índice público, proyecto, editor, home y un recurso admin migrado, en claro/oscuro, 375 px y escritorio.
5. Aceptar el cambio con tokens y componentes en el mismo commit cuando sean dependientes. Mantener las excepciones creativas de WebGL/canvas localizadas y documentadas.

## Entregas y criterios de aceptación

### 0. Base reproducible y contratos de diseño

Recuperar `test/test_helper.rb`, revisar los tests actuales y asegurar PostgreSQL de pruebas. Confirmar Ruby/Node, lockfiles y el archivo de arranque real; el plan anterior registraba una eliminación pendiente de `Procfile.dev`, que debe comprobarse de nuevo. Normalizar directorios `Admin/Users` cuando se toquen y crear bases de autenticación sin modificar todas las pantallas a la vez.

Inventariar diferencias entre `DESIGN.md`, `@theme` y estilos globales; resolver la escala tipográfica y crear exportador, configuración compartida y controles mínimos. Corregir el arranque JS público y usar navegación completa mientras se prueba Turbo.

**Aceptación:** instalación y arranque reproducibles; `zeitwerk:check`, compilación y pruebas de sesión/autorización ejecutables; generación determinista y `design:check` correcto. Una muestra de controles comparte tokens con una ficha pública sin afectar laboratorio ni estilos anteriores. Registrar limitaciones reales del entorno.

### 1. Projects público y contenido real

Crear tablas, relaciones, validaciones por estado e índices. Implementar listado/ficha de revisiones publicadas y tarjeta compartida. Mantener `/portfolio` durante la transición.

Extraer el arreglo actual del portafolio a datos revisables e importar mediante `Portfolio::Import` idempotente por `(lang, slug)`, con dry-run y reporte. Convertir títulos con `<br>/<small>` en texto y campos estructurados; reemplazar enlaces HTML de `link_to` por etiqueta/URL validadas. Normalizar rutas relativas de portada a rutas absolutas o recursos importados. No ejecutar ni volcar el ERB como contenido confiable.

Los casos importados nacen como borradores para revisar texto, portada y alt. No publicar automáticamente casos sin portada o con fallback. Conservar IDs de anclas existentes; después de validar equivalencia, `/portfolio` podrá redirigir a `/projects` y el índice conservará esas anclas. Los fragmentos de URL no llegan al servidor: no prometer redirects por fragmento hacia fichas individuales.

**Aceptación:** visitante solo ve casos publicados; ficha y OG correctos; slugs e idioma resueltos sin colisión con `/:lang`; repetir importación no duplica ni pisa cambios editoriales; consultas paginadas y portadas precargadas, sin N+1.

### 2. Primera entrega editorial completa

Implementar barra, creación de borrador, formularios de título/resumen/secciones, guardado, preview y publicación. Añadir carga/selección de portada con privacidad, alt y punto focal. Incorporar `featured_on_home`, posición y preview privada de home. Conectar la sección de destacados publicada.

**Aceptación:** desde `/projects`, un admin crea un caso, carga portada y la ve inmediatamente, guarda borrador, revisa ficha/tarjeta/home y publica sin pasar por `/admin`. En otra sesión, el visitante ve solo la versión anterior hasta publicar. Cambiar o quitar portada en borrador no altera la publicada. Fallos de validación, procesamiento y concurrencia preservan trabajo y no publican parcialmente. No hay controles ni medios privados filtrados por caché, URLs o Turbo.

Esta entrega es el primer win del producto y tiene prioridad sobre un rediseño completo del dashboard.

### 3. Consolidación de /admin y multimedia

Migrar biblioteca multimedia e inventarios al sistema visual compartido. Completar los endpoints anteriores que realmente se conservan y centralizar servicios de carga. El índice global debe enlazar a la edición contextual de Projects, sin introducir otro formulario con reglas diferentes.

Paginar índices con orden estable, filtros GET y búsquedas parametrizadas. Sustituir `Page.all`/`total_views` por listados acotados y agregados SQL; para visitas, agrupar solo los IDs mostrados. Retirar enlaces de países o blog admin hasta tener acciones implementadas. No inventar dashboard de ventas ni métricas sin fuente.

**Aceptación:** inventario y multimedia usan datos reales y los mismos controles; carga/edición/eliminación respetan referencias; navegación móvil y teclado correctos; ninguna pantalla nueva mezcla resets de Bootstrap y Tailwind.

### 4. Artículos, blog y páginas

Definir `Article` como entidad editorial y `/blog` como su colección, no como un tipo de artículo. Reutilizar renderer/editor donde exista una necesidad comprobada, manteniendo campos y publicación explícitos. Un segundo tipo permite evaluar qué piezas merecen extraerse del módulo Projects.

Inventariar categorías e idiomas reales de `Page` antes de mapear datos. Conservar IDs/referencias existentes o mantener una tabla de correspondencias y redirects para `/:lang/blog/:id`; no borrar ni reinterpretar `Page` por una etiqueta de categoría. Preservar formato almacenado hasta una migración revisada.

Para páginas estáticas, empezar con plantillas registradas y campos editables definidos por plantilla. Home permite curar contenido; no se convierte en un constructor libre de CSS, bloques ejecutables o rutas arbitrarias.

**Aceptación:** blog/artículo se entienden como colección/ficha; permisos, preview y publicación equivalentes; URLs anteriores resuelven; restricciones de páginas protegidas también se aplican en el servidor. La extracción de código compartido responde a dos flujos reales.

### 5. Retirada del legado y ampliaciones justificadas

Retirar jQuery, AdminLTE, Bootstrap, Selectize, UJS y `/static/admin.*` solo cuando no queden consumidores. Migrar logout GET a botón DELETE con CSRF actualizando ruta y vistas en conjunto. Eliminar duplicados de tipografía y tokens después de verificar todo el sitio.

Mantener separadas las migraciones mayores de Ruby, Three.js, Fontkit, CarrierWave y nuevos defaults Rails. CarrierWave 3 requiere resolver antes la restricción de `carrierwave-imageoptimizer`; los cambios de Three.js deben revisar shaders, imports y `FilmPass`. No mezclar esas actualizaciones con la primera experiencia editorial.

Autoguardado, comparación/restauración de versiones, programación de publicación, roles adicionales, home con slots mixtos y extracción a `Rails::Engine` quedan fuera del MVP. Cada uno necesita una necesidad y criterios propios.

## Riesgos, validación y reversión

| Riesgo | Decisión y verificación |
| --- | --- |
| Edición que modifica la versión pública | Revisión publicada inmutable; prueba con dos sesiones antes/después de publicar |
| Borradores o herramientas filtrados | Scopes publicados, autorización por request, medios privados, `no-store` y prueba de caché |
| Cambios concurrentes perdidos | Lock optimista en borrador y bloqueo al publicar; prueba de dos pestañas y respuesta 409 |
| Publicación parcial de ficha/home/medios | Preparar medios antes de cambiar el puntero; fallo de procesamiento conserva versión pública anterior |
| Deriva de diseño | Tokens generados desde una sola fuente y comparación en CI; revisión visual para reglas estructurales |
| CSS global que rompe inspectores o pantallas | Roles tipográficos y estilos acotados; recorrido público/editor/admin, claro/oscuro y móvil |
| Importación que altera casos o URLs | Dry-run idempotente, borradores revisables, respaldo y conservación de anclas/rutas previas |
| Coste de versiones e imágenes | Un borrador activo, referencias a medios y limpieza controlada; historial UI y variantes adicionales fuera del MVP |

Las pruebas necesarias cubren permisos, visibilidad, publicación atómica, concurrencia, importación y medios; evitar tests que solo repitan clases CSS. Añadir un recorrido de sistema para crear → portada → guardar → preview → publicar → home, y comprobar errores sin pérdida de datos. La compilación por sí sola no valida el editor.

Desplegar esquema aditivo antes de habilitar rutas. Mantener Projects y la sección nueva de home tras una bandera editorial del servidor durante el rollout; conservar `/portfolio`, tablas y archivos previos. La reversión desactiva herramientas y sección nueva sin borrar revisiones ni medios. Hacer respaldo de base y archivos antes de importar o cambiar almacenamiento. No aplicar migraciones destructivas en las primeras entregas.

## Validación de esta revisión documental

- `git diff --check`: correcto.
- Enlaces locales y delimitadores de bloques de código de este plan, `DESIGN.md` y `README.md`: correctos.
- `npm run design:lint`: cero errores; permanecen los 17 avisos de tokens sin referencias ya registrados en la revisión anterior.
- No se modificaron código de aplicación, dependencias ni esquema. Los flujos y criterios de aceptación propuestos no se han implementado ni probado de extremo a extremo.

## Registro histórico: dependencias y validación del 21 de noviembre

Los resultados siguientes pertenecen a la actualización anterior. No son verificaciones de la arquitectura ni de la interfaz propuestas en esta revisión.


La entrega anterior aplicó actualizaciones de dependencias y documentó sus validaciones. La edición contextual y la sustitución visual de `/admin` siguen pendientes.

| Dependencia | Antes | Ahora |
| --- | --- | --- |
| Rails | 8.1.3.1 | 8.1.4.1 |
| Turbo Rails / JavaScript | 2.0.12 / 7.3.0 | 2.0.23 / 8.0.23 |
| Stimulus JavaScript | Dependencia directa ausente | 3.2.2 |
| Tailwind / CLI | 4.3.3 | 4.3.5 |
| Vite / plugin Ruby | 8.3.0 / 5.2.4 | 8.3.8 / 5.2.6 |
| vite_ruby | 3.11.0 | 3.11.1 |
| GSAP / Lenis | 3.15.0 / 1.3.26 | 3.15.1 / 1.3.27 |
| RMagick / MiniMagick | 5.3.0 / 5.3.1 | 5.5.0 / 5.4.0 |
| JSON / PG | 2.6.3 / 1.6.3 | 2.21.2 / 1.7.0 |
| Sentry Rails / Ruby | 6.6.2 | 6.7.0 |

También se actualizaron dependencias transitivas con Bundler y npm. El mínimo de `vite-plugin-ruby` en el manifiesto se elevó junto a la gema: Vite Ruby comprueba ese rango al arrancar. Se mantuvo Bundler 2.7.1, que ya es el indicado en el lockfile; no se instalaron herramientas globales.

Three.js 0.155 y Fontkit 2 permanecen en su línea actual hasta ejecutar sus migraciones visuales. CarrierWave continúa en 2.2.7 por la restricción de `carrierwave-imageoptimizer`. `json < 3` y Puma 6 conservan sus límites; sus saltos mayores requieren validación separada.

Validaciones realizadas con Node 22.18.0 y Ruby 3.2.3:

- `bundle check`: correcto.
- `bin/rails zeitwerk:check`: correcto después de alinear Vite Ruby y su plugin.
- `npm run build:css` y `vite build`: correctos. Persiste el aviso previo sobre el bundle de errores de aproximadamente 901 kB.
- Escritura de un PNG con RMagick y lectura con MiniMagick: correcta.
- `npm run design:lint`: sin errores; 17 avisos de tokens sin referencias en el documento existente.
- `npm audit --omit=dev`: cero vulnerabilidades reportadas.
- Auditoría completa: dos avisos altos, correspondientes a Zod y a su consumidor de desarrollo `@google/design.md`. npm no ofrece arreglo compatible. No se impuso Zod 4 sobre una herramienta que depende de Zod 3; evaluar una versión corregida o sustituir la herramienta. [Aviso de Zod](https://github.com/advisories/GHSA-mrhx-c7xc-m3w5).
- Se añadió un override acotado para que Tailwind Typography use `postcss-selector-parser` 6.1.6, corrigiendo su aviso moderado sin cambiar de versión mayor. Retirar el override cuando Typography incluya una dependencia corregida. [Aviso de PostCSS](https://github.com/advisories/GHSA-rj75-hqrm-r3gf).
- La suite existente no arranca porque falta `test_helper`; esa carencia se comprobó antes de actualizar.
- Una petición a `/admin` devuelve 500 por `ActiveRecord::ConnectionNotEstablished` / `PG::ConnectionBad` en este entorno. La misma petición con los manifiestos y lockfiles anteriores también devuelve 500. Se necesita acceso a PostgreSQL para validar login, permisos y CRUD; no se verificó el administrador de extremo a extremo.

## Referencias del plan

- [Contrato de diseño del repositorio](../DESIGN.md).
- [Portafolio actual a migrar](../app/views/pages/portfolio.html.erb).
- [Configuración Tailwind actual](../app/assets/stylesheets/application.tailwind.css).
- [Rutas existentes](../config/routes.rb).
- [Esquema actual](../db/schema.rb).
