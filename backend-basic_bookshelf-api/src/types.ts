export interface Book {
  id: string;
  name: string;
  year: number;
  author: string;
  summary: string;
  publisher: string;
  pageCount: number;
  readPage: number;
  reading: boolean;
  finished: boolean;
  insertedAt: Date;
  updatedAt: Date;
}
