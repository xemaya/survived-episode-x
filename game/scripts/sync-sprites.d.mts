export interface SyncSpritesOptions {
  src: string;
  dest: string;
  categories?: string[];
}

export declare function syncSprites(options: SyncSpritesOptions): Promise<number>;
