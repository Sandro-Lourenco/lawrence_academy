"""Bounded offload for synchronous third-party SDK calls.

The Supabase and Stripe clients currently used by the application expose
synchronous APIs. Calling them directly from an ``async def`` blocks FastAPI's
event loop. This adapter keeps those calls outside the loop while bounding the
number of worker threads that may concurrently pressure upstream services.
"""

from __future__ import annotations

import os
from collections.abc import Callable
from functools import partial
from typing import ParamSpec, TypeVar

import anyio

_P = ParamSpec("_P")
_T = TypeVar("_T")


def _configured_capacity() -> int:
    raw_value = os.getenv("SYNC_IO_MAX_CONCURRENCY", "16")
    try:
        value = int(raw_value)
    except ValueError:
        return 16
    return max(1, min(value, 128))


class SyncIoExecutor:
    """Runs blocking callables in AnyIO's worker threads with backpressure."""

    def __init__(self, max_concurrency: int) -> None:
        if max_concurrency < 1:
            raise ValueError("max_concurrency must be at least 1")
        self._limiter = anyio.CapacityLimiter(max_concurrency)

    @property
    def max_concurrency(self) -> int:
        return int(self._limiter.total_tokens)

    async def run(
        self,
        callable_: Callable[_P, _T],
        *args: _P.args,
        **kwargs: _P.kwargs,
    ) -> _T:
        call = partial(callable_, *args, **kwargs)
        return await anyio.to_thread.run_sync(
            call,
            abandon_on_cancel=True,
            limiter=self._limiter,
        )


_shared_executor = SyncIoExecutor(_configured_capacity())


async def run_sync_io(
    callable_: Callable[_P, _T],
    *args: _P.args,
    **kwargs: _P.kwargs,
) -> _T:
    """Offload one blocking infrastructure call through the shared limiter."""

    return await _shared_executor.run(callable_, *args, **kwargs)
