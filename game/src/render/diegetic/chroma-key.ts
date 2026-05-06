// Q-W (Bug #36 sub-fix B): chroma-key helper for prop sprites whose
// source PNG carries a non-transparent cream BG rectangle (W5's
// generated assets currently bake `#E8E0CC` into the background
// instead of using alpha; phone / fruit_bowl PNGs are the visible
// offenders). Strips the chroma color → alpha 0 at texture load.
//
// Approach: load the URL via Pixi.Assets, project pixels through a
// canvas2D ImageData buffer, knock alpha=0 on every pixel that lies
// within `tolerance` of the chroma color (Manhattan distance per
// channel — cheap and good enough for solid-fill BGs), then build a
// fresh Texture from the modified canvas. Output texture does NOT
// share a bitmap with the upstream Assets cache, so the original URL
// remains usable for non-keyed mounts elsewhere.

import { Assets, Texture } from 'pixi.js';

export interface ChromaKeySpec {
  /** RGB color to remove, as 0xRRGGBB. */
  color: number;
  /** Per-channel ± tolerance window (8-bit). 0 = exact match. */
  tolerance: number;
}

/** Fetch a texture and replace pixels within `tolerance` of the
 * `color` with alpha=0. Browser-only — vitest paths skip this and
 * call Assets.load directly. */
export async function loadChromaKeyedTexture(url: string, spec: ChromaKeySpec): Promise<Texture> {
  const baseTex = await Assets.load(url);
  const resource = baseTex.source?.resource as
    | HTMLImageElement
    | HTMLCanvasElement
    | ImageBitmap
    | undefined;
  if (!resource || typeof document === 'undefined') {
    console.warn('[chroma-key] no DOM / unsupported resource; returning base texture:', url);
    return baseTex;
  }
  const w = resource.width;
  const h = resource.height;
  const canvas = document.createElement('canvas');
  canvas.width = w;
  canvas.height = h;
  const ctx = canvas.getContext('2d');
  if (!ctx) return baseTex;
  ctx.drawImage(resource as CanvasImageSource, 0, 0);
  const imgData = ctx.getImageData(0, 0, w, h);
  const data = imgData.data;
  const cr = (spec.color >> 16) & 0xff;
  const cg = (spec.color >> 8) & 0xff;
  const cb = spec.color & 0xff;
  const tol = spec.tolerance;
  for (let i = 0; i < data.length; i += 4) {
    const r = data[i] ?? 0;
    const g = data[i + 1] ?? 0;
    const b = data[i + 2] ?? 0;
    if (Math.abs(r - cr) <= tol && Math.abs(g - cg) <= tol && Math.abs(b - cb) <= tol) {
      data[i + 3] = 0;
    }
  }
  ctx.putImageData(imgData, 0, 0);
  return Texture.from(canvas);
}
