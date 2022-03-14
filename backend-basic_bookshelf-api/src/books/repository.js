import { nanoid } from 'nanoid';
import { setDebugValue } from '../utils/dev.js';
import { pick } from '../utils/object.js';
import collection from './data.js';

/**
 * @typedef {import('../types').Book} Book
 */

/** @returns {Book} */
const createBook = (data) => ({
  ...data,
  id: nanoid(),
  finished: false,
  insertedAt: new Date(),
  updatedAt: new Date(),
});

const findBook = (id) => collection.find((el) => el.id === id);

const listBooks = () => collection;

/** @param {Book} book */
const isFinished = (book) => book.readPage >= book.pageCount;

const saveBook = (book, createNewIfNotExists = true) => {
  const index = collection.findIndex((el) => el.id === book.id);

  if (index < 0) {
    if (createNewIfNotExists) {
      const newBook = createBook(book);
      newBook.finished = isFinished(newBook);
      collection.push(newBook);
      return newBook.id;
    }
    return undefined;
  }

  collection[index] = {
    ...collection[index],
    ...book,
    updatedAt: new Date(),
  };
  collection[index].finished = isFinished(collection[index]);
  return book.id;
};

const deleteBook = (id) => {
  const index = collection.findIndex((el) => el.id === id);

  if (index < 0) return false;

  collection.splice(index, 1);
  return true;
};

const pickSupportedFilter = (arr) => arr.map((el) => pick(el, ['name', 'finished', 'reading']));

const searchBooks = ({ name, reading, finished }) => {
  const nameMatcher = new RegExp(name, 'gi');
  const filtered = collection.filter((el) => (name !== undefined
    ? el.name.match(nameMatcher) : true)
    && (reading !== undefined ? !!el.reading === !!reading : true)
    && (finished !== undefined ? !!el.finished === !!finished : true));

  setDebugValue('query', { name, reading, finished });
  setDebugValue('all', pickSupportedFilter(collection));

  return filtered;
};

export {
  createBook,
  findBook,
  listBooks,
  saveBook,
  deleteBook,
  searchBooks,
};
