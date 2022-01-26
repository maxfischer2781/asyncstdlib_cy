#cython: language_level=3
from cpython.object cimport Py_TYPE
from ._pytype_as_async cimport PyTypeObject


cdef bint is_awaitable(__subject: object):
    cdef PyTypeObject* subject_type = <PyTypeObject*> Py_TYPE(__subject)
    return (
        subject_type.tp_as_async is not NULL
        and subject_type.tp_as_async.am_await is not NULL
    )


cdef bint is_aiterable(__subject: object):
    cdef PyTypeObject* subject_type = <PyTypeObject*> Py_TYPE(__subject)
    return (
        subject_type.tp_as_async is not NULL
        and subject_type.tp_as_async.am_aiter is not NULL
    )


cdef bint is_aiterator(__subject: object):
    cdef PyTypeObject* subject_type = <PyTypeObject*> Py_TYPE(__subject)
    return (
        subject_type.tp_as_async is not NULL
        and subject_type.tp_as_async.am_anext is not NULL
    )


cpdef object __aiter__(__subject: object):
    """Special method lookup of ``subject.__aiter__()``"""
    if not is_aiterable(__subject):
        raise TypeError(f"'{type(__subject).__name__}' object is not an async iterable")
    cdef PyTypeObject* subject_type = <PyTypeObject*> Py_TYPE(__subject)
    cdef object subject_aiter = subject_type.tp_as_async.am_aiter(__subject)
    if not is_aiterator(subject_aiter):
        raise TypeError(
            f"aiter() returned non-async-iterator of type {type(subject_aiter).__name__}"
        )
    return subject_aiter


cpdef object __anext__(__subject: object):
    """Special method lookup of ``subject.__next__()``"""
    if not is_aiterator(__subject):
        raise TypeError(f"'{type(__subject).__name__}' object is not an async iterator")
    cdef PyTypeObject* subject_type = <PyTypeObject*>Py_TYPE(__subject)
    cdef object subject_anext = subject_type.tp_as_async.am_anext(__subject)
    return subject_anext
