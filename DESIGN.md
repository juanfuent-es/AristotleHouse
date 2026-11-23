---
name: "Psychedelic Glitch — WebCraft" #[cite: 4]
version: "beta"
colors:
  primary: "#DF00FF"
  primary-light: "#A600DD"
  primary-dark: "#DF00FF"
  primary-hover: "#EA40FF"
  primary-active: "#D900F9"
  secondary: "#4533FF"
  tertiary: "#00E5FF"
  quaternary: "#FF2EC4"
  deep-violet: "#550078"
  background-light: "#EDEDED"
  background-dark: "#121212"
  surface-light: "#FFFFFF"
  surface-dark: "#1A1A1A"
  text-light: "#33313B"
  text-dark: "#D6D6DB"
  title-light: "#121212"
  title-dark: "#F7F5FA"
  muted-light: "#625B70"
  muted-dark: "#A6A6B2"
  border-light: "#787482"
  border-dark: "#7C7C8A"
  selection-light: "#E8D3FF"
  selection-dark: "#3B124B"
  selection-text-light: "#550078"
  selection-text-dark: "#F7F5FA"
typography:
  display:
    fontFamily: "Stack Sans Notch, sans-serif"
    fontWeight: 900
  body:
    fontFamily: "Google Sans, monospace"
    fontSize: "16px"
    lineHeight: "1.6"
  xs:
    fontFamily: "Google Sans, monospace"
    fontSize: "12px"
    lineHeight: "1.2"
    letterSpacing: "0.06em"
  sm:
    fontFamily: "Google Sans, monospace"
    fontSize: "14px"
    lineHeight: "1.5"
  lg:
    fontFamily: "Google Sans, monospace"
    fontSize: "18px"
    lineHeight: "1.55"
  xl:
    fontFamily: "Stack Sans Notch, sans-serif"
    fontSize: "32px"
    lineHeight: "1.08"
    letterSpacing: "-0.025em"
  2xl:
    fontFamily: "Stack Sans Notch, sans-serif"
    fontSize: "48px"
    lineHeight: "1"
    letterSpacing: "-0.035em"
  3xl:
    fontFamily: "Stack Sans Notch, sans-serif"
    fontSize: "64px"
    lineHeight: "0.98"
    letterSpacing: "-0.04em"
spacing:
  px: "1px"
  1: "4px"
  2: "8px"
  4: "16px"
  6: "24px"
  8: "32px"
  16: "64px"
rounded:
  none: "0px"
  sm: "4px"
  md: "6px"
  lg: "10px"
  full: "9999px"
components:
  button-primary:
    backgroundColor: "{colors.deep-violet}"
    textColor: "{colors.title-dark}"
    typography: "{typography.body}"
    rounded: "{rounded.md}"
    padding: "{spacing.2}"
  button-primary-hover:
    backgroundColor: "{colors.primary-hover}"
  surface-dark:
    backgroundColor: "{colors.surface-dark}"
    textColor: "{colors.text-dark}"
---

# Psychedelic Glitch — WebCraft[cite: 4]

## Overview
Un lenguaje visual de alto contraste para WebCraft, donde los rigurosos sistemas en blanco y negro son interrumpidos por colores saturados espectrales[cite: 4]. La interfaz debe sentirse lo suficientemente precisa y técnica para generar confianza, pero lo suficientemente extraña para invitar a la exploración y el descubrimiento[cite: 4].

## Colors
La paleta tiene una base oscura/clara estable y espectros de interferencia saturados[cite: 4]:
- **Primary (`#DF00FF`):** Púrpura psicodélico[cite: 4]. Úsalo para la acción principal, énfasis y highlights[cite: 4].
- **Secondary (`#4533FF`):** Azul eléctrico[cite: 4]. Perfecto para enlaces y estados de selección en modo claro[cite: 4].
- **Tertiary (`#00E5FF`):** Cian señal[cite: 4]. Ideal para enlaces e indicadores de enfoque técnico en modo oscuro[cite: 4].
- **Quaternary (`#FF2EC4`):** Magenta intenso[cite: 4]. Resérvalo exclusivamente para efectos de desfase *glitch* y aberraciones cromáticas decorativas[cite: 4].

