# Auditoria de UX — Fase 2

Data: 2026-07-17. Escopo: jornada do estudante em Flutter Web e Android.

| Tela | Objetivo e ação principal | Atritos | Resultado |
| --- | --- | --- | --- |
| Landing/Catálogo | Descobrir e abrir um curso | Landing e catálogo compartilham a raiz | Landing editorial dedicada pendente |
| Login | Autenticar | Cadastro e recuperação não tinham entrada direta | Formulário curto mantido |
| Cadastro | Criar conta | `/register` abria em login | Agora abre no modo de cadastro |
| Recuperação | Solicitar e-mail seguro | Fluxo escondido no login | Rota `/forgot-password` implementada |
| Dashboard | Continuar aprendendo | Pouca síntese do progresso | Resumo real com progresso, aulas, tempo e pendências |
| Catálogo | Pesquisar e filtrar | Sem cursor/recomendações reais | Estados existentes preservados; API pendente |
| Curso | Entender oferta/continuar | Avaliações e materiais incompletos | Pendente de contratos reais |
| Player | Assistir e progredir | Legenda, notas e velocidade parciais | Pendente de player/API |
| Perfil/Configurações | Identidade e preferências | Dispositivos e preferências sem backend completo | Pendente de contrato e RLS |
| Certificados | Visualizar conquista | Runtime depende de fixtures | Endpoint canônico existente |
| Assinaturas/Pagamentos | Gerenciar cada curso | Stripe real não validado | Bloqueado até homologação |
| Notificações | Entender pendências | Não há módulo/endpoint canônico | Não foi simulado |
| Logout | Encerrar sessão | Escopo local/global não é explicado | Política de sessões pendente |

Conclusão: a jornada principal ganhou entradas diretas e o dashboard comunica melhor o próximo passo. Produção depende de contratos reais para notificações, dashboard agregado, perfil avançado e player.
