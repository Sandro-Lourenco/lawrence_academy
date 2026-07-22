import ast
from collections import Counter
from pathlib import Path

from fastapi.routing import APIRoute

from src.main import app


BACKEND_ROOT = Path(__file__).resolve().parents[1]
MIGRATED_V1_ROUTES = (
    BACKEND_ROOT / "src/modules/profiles/interface/api/routes.py",
    BACKEND_ROOT / "src/modules/courses/interface/api/routes.py",
    BACKEND_ROOT / "src/modules/assessments/interface/api/routes.py",
    BACKEND_ROOT / "src/modules/payments/interface/api/routes.py",
    BACKEND_ROOT / "src/modules/subscriptions/interface/api/routes.py",
    BACKEND_ROOT / "src/modules/certificates/interface/api/routes.py",
    BACKEND_ROOT / "src/modules/courses/interface/api/teacher_routes.py",
    BACKEND_ROOT / "src/modules/invoices/interface/api/routes.py",
    BACKEND_ROOT / "src/modules/sync/interface/api/routes.py",
)


def test_migrated_v1_routes_do_not_import_infrastructure() -> None:
    violations: list[str] = []

    for route_file in MIGRATED_V1_ROUTES:
        tree = ast.parse(route_file.read_text(encoding="utf-8"), route_file.as_posix())
        for node in ast.walk(tree):
            if isinstance(node, ast.ImportFrom) and node.module:
                if ".infrastructure." in node.module or node.module.startswith(
                    "src.core.database"
                ):
                    violations.append(f"{route_file.name}:{node.lineno} {node.module}")

    assert not violations, "Routes must depend on interfaces/providers: " + ", ".join(
        violations
    )


def test_openapi_operation_ids_are_unique() -> None:
    operations = [
        operation
        for path_item in app.openapi()["paths"].values()
        for method, operation in path_item.items()
        if method.lower() in {"get", "post", "put", "patch", "delete"}
    ]
    operation_ids = [operation["operationId"] for operation in operations]
    duplicates = [
        operation_id
        for operation_id, count in Counter(operation_ids).items()
        if count > 1
    ]

    assert not duplicates, f"Duplicate OpenAPI operation IDs: {duplicates}"


def test_registered_method_and_path_pairs_are_unique() -> None:
    registered_pairs = [
        (method, route.path)
        for route in app.routes
        if isinstance(route, APIRoute)
        for method in route.methods
    ]
    duplicates = [
        pair for pair, count in Counter(registered_pairs).items() if count > 1
    ]

    assert not duplicates, f"Duplicate HTTP operations registered: {duplicates}"


def test_non_v1_business_routes_are_explicitly_deprecated() -> None:
    operational_paths = {"/", "/health"}
    violations = [
        route.path
        for route in app.routes
        if isinstance(route, APIRoute)
        and route.path not in operational_paths
        and not route.path.startswith("/api/v1/")
        and not route.deprecated
    ]

    assert not violations, f"Non-v1 routes must be deprecated aliases: {violations}"