## Typography
El sistema utiliza una voz *display* con mucha personalidad y una voz técnica para lectura prolongada[cite: 4]:
- **Display (`font-display`):** Stack Sans Notch[cite: 4]. Debe sentirse construida, no ornamental[cite: 4]. Úsala con tracking negativo en titulares grandes[cite: 4].
- **Body & Code (`font-body`):** Google Sans. Refuerza la autoría técnica y el concepto de programación manteniendo una estructura de lectura orgánica desde los 14px en adelante.

## Layout & Elevation
- **Grid:** Estructura basada en bloques con un ritmo vertical de 8px[cite: 4]. El "medio paso" de 4px se reserva exclusivamente para ajustes ópticos[cite: 4].
- **Profundidad:** Evita a toda costa las sombras genéricas y suaves[cite: 4]. Genera profundidad mediante diferencias cromáticas, superficies tonales o delineados estructurales de 1px[cite: 4]. El radio de los componentes va desde cortes rectos (0px) hasta bordes de tarjeta (10px)[cite: 4].

## Do's and Don'ts
- **Hazlo:** Preserva la estructura neutra antes de inyectar el estímulo del color saturado[cite: 4].
- **Hazlo:** Asegúrate de que el color activo vaya acompañado de otra señal visual (un borde, un subrayado, un cambio de forma o etiqueta)[cite: 4].
- **No lo hagas:** Usar `#DF00FF` sobre fondo blanco en textos pequeños; fallará en accesibilidad por falta de contraste[cite: 4].
- **No lo hagas:** Aplicar gradientes saturados detrás de elementos de lectura esencial o formularios[cite: 4].
- **No lo hagas:** Introducir otra familia tipográfica sin un rol sistémico justificado[cite: 4].

## Contrato compartido: sitio, editor y administración

La revisión editorial del 22 de noviembre de 2026 adopta este documento como
contrato de diseño para las vistas públicas, la edición en contexto y las
pantallas de administración que se migren. La implementación y sus fases se
describen en el [plan editorial](docs/admin-migration-plan.md).

El front matter será la única fuente manual de valores de tokens. El plan prevé
generar `app/assets/stylesheets/design-system/tokens.css` y consumirlo desde una
configuración CSS compartida de Tailwind en `design-system/theme.css`. El
exportador y esa integración todavía no están implementados; hoy hay valores
duplicados en `application.tailwind.css`. Antes de activar la generación se deben
resolver diferencias como la escala `xl/2xl/3xl`, sin cambiarla silenciosamente.

La configuración Tailwind define el mapeo de tokens a utilidades y los roles
semánticos; no introduce una segunda paleta editable. Los tokens controlan
valores, mientras que los parciales y controladores implementan estructura y
comportamiento. Una actualización de componentes debe reflejarse también en las
reglas de este documento.

- Compartir roles de fondo, superficie, texto, texto secundario, borde, acento,
  foco, error y éxito en claro y oscuro. Los controles editoriales usan la misma
  identidad que el contenido público.
- Distinguir la escala de titulares del contenido y la escala de controles del
  editor mediante su alcance. Un encabezado en un inspector no hereda el tamaño
  de un titular de proyecto.
- Definir estados de botón/campo, foco visible, carga, error, guardado pendiente
  y publicación. Acompañar el color con texto o una señal adicional.
- Mantener los controles de portada y edición accesibles con teclado y en móvil;
  ninguna acción esencial depende del hover o de arrastrar.
- Reutilizar la composición de proyecto y tarjeta entre lectura, edición y
  preview. Las herramientas se agregan alrededor del contenido y el visitante
  recibe únicamente la revisión publicada.
- Reservar glitch, canvas y WebGL para contenido y experiencias creativas;
  conservar legibilidad y movimiento reducido en formularios y herramientas.

Un cambio de diseño se revisa en colección pública, ficha de proyecto, editor,
home y un recurso admin migrado, a 375 px y escritorio, en claro y oscuro. Durante
la transición, las pantallas anteriores de AdminLTE permanecen en su propio
layout; no se mezclan sus estilos con el nuevo sistema en un mismo documento.
