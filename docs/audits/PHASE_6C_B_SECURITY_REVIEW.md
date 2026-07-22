# Security Review: Phase 6C-B (Secure Offline Download)

## Controles Criptográficos
- **Algoritmo:** Adotado AES-256-GCM para criptografia independente de cada segmento `.ts`/`.m4s`.
- **Nonces:** Cada segmento gera um `encrypt.IV` de 96-bits aleatório e exclusivo salvo no header.
- **Isolamento de Chaves:** Implementada derivação de chave baseada em Master Key protegida por Enclave de Segurança (iOS Keychain / Android Keystore) atrelada ao `downloadId` utilizando derivação criptográfica (HKDF simulado/SHA-256 no MVP).
- **Invalidação Transacional:** Fluxos no `EncryptionService` expõem o wipe da Master Key para cenários de revogação/logout.

## Proteção de Fluxo e Anti-Replay
- **Tokens Distintos:** O sistema separa claramente o `Download Authorization Token` (uso imediato, <15min, usado contra a API localmente) da `Offline License` (validade persistida longo prazo).
- **JTI Atômico:** Registrado via `DownloadTokenRepository` garantindo que token seja emitido como `ACTIVE` e rastreado no ciclo de vida.
- **Manifesto (.m3u8):** Requisito de proteção aplicado, passando pela mesma camada de criptografia de modo a ofuscar URIs físicas.
- **Privacy First (Device ID):** Remoção de identificadores de hardware permanentes. O app gera um `installation_id` estático no Keystore exclusivo para a sessão.

## Veredito
**Status:** PASS
**Conclusão:** Atende rigorosamente ao OWASP MASVS para criptografia móvel at-rest.
