
# DomGL on Rails
Dynamic websites with minimal effort

## BackEnd

El uso de este sistema requiere de conocimiento en [Rails](https://rubyonrails.org/), y el patrón de diseño que ocupa, MVC (Modelo-Vista-Controlador).

  

## FrontEnd

Las vistas ocupadas en este sistema podrás encontrarlas para su edición en.

/app/views/**/*.html.erb

Para más información más acerca de la generación, edición, eliminación de vistas y rutas visita la documentación en [Action View Overview](https://guides.rubyonrails.org/action_view_overview.html)

### Librerías

- [three.js](https://threejs.org/) (versión fijada en `package-lock.json`)
- [gsap3](https://greensock.com/gsap/)
- [tailwindcss v4](https://tailwindcss.com/)
- [vitejs](https://vite-ruby.netlify.app/guide)

**ASCII ART**
https://patorjk.com/software/taag/#p=display&f=Slant&t=DomGL

**Dependencies**

    node 22.12+
    ruby >= 3.2, < 4.0
    bundler 2.7.1
    ImageMagick 7.1

https://developers.google.com/speed/webp/download?hl=es-419

**FFMPEG**

Download https://ffmpeg.org/download.html
https://www.gyan.dev/ffmpeg/builds/packages/ffmpeg-2023-03-23-git-30cea1d39b-essentials_build.7z

Extract files on C:/
Add new ambient variable on PATH:
C:\ffmpeg\bin

**Instalación**

    bundle install  
    npm ci

El intérprete de Ruby seleccionado en el shell debe cumplir el `Gemfile`.
En el entorno de esta revisión, `ruby` selecciona 3.1.2; `/usr/bin/ruby3.2`
proporciona 3.2.3 y permite ejecutar Bundler y Rails. La actualización a Ruby 3.4
se contempla como una entrega independiente de la migración.

### Engine editorial y sistema de diseño

El [plan editorial](docs/admin-migration-plan.md) parte de `/projects` como
espacio de lectura y edición en contexto, con borradores, publicación y selección
de proyectos para home. `/admin` conserva la gestión global. La propuesta incluye
un sistema Tailwind compartido cuyo contrato es [DESIGN.md](DESIGN.md), las fases
de implementación y el registro histórico de dependencias y validaciones.



## Issues & lectures for posible fix

Kerning on variable fonts
https://github.com/googlefonts/fontmake/issues/470
https://variablefonts.typenetwork.com/topics/spacing/
https://github.com/LettError/responsiveLettering

Readme Project
https://github.com/readme
https://github.com/readme/featured/css-future

ImageMagick errores
<!-- 
Errores
ImageMagick-7.1.1-25-Q16-x64-dll

Correcta Windows 64bits
ImageMagick-6.9.13-3-Q16-HDRI-x64-dll
-->

**Ejecución**

    rails s
    foreman start

Developed by [JuanFuent.es](https://juanfuent.es)
