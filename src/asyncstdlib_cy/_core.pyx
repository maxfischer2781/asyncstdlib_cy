#cython: language_level=3
from ._accessors cimport __aiter__, __anext__, is_aiterable, is_awaitable
from inspect import iscoroutinefunction
from typing import (
    Any,
    AsyncIterator,
    Iterable,
    AsyncIterable,
    Union,
    Optional,
    Awaitable,
    Callable,
    Type,
)
from types import TracebackType


AnyIterable = Union[Iterable, AsyncIterable]


cdef class Sentinel:
    """Placeholder with configurable ``repr``"""

    cdef str name

    def __init__(self, name: str):
        self.name = name

    def __repr__(self) -> str:
        return self.name


cpdef object aiter(subject: AnyIterable):
    """
    An async iterator object yielding elements from ``subject``

    :raises TypeError: if ``subject`` does not support any iteration protocol

    The ``subject`` must support
    the async iteration protocol (the :py:meth:`object.__aiter__` method),
    the regular iteration protocol (the :py:meth:`object.__iter__` method),
    or it must support the sequence protocol (the :py:meth:`object.__getitem__`
    method with integer arguments starting at 0).
    In either case, an async iterator is returned.
    """
    if not is_aiterable(subject):
        subject = _aiter_sync(subject)
    return __aiter__(subject)


async def _aiter_sync(iterable: Iterable) -> AsyncIterator:
    """Helper to provide an async iterator for a regular iterable"""
    for item in iterable:
        yield item


cdef class ScopedIter:
    """Context manager that provides and cleans up an iterator for an iterable"""

    cdef object _iterable
    cdef object _iterator

    def __init__(self, iterable: AnyIterable):
        self._iterator: Optional[AsyncIterator] = aiter(iterable)

    async def __aenter__(self) -> AsyncIterator:
        return self._iterator

    async def __aexit__(
        self,
        exc_type: Optional[Type[BaseException]],
        exc_val: Optional[BaseException],
        exc_tb: Optional[TracebackType],
    ) -> bool:
        if hasattr(self._iterator, "aclose"):
            await self._iterator.aclose()
        return False


cdef class borrow:
    """Borrow an async iterator for iteration, preventing it from being closed"""
    cdef object iterator

    def __init__(self, iterator: AsyncIterator):
        self.iterator = __aiter__(iterator)

    def __aiter__(self):
        return self

    def __anext__(self):
        return __anext__(self.iterator)


def awaitify(function: Callable) -> Callable:
    """Ensure that ``function`` can be used in ``await`` expressions"""
    if iscoroutinefunction(function):
        return function  # type: ignore
    else:
        return Awaitify(function)


cdef class Awaitify:
    """Helper to peek at the return value of ``function`` and make it ``async``"""

    cdef public object __wrapped__
    cdef object async_call

    def __init__(self, function: Callable):
        self.__wrapped__ = function
        self.async_call = None

    def __call__(self, *args: Any, **kwargs: Any) -> Awaitable:
        if self.async_call is None:
            value = self.__wrapped__(*args, **kwargs)
            if is_awaitable(value):
                self.async_call = self.__wrapped__
                return value
            else:
                self.async_call = force_async(self.__wrapped__)
                return await_value(value)
        else:
            return self.async_call(*args, **kwargs)


async def await_value(value):
    return value


def force_async(call: Callable) -> Callable:
    async def async_wrapped(*args: Any, **kwargs: Any):
        return call(*args, **kwargs)

    return async_wrapped
