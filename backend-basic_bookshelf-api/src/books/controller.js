/**
 * @typedef {import('@hapi/hapi').Lifecycle.Method} Handler
*/

import {
  deleteBook, findBook, listBooks, saveBook, searchBooks,
} from './repository.js';
import { pick } from '../utils/object.js';

const success = (data, message) => ({
  status: 'success',
  message,
  data,
});

const fail = (message) => ({
  status: 'fail',
  message,
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
  const qName = query.name;
  const qReading = Number(query.reading);
  const qFinished = Number(query.finished);
  const hasQuery = typeof qName === 'string' || !Number.isNaN(qReading) || !Number.isNaN(qFinished);
  const q = {
    name: qName,
    reading: Number.isNaN(qReading) ? undefined : qReading,
    finished: Number.isNaN(qFinished) ? undefined : qFinished,
  };

  const books = (hasQuery ? searchBooks(q) : listBooks())
    .map((el) => pick(el, ['id', 'name', 'publisher']));

  return success({ books }, 'Buku berhasil ditambahkan');
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
