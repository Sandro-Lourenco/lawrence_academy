    async def update_module(self, module_id: str, module_data: dict) -> Module:
        res = (
            self.client.table("modules")
            .update(module_data)
            .eq("id", module_id)
            .select("*, lessons(*, lesson_blocks(*))")
            .execute()
        )
        if not res.data:
            raise NotFoundError("Módulo não encontrado para atualização.")
        return self._map_module(typing.cast(dict[str, typing.Any], res.data[0]))

# --- NEW REPLACEMENT ---

    async def update_module(self, module_id: str, module_data: dict) -> Module:
        res = (
            self.client.table("modules")
            .update(module_data)
            .eq("id", module_id)
            .select("*, lessons(*, lesson_blocks(*))")
            .execute()
        )
        if not res.data:
            raise NotFoundError("Módulo não encontrado para atualização.")
        return self._map_module(typing.cast(dict[str, typing.Any], res.data[0]))

# --- NEW REPLACEMENT ---

    async def update_module(self, module_id: str, module_data: dict) -> Module:
        res = (
            self.client.table("modules")
            .update(module_data)
            .eq("id", module_id)
            .select("*, lessons(*, lesson_blocks(*))")
            .execute()
        )