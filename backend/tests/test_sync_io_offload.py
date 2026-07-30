import asyncio
import threading
import time

from src.core.concurrency.sync_io import SyncIoExecutor


def _blocking_wait(started: threading.Event, release: threading.Event) -> str:
    started.set()
    assert release.wait(timeout=2)
    return "done"


def test_blocking_io_does_not_stall_event_loop() -> None:
    async def scenario() -> None:
        executor = SyncIoExecutor(max_concurrency=1)
        started = threading.Event()
        release = threading.Event()

        task = asyncio.create_task(executor.run(_blocking_wait, started, release))
        while not started.is_set():
            await asyncio.sleep(0)

        loop_progressed = False

        async def heartbeat() -> None:
            nonlocal loop_progressed
            await asyncio.sleep(0.01)
            loop_progressed = True

        await asyncio.wait_for(heartbeat(), timeout=0.2)
        assert loop_progressed is True
        release.set()
        assert await task == "done"

    asyncio.run(scenario())


def test_sync_io_executor_applies_shared_backpressure() -> None:
    async def scenario() -> None:
        executor = SyncIoExecutor(max_concurrency=2)
        lock = threading.Lock()
        active = 0
        peak = 0

        def measured_call() -> None:
            nonlocal active, peak
            with lock:
                active += 1
                peak = max(peak, active)
            time.sleep(0.03)
            with lock:
                active -= 1

        await asyncio.gather(*(executor.run(measured_call) for _ in range(8)))
        assert peak == 2

    asyncio.run(scenario())


def test_sync_io_executor_rejects_zero_capacity() -> None:
    try:
        SyncIoExecutor(max_concurrency=0)
    except ValueError as error:
        assert "at least 1" in str(error)
    else:
        raise AssertionError("zero capacity must be rejected")
