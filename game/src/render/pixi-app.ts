import { Application } from 'pixi.js';

export interface PixiAppHandles {
  app: Application;
  resize: () => void;
}

const LOGICAL_WIDTH = 640;
const LOGICAL_HEIGHT = 360;

export async function createPixiApp(mount: HTMLElement): Promise<PixiAppHandles> {
  const app = new Application();
  await app.init({
    width: LOGICAL_WIDTH,
    height: LOGICAL_HEIGHT,
    backgroundColor: 0x111418,
    antialias: false,
    roundPixels: true,
    // Render at native screen DPI so PixiJS Text and Graphics strokes
    // stay crisp on Retina (2x) and on fractional-CSS-scale windows.
    // Backing store is LOGICAL × resolution; CSS canvas size is LOGICAL.
    resolution: window.devicePixelRatio || 1,
    autoDensity: true,
  });

  const canvas = app.canvas as HTMLCanvasElement;
  // No image-rendering: pixelated — GPU does smooth (bilinear) upscale,
  // which combined with linear texture scaleMode for sprites gives a
  // "modern indie pixel art" look (Eastward / Hades), not strict
  // pixel-perfect SNES. Sources are high-detail; smooth scaling preserves
  // detail instead of crushing it via repeated nearest-neighbor.
  mount.appendChild(canvas);

  const resize = () => {
    // Fit-to-window with aspect-ratio preservation. Was strict integer
    // scale (Math.floor) which left visible letterbox on most window
    // sizes (e.g. macOS title bar steals 28px → 1080 inner becomes 1052
    // → floor(1052/360)=2 → 1280×720 canvas with black bars). For a
    // slow-paced narrative game, fractional scale + image-rendering:
    // pixelated is an acceptable trade — sprites stay crisp via
    // nearest-neighbor sampling, but some pixels render 2px wide and
    // some 3px when scale is non-integer. P0/P1/P2 don't have any
    // motion-critical or twitch-input scenarios so this is fine.
    const scale = Math.min(window.innerWidth / LOGICAL_WIDTH, window.innerHeight / LOGICAL_HEIGHT);
    canvas.style.width = `${LOGICAL_WIDTH * scale}px`;
    canvas.style.height = `${LOGICAL_HEIGHT * scale}px`;
  };
  window.addEventListener('resize', resize);
  resize();

  return { app, resize };
}
