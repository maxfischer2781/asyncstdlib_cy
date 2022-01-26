# Patched PyTypeObject supporting async slots
from cpython.object cimport newfunc, destructor, traverseproc, inquiry, freefunc, ternaryfunc, hashfunc, reprfunc, unaryfunc, richcmpfunc, PyObject, descrgetfunc, descrsetfunc

cdef extern from "Python.h":
    ctypedef struct PyAsyncMethods:
        unaryfunc am_await
        unaryfunc am_aiter
        unaryfunc am_anext

    ctypedef struct PyTypeObject:
        const char* tp_name
        const char* tp_doc
        Py_ssize_t tp_basicsize
        Py_ssize_t tp_itemsize
        Py_ssize_t tp_dictoffset
        unsigned long tp_flags

        newfunc tp_new
        destructor tp_dealloc
        traverseproc tp_traverse
        inquiry tp_clear
        freefunc tp_free

        ternaryfunc tp_call
        hashfunc tp_hash
        reprfunc tp_str
        reprfunc tp_repr

        richcmpfunc tp_richcompare

        PyAsyncMethods* tp_as_async
        # getiterfunc tp_iter;
        # iternextfunc tp_iternext;

        PyTypeObject* tp_base
        PyObject* tp_dict

        descrgetfunc tp_descr_get
        descrsetfunc tp_descr_set
