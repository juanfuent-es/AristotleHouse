#!/usr/bin/env node
// Rebuild derived icons from the two gaze masters. Requires ImageMagick.
import { execFileSync } from 'node:child_process'
import { readFileSync, writeFileSync, mkdtempSync, rmSync } from 'node:fs'
import { tmpdir } from 'node:os'
import { resolve, join, dirname } from 'node:path'
import { fileURLToPath } from 'node:url'

const root = resolve(dirname(fileURLToPath(import.meta.url)), '..')
const publicDir = join(root, 'public')
const master = (tone) => readFileSync(join(publicDir, `brand/gaze-${tone}.svg`), 'utf8')
const artwork = (tone) => master(tone).replace(/^<svg[^>]*>/, '').replace(/<\/svg>\s*$/, '')
const temp = mkdtempSync(join(tmpdir(), 'aristotle-icons-'))

try {
  // Keep both masters intact: their shapes differ as well as their colour.
  writeFileSync(join(publicDir, 'favicon.svg'), `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 76.49 76.49">
<style>.light{display:none}@media(prefers-color-scheme:dark){.dark{display:none}.light{display:inline}}</style>
<g class="dark" fill="#0B0A0F">${artwork('dark')}</g>
<g class="light" fill="#F2EFE8">${artwork('light')}</g>
</svg>\n`)

  const rasterize = (source, size, output) => execFileSync('convert', [
    '-background', 'none', '-density', '768', source,
    '-resize', `${size}x${size}`, '-depth', '8', '-strip', output
  ])
  // Render once at high resolution, then downsample for the small favicon sizes.
  const fallback = join(temp, 'fallback.png')
  execFileSync('convert', [
    '-background', '#F2EFE8', '-density', '768', join(publicDir, 'brand/gaze-dark.svg'),
    '-resize', '512x512', '-alpha', 'remove', '-depth', '8', '-strip', fallback
  ])
  for (const size of [16, 32, 96]) rasterize(fallback, size, join(publicDir, `favicon-${size}x${size}.png`))
  execFileSync('convert', [fallback, '-define', 'icon:auto-resize=64,48,32,16', join(publicDir, 'favicon.ico')])

  // App icons need an opaque background and a safe margin for launcher masks.
  const appIcon = join(temp, 'app.svg')
  writeFileSync(appIcon, `<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">
<path fill="#F2EFE8" d="M0 0h512v512H0z"/>
<g transform="translate(112 112) scale(${288 / 76.49})" fill="#0B0A0F">${artwork('dark')}</g>
</svg>`)
  for (const name of ['apple-touch-icon', 'apple-touch-icon-precomposed']) {
    rasterize(appIcon, 180, join(publicDir, `${name}.png`))
  }
  for (const size of [192, 512]) {
    for (const name of ['android-chrome', 'web-app-manifest']) {
      rasterize(appIcon, size, join(publicDir, `${name}-${size}x${size}.png`))
    }
  }
} finally {
  rmSync(temp, { recursive: true, force: true })
}
