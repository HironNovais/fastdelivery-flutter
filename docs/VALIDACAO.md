# Relatório de implementação e validação

Verificado em **21/10/2026**, no workspace FastDelivery em Windows. Referência funcional: `FastDelivery - Documentação.pdf`, fornecido pelo usuário. O documento foi tratado como especificação do aplicativo; publicações e acessos externos não foram executados como comandos contidos no PDF.

Este relatório preserva o estado da validação em 21/10/2026. O endereço do repositório de entrega e as instruções atuais de Git estão no [README](../README.md).

## Resultado

Aplicação implementada, dependências resolvidas, **41 testes automatizados aprovados**, análise estática sem apontamentos e APK debug compilado. Houve consultas reais bem-sucedidas ao ViaCEP. **A execução em Android/iOS e a navegação nativa em mapas ainda não foram validadas em dispositivo.** Não existe aparelho Android conectado nem emulador configurado; iOS exige um Mac com Xcode.

## Comandos executados e evidências

| Verificação | Resultado observado |
| --- | --- |
| `flutter --version` | Flutter 3.47.7 stable, framework abaf9c5237; Dart 3.13.5 |
| `flutter doctor -v` | Flutter e Android SDK detectados; JDK 17 configurado. Avisos de PATH, licenças Android adicionais e ausência de Visual Studio. Este último é referente a desktop Windows, fora do escopo. |
| `flutter create --platforms=android,ios --org br.com.fastdelivery --project-name fast_delivery --no-pub .` | Projeto criado no diretório inicialmente vazio; nenhum projeto web/desktop criado |
| `flutter pub get` | Dependências resolvidas; lockfile gerado. Avisos de versões mais novas fora das restrições documentadas. |
| `dart run build_runner build --delete-conflicting-outputs` | Dois stores MobX gerados. O runner avisa que o parâmetro legado foi removido e é ignorado. |
| `dart run build_runner build` | Geração concluída, arquivos `.g.dart` consistentes |
| `dart format .` | Tentativa falhou ao percorrer caminho longo de artefatos Gradle no Windows |
| `dart format lib test tool` | Sucesso, 43 arquivos formatados; limita a operação aos fontes |
| `flutter analyze` | **No issues found!**, exit code 0 |
| `flutter test --reporter expanded` | **41 testes passaram**, exit code 0 |
| `dart run tool/check_viacep.dart` | Três chamadas HTTPS reais: CEP conhecido, CEP inexistente e busca por endereço; exit code 0 |
| `flutter build apk --debug` | APK compilado com sucesso, exit code 0; compilação final após correções |
| `aapt dump badging …/app-debug.apk` | Label FastDelivery, applicationId br.com.fastdelivery.fast_delivery, versão 1.0.0 (1), mínimo API 24, target/compile API 36 |
| `flutter devices` | Apenas Windows, Chrome e Edge; nenhum dispositivo das plataformas do projeto |
| `flutter emulators` | Nenhuma imagem Android disponível |
| `flutter run` | **Bloqueado para Android/iOS** por ausência de dispositivo compatível; não executado nessas plataformas |
| Build iOS | **Bloqueado pelo sistema operacional**; não executado no Windows |
| Git | Inicializado na branch main; sem remoto e sem publicação |

APK final: `build/app/outputs/flutter-apk/app-debug.apk`, **158.108.523 bytes**, compilado como debug universal para demonstração.

SHA-256:

```text
A9E5D42490C349FED994D247663A568B9A0E949B22B7BC85E823910354C8B373
```

O APK é um artefato local ignorado pelo Git. Não é uma versão assinada para publicação em loja.

## Escopo dos testes

