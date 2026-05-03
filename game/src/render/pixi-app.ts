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
    autoDensity: false,
    resolution: 1,
  });

  const canvas = app.canvas as HTMLCanvasElement;
  canvas.style.imageRendering = 'pixelated';
  mount.appendChild(canvas);

  const resize = () => {
    const scale = Math.max(
      1,
      Math.min(
        Math.floor(window.innerWidth / LOGICAL_WIDTH),
        Math.floor(window.innerHeight / LOGICAL_HEIGHT),
      ),
    );
    canvas.style.width = `${LOGICAL_WIDTH * scale}px`;
    canvas.style.height = `${LOGICAL_HEIGHT * scale}px`;
  };
  window.addEventListener('resize', resize);
  resize();

  return { app, resize };
}
