import { nanoid } from 'nanoid';
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

const saveBook = (book, createNewIfNotExists = true) => {
  const index = collection.findIndex((el) => el.id === book.id);

  if (index < 0) {
    if (createNewIfNotExists) {
      const newBook = createBook(book);
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
  return book.id;
};

const deleteBook = (id) => {
  const index = collection.findIndex((el) => el.id === id);

  if (index < 0) return false;

  collection.splice(index, 1);
  return true;
};

const searchBooks = ({ name, reading, finished }) => {
  const nameMatcher = new RegExp(name, 'gi');
  const filtered = collection.filter((el) => el.name.match(nameMatcher)
    && !!el.reading === !!reading
    && !!el.finished === !!finished);

  console.log({
    nameMatcher, reading, finished, collection, filtered,
  });

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