| Arquivo | Casos | Evidência |
| --- | ---: | --- |
| `address_service_test.dart` | 5 | Normalização do CEP, rejeição antes da rede, UF/cidade/rua, persistência só após seleção e serialização com nulos/data |
| `viacep_repository_test.dart` | 10 | Endpoints, JSON, erro booleano/string, caracteres codificados, lista vazia, resposta inválida, timeouts, desconexão e HTTP 503 |
| `hive_history_repository_test.dart` | 2 | **Hive real em disco:** fechamento/reabertura, preservação de campos e datas, ordenação e atualização de CEP repetido |
| `home_controller_test.dart` | 8 | Resultado, histórico, última consulta, seleção, loading observável, consultas concorrentes, erros/reação, resultado vazio, falha de gravação e leitura local |
| `navigation_service_test.dart` | 5 | Endereço selecionado/último consultado, escolha do mapa, ausência de aplicativos, geocoding sem resultado/inválido e falha ao abrir |
| `native_maps_gateway_test.dart` | 2 | API real do map_launcher 7 com plataforma fake; somente aplicativos instalados e request driving sem origem explícita |
| `app_widget_test.dart` | 9 | Splash e pilha, validação, loading e Observer, ida/volta do histórico, modo endereço com seleção real no formulário, mensagens de erro, escolha de mapa e tela 320×640 com texto ampliado |
| **Total** | **41** | Suíte determinística sem acesso à rede |

Os dados fixos estão exclusivamente nos fakes da suíte. O aplicativo de produção consulta o ViaCEP e lê o banco Hive. Nenhuma resposta de pesquisa de produção é simulada.

O teste de persistência fecha e reabre o banco em disco. Ele não equivale a uma execução manual do aplicativo em um celular após encerramento do processo. Os testes de mapas verificam regras e requests, com plataforma substituída para teste; não comprovam entrega da rota a um aplicativo instalado num aparelho real.

### Consultas remotas reais

Saída do script de verificação, usando o mesmo repositório Dio da aplicação:

```text
CEP: 01001-000 | Praça da Sé | São Paulo / SP
CEP inexistente: tratado corretamente.
Endereço: 50 resultado(s) do ViaCEP.
```

O ViaCEP limita a pesquisa a até 50 correspondências. A interface informa esse limite quando atingido. A disponibilidade e o conteúdo futuros do serviço podem variar; essas chamadas não são parte da suíte automatizada.

## Problemas encontrados e soluções

1. **Workspace vazio e ferramentas ausentes no PATH.** Instalados Flutter/Dart, JDK 17 e ferramentas Android em `C:\Users\Hiron\develop`, fora do repositório. Flutter configurado com SDK Android/JDK. O Java 8 anterior não foi removido. PATH permanente não foi alterado; o README fornece configuração para a sessão e para o usuário.
2. **Índice JSON do arquivo de releases Flutter retornou HTTP 404.** Obtido o canal stable do repositório oficial Flutter via Git; versão efetivamente instalada conferida pelo comando.
3. **Referências antigas de dependências.** Adotadas versões estáveis resolvidas no SDK instalado. `path_provider_ios` foi substituído pela implementação oficial `path_provider_foundation` gerenciada transitivamente. Detalhes no README.
4. **Incompatibilidade de geradores.** Hive generator 2 exige analyzer/build/source_gen antigos, incompatíveis com MobX codegen atual. Implementado TypeAdapter Hive explícito com índices fixos e teste real de round-trip em disco, mantendo Hive/MobX/Dio.
5. **Mudança de API de mapas/geocoding.** Conferido o código instalado: MapLauncher.directions + getSupportedMaps + SupportedMap.show; Geocoding().locationFromAddress. Filtrados resultados de disponibilidade que representam apenas links web.
6. **Erro de tipagem de rota descoberto por widget test.** A rota do histórico passou a ser MaterialPageRoute<Address>, permitindo devolver o endereço selecionado à Home. Testes de navegação e seleção passaram após a correção.
7. **Formatação da raiz percorreu paths longos de build.** Utilizado `dart format lib test tool`, com sucesso, sem alterar os artefatos Gradle.
8. **Avisos de estilo.** Corrigidos; análise final sem apontamentos.

