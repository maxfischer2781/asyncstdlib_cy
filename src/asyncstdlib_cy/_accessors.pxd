#cython: language_level=3
cdef bint is_awaitable(__subject: object)

cdef bint is_aiterable(__subject: object)

cdef bint is_aiterator(__subject: object)

cpdef object __aiter__(__subject: object)

cpdef object __anext__(__subject: object)
