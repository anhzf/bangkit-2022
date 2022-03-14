/**
 * @typedef {import('@hapi/hapi').Lifecycle.Method} Handler
*/

import {
  deleteBook, findBook, listBooks, saveBook, searchBooks,
} from './repository.js';
import { pick } from '../utils/object.js';
import { getDebugValue, shouldDebug } from '../utils/dev.js';

const success = (data, message) => ({
  status: 'success',
  data,
  message,
  ...(shouldDebug() ? { debug: getDebugValue() } : null),
});

const fail = (message) => ({
  status: 'fail',
  message,
  ...(shouldDebug() ? { debug: getDebugValue() } : null),
});

/** @type {Handler} */
const create = (req, h) => {
  const {
    name, readPage, pageCount, ...payload
  } = req.payload;

  if (!name) {
    return h.response(fail('Gagal menambahkan buku. Mohon isi nama buku'))
      .code(400);
  }

  if (readPage > pageCount) {
    return h.response(fail('Gagal menambahkan buku. readPage tidak boleh lebih besar dari pageCount'))
      .code(400);
  }

  const newBook = saveBook({
    name, readPage, pageCount, ...payload,
  });

  if (newBook) {
    return h.response(success({ bookId: newBook }, 'Buku berhasil ditambahkan'))
      .code(201);
  }

  return h.response()
    .code(500);
};

/** @type {Handler} */
const getAll = ({ query }) => {
  // Normalize query
  const { name } = query;
  const reading = query.reading === undefined ? undefined : !!Number(query.reading);
  const finished = query.finished === undefined ? undefined : !!Number(query.finished);
  const hasQuery = typeof name === 'string' || reading !== undefined || finished !== undefined;
  const q = { name, reading, finished };

  const books = (hasQuery ? searchBooks(q) : listBooks())
    .map((el) => (query.all ? el : pick(el, ['id', 'name', 'publisher'])));

  return success({ books });
};

/** @type {Handler} */
const get = (req, h) => {
  const { id } = req.params;
  const book = findBook(id);

  if (book) {
    return success({ book });
  }

  return h.response(fail('Buku tidak ditemukan'))
    .code(404);
};

/** @type {Handler} */
const update = (req, h) => {
  const {
    name, readPage, pageCount, ...payload
  } = req.payload;

  if (!name) {
    return h.response(fail('Gagal memperbarui buku. Mohon isi nama buku'))
      .code(400);
  }

  if (readPage > pageCount) {
    return h.response(fail('Gagal memperbarui buku. readPage tidak boleh lebih besar dari pageCount'))
      .code(400);
  }

  const book = saveBook({
    id: req.params.id,
    name,
    ...(readPage && { readPage }),
    ...(pageCount && { pageCount }),
    ...payload,
  }, false);

  if (book) {
    return h.response(success(undefined, 'Buku berhasil diperbarui'));
  }

  return h.response(fail('Gagal memperbarui buku. Id tidak ditemukan'))
    .code(404);
};

/** @type {Handler} */
const remove = (req, h) => {
  const { id } = req.params;

  if (deleteBook(id)) {
    return h.response(success(undefined, 'Buku berhasil dihapus'));
  }

  return h.response(fail('Buku gagal dihapus. Id tidak ditemukan'))
    .code(404);
};

export {
  get,
  getAll,
  create,
  update,
  remove as delete,
};