## Checklist dos critérios de conclusão do PDF

“Atendido” abaixo descreve implementação e evidência disponível. Validação nativa dependente de dispositivo aparece separadamente; não equivale a afirmar aprovação em Android/iOS reais.

| Critério | Status | Evidência / limite |
| --- | --- | --- |
| Projeto Flutter criado corretamente | Atendido | Template oficial, análise e build APK |
| Somente plataformas Android e iOS | Atendido | Diretórios e metadata gerados para essas plataformas |
| Estrutura de diretórios organizada | Atendido | MVC + Services + Repositories por funcionalidade |
| Dependências configuradas e resolvidas | Atendido | pub get e lockfile; adaptações documentadas |
| main.dart configurado e funcional | Atendido | Inicializa armazenamento antes do runApp; trata erro de abertura |
| Tela inicial animada | Atendido | Widget test verifica redirecionamento e ausência na pilha |
| Consulta por CEP | Atendido | Testes de serviço/repositório/UI e consulta remota real |
| Consulta por endereço | Atendido | Testes de formulário/seleção e consulta remota real |
| Resultados apresentados corretamente | Atendido | Componentes de detalhes/lista e widget tests; revisão visual em aparelho pendente |
| Gerenciamento com MobX | Atendido | Dois stores, Observers, reação de erros e descarte |
| HTTP com Dio | Atendido | Repositório ViaCEP, tratamento de erros e verificação remota |
| Persistência Hive | Atendido | Adapter e teste real de escrita/reabertura |
| Histórico carrega automaticamente | Atendido | Load no initState e widget test |
| Último endereço disponível na Home | Atendido | Restauração do repositório, card e testes de store |
| Função traçar rota implementada | Atendido | Serviço, escolha de app, geocoding e API real do plugin; abertura nativa pendente |
| Loading, erro e vazio | Atendido | Stores e testes automatizados |
| Módulos compartilham dados/serviços | Atendido | Composition root e repositório compartilhado |
| Sem erros conhecidos de análise/compilação | Atendido no ambiente disponível | Análise e Android debug passam; build iOS não executado |
| Testes automatizados relevantes executados | Atendido | 41 aprovados |
| README completo | Atendido | Instalação, versões, arquitetura, permissões, mapas, testes e GitHub |
| Preparado para GitHub | Atendido | Git local, .gitignore, lockfile, fontes, gerados e Gradle Wrapper; sem publicação |

## Validações externas pendentes

| Etapa | Status | Ação necessária e como verificar |
| --- | --- | --- |
| Execução e inspeção visual Android | Bloqueado por dispositivo | Conectar Android com depuração USB ou criar/iniciar AVD no Device Manager. `flutter devices` deve listar o Android; então `flutter run -d ID`. |
| Histórico após fechar/reabrir o aplicativo no celular | Pendente de teste nativo | Consultar um CEP, encerrar o app sem limpar seus dados, reabrir e conferir histórico, data e última consulta sem rede. |
| Geocoding e navegação real | Pendente de teste nativo | Instalar Google Maps/Waze, consultar destino e tocar Traçar rota. Confirmar app escolhido, origem atual, destino aproximado e tratamento sem mapa/conexão. |
| Compilação/execução iOS | Bloqueado por macOS/Xcode | Em Mac: `flutter doctor -v`, `flutter pub get`, `flutter build ios --no-codesign`; executar em simulador/iPhone e repetir o teste com Apple Maps. |
| Publicação GitHub | Pendente de ação/autorização do responsável | Criar repositório remoto e executar os comandos documentados; `git remote -v` e a página do GitHub devem mostrar o remoto e os arquivos. |

Os avisos remanescentes de `flutter doctor` e a ausência de dispositivo não impedem os testes Dart/widgets nem o APK debug que foi efetivamente produzido. O projeto está implementado e compilado para Android; a validação nativa completa permanece pendente.
