# FastDelivery

Aplicativo acadêmico Flutter para entregadores consultarem endereços brasileiros, encontrarem CEPs, recuperarem consultas offline e abrirem rotas em aplicativos de mapas. Suporta **somente Android e iOS**. Não exige login, servidor próprio, conta ou chave de API.

## Funcionalidades

- Consulta por CEP com normalização e validação de oito dígitos antes da requisição.
- Consulta por UF, cidade e nome completo ou parcial do logradouro; cidade e rua exigem ao menos três caracteres.
- Lista de correspondências, seleção e detalhes: CEP, rua, complemento, bairro, cidade, UF, IBGE e data/hora.
- Histórico Hive persistente, em ordem decrescente de consulta, com um registro atualizado por CEP.
- Última consulta e consultas recentes restauradas ao abrir o aplicativo.
- Histórico disponível sem internet e identificado como informação local. Rever um registro não altera a data de consulta.
- Animação de abertura com substituição da rota, sem acumular splash na pilha.
- Estados reativos de carregamento, erro, timeout e resultado vazio; mensagens em português.
- Geocodificação e seleção entre Google Maps, Apple Maps e Waze **instalados**. O mapa utiliza a localização atual como origem.

**Limite do produto:** o ViaCEP não fornece número de imóvel nem coordenadas de entrega. A rota aponta para a localização aproximada do endereço/CEP resolvida pelo geocodificador. Confirme o destino no mapa. CEPs gerais podem representar um município inteiro. O aplicativo não afirma precisão de ponto de entrega.

## Arquitetura

MVC por funcionalidade, complementado por Services e Repositories, com injeção por construtor:

```text
lib/
  main.dart                        # Inicializa Hive antes do runApp; trata falha de abertura
  src/
    app.dart                       # MaterialApp, tema e localização pt-BR
    app_dependencies.dart          # Composição das dependências compartilhadas
    http/dio_client.dart           # HTTPS, URL-base e timeouts
    routes/app_routes.dart         # Nomes e criação das rotas, histórico com retorno tipado
    shared/
      colors/                      # Paleta
      metrics/                     # Espaçamentos e limites de largura
      components/                  # Tema, erros, datas, loading e estados vazios
      storage/                     # Inicialização Hive e adapter versionado
    modules/
      initial/page/                # Splash animada
      home/
        components/                # Formulário, lista, detalhes, resultado e última consulta
        controller/                # Store MobX e arquivo gerado
        model/                     # Address e serialização
        repositories/              # Contratos, ViaCEP e histórico Hive
        service/                   # Validação, consultas, persistência e mapas
        page/                      # Home e interação de navegação
      history/
        controller/                # Store MobX independente e arquivo gerado
        page/                      # Histórico offline
test/                              # Regras, HTTP fake, Hive em disco, stores e widgets
tool/check_viacep.dart              # Verificação remota opcional com três requisições reais
android/                           # Projeto Android e Gradle Wrapper
ios/                               # Projeto Xcode
docs/VALIDACAO.md                   # Evidências e checklist de entrega
```

Widgets não fazem requisições HTTP nem acessam boxes diretamente. Services validam e coordenam os repositórios. A consulta por endereço só é persistida após a seleção; consultar um CEP existente persiste automaticamente. Falha de gravação é informada sem descartar o endereço encontrado ou inventar um histórico salvo. Uma falha na consulta remota não é substituída silenciosamente por cache.

## Ferramentas e dependências

Ambiente utilizado: **Flutter 3.47.7 stable / Dart 3.13.5**, Windows, **Microsoft OpenJDK 17.0.20.1**, Android SDK Platform 36. O template usa AGP 9.1.0, Gradle 9.3.1, Android mínimo API 24 e iOS mínimo 15.0. Use o mesmo Flutter para reproduzir a resolução registrada em `pubspec.lock`.

O nome Dart é `fast_delivery` porque nomes de pacotes devem usar letras minúsculas e sublinhados. O nome exibido é **FastDelivery**.

| Biblioteca | Referência do documento | Versão resolvida / decisão |
| --- | --- | --- |
| dio | ^4.0.6 | 5.11.1: API atual de exceções e timeouts com Duration |
| flutter_mobx | ^2.0.4 | 2.4.0 |
| mobx | ^2.0.6+1 | 2.7.0 |
| hive | ^2.1.0 | 2.2.3: preservada a linha Hive 2 |
| hive_flutter | ^1.1.0 | 1.1.0 |
| path | ^1.8.0 | 1.9.1; usado também internamente pelo hive_flutter |
| path_provider | ^2.0.2 | 2.1.6; diretório privado de dados |
| path_provider_android | ^2.0.14 | 2.3.1, gerenciado transitivamente por path_provider |
| path_provider_ios | ^2.0.9 | Substituído por path_provider_foundation 2.6.0, transitivo oficial |
| map_launcher | ^2.2.1+1 | 7.0.0: API de requests, descoberta e abertura conferida no pacote instalado |
| geocoding | ^2.1.1 | 5.0.0: instância Geocoding e implementação nativa |
| mobx_codegen | ^2.0.1+3 | 2.8.0 |
| build_runner | ^2.0.5 | 2.16.1: limitado a <2.17 por compatibilidade com build 4 e mobx_codegen |
| hive_generator | ^2.0.0 | Não utilizado: adapter Hive implementado explicitamente |
| flutter_lints | — | 6.0.0 |
| flutter_localizations | — | SDK Flutter: textos e datas em português |

**Justificativa do adapter:** `hive_generator` 2.0.1 exige `analyzer <7`, `build ^2` e `source_gen ^1`. `mobx_codegen` 2.8.0 exige `analyzer ^13.3`, `build ^4` e `source_gen ^4`. As restrições são incompatíveis. O adapter explícito preserva o Hive, evita overrides inseguros e é testado com escrita, fechamento e reabertura real do banco. Seu typeId 0 e índices 0–7 são estáveis; alterações de schema precisam preservar esses índices. Os arquivos MobX `.g.dart` são gerados e devem ser versionados.

As versões de referência são antigas; a resolução atual foi executada com sucesso. Dependências nativas de plataforma são mantidas pelo pacote principal, evitando implementações iOS duplicadas. Não foram substituídos MobX, Dio ou Hive.

## Instalação e execução Android

Requisitos: Git, Flutter stable, JDK 17, Android SDK com platform-tools, command-line tools, plataforma 36, build-tools, e um celular com depuração USB ou emulador Android configurado. O build também utiliza NDK 28.2.13676358 e CMake 3.22.1, que as ferramentas Android podem instalar automaticamente. Na primeira compilação é necessária internet para baixar dependências.

```powershell
flutter --version
flutter doctor -v
flutter doctor --android-licenses
flutter pub get
dart run build_runner build
flutter devices
flutter run -d ID_DO_DISPOSITIVO
```

`ID_DO_DISPOSITIVO` é o identificador listado por `flutter devices`; substitua esse texto pelo ID real. Para um celular: ative Opções do desenvolvedor e Depuração USB, conecte o cabo de dados e autorize o computador na tela do aparelho. Para um emulador: Android Studio → Device Manager → Create Device; escolha uma imagem com Google APIs/Play Store e inicialize o dispositivo. Verifique novamente com `flutter devices`.

### Este computador

As ferramentas foram instaladas fora do repositório, sem substituir o Java 8 preexistente:

```text
C:\Users\Hiron\develop\flutter
C:\Users\Hiron\develop\java\jdk-17.0.20.1+1
C:\Users\Hiron\develop\android-sdk
```

O Flutter foi configurado com esses diretórios. Para disponibilizar Flutter/Dart no terminal PowerShell atual:

```powershell
$env:Path = "C:\Users\Hiron\develop\flutter\bin;$env:Path"
flutter doctor -v
flutter pub get
dart run build_runner build
flutter run -d ID_DO_DISPOSITIVO
```

Para configurar em outro computador, ajuste os caminhos:

```powershell
flutter config --android-sdk 'C:\caminho\android-sdk'
flutter config --jdk-dir 'C:\caminho\jdk-17'
```

As instalações oficiais estão em [Flutter](https://docs.flutter.dev/install/manual) e [Android Studio](https://developer.android.com/studio). Para tornar o comando permanente no Windows, adicione o diretório `flutter\bin` ao PATH do usuário nas Variáveis de Ambiente e reabra o terminal. O SDK Flutter já inclui o Dart; não instale uma cópia separada.

## iOS

A compilação iOS exige **macOS e Xcode**. Não pode ser validada neste Windows. Configure o Xcode, ferramentas de linha de comando e o simulador conforme [Flutter para iOS](https://docs.flutter.dev/platform-integration/ios/setup).

No Mac, dentro do projeto:

```bash
flutter doctor -v
flutter pub get
dart run build_runner build
open -a Simulator
flutter devices
flutter run -d ID_DO_SIMULADOR
flutter build ios --no-codesign
```

O template utiliza a integração atual do Flutter com plugins/Swift Package Manager; se o Flutter solicitar CocoaPods, instale e configure-o nesse Mac. Para dispositivo físico/distribuição, abra `ios/Runner.xcworkspace` no Xcode, configure Signing & Capabilities e selecione sua equipe. Assinatura e publicação não foram realizadas.

## Validação e APK

```powershell
dart format lib test tool
flutter pub get
dart run build_runner build
flutter analyze
flutter test
flutter build apk --debug
```

O parâmetro antigo `--delete-conflicting-outputs`, citado no documento, foi executado e o build_runner 2.16.1 avisou que ele foi removido e é ignorado. Use o comando sem esse parâmetro.

`dart format .` também foi tentado; no caminho longo deste workspace Windows, a varredura de diretórios intermediários de build falhou. O comando acima limita a formatação aos fontes Dart, evitando artefatos gerados de compilação.

APK de desenvolvimento: `build/app/outputs/flutter-apk/app-debug.apk`. Para instalar em um Android conectado:

```powershell
flutter install --debug -d ID_DO_DISPOSITIVO
```

O APK debug serve para demonstração e testes. Distribuição em loja exige configuração de assinatura release própria; o template ainda utiliza a assinatura debug no build release.

Verificação opcional do serviço real, fora dos testes automatizados:

```powershell
dart run tool/check_viacep.dart
```

Esse comando faz três chamadas ViaCEP: CEP conhecido, CEP inexistente e busca por endereço. A suíte `flutter test` usa fakes de HTTP/plugins e Hive real em diretório temporário; não exige internet nem aplicativos de mapas instalados. Detalhes dos resultados e validações de dispositivo ainda pendentes: [docs/VALIDACAO.md](docs/VALIDACAO.md).

## API, armazenamento e permissões

- [ViaCEP](https://viacep.com.br/): gratuito, sem chave, respostas variáveis e limite de até 50 resultados por pesquisa por endereço. Evite consultas em massa. O app usa HTTPS e timeouts de conexão/envio de 10s e recebimento de 15s.
- Android declara apenas INTERNET e visibilidade dos pacotes Google Maps e Waze. iOS declara os esquemas comgooglemaps e waze para descoberta.
- Nenhuma permissão de localização é solicitada pelo FastDelivery. A origem é omitida no request do [map_launcher](https://pub.dev/packages/map_launcher); o próprio aplicativo de mapas gerencia localização/permissões.
- [geocoding](https://pub.dev/packages/geocoding) utiliza os serviços nativos do sistema. Pode depender de conexão, disponibilidade e limites do provedor; erros são tratados sem coordenadas inventadas.
- O histórico está no sandbox privado do app, box `address_history_v1`, em `fast_delivery` dentro do diretório de documentos. Fechar e reabrir mantém os dados. Limpar os dados do app ou desinstalá-lo remove o histórico; não existe backup/sincronização implementado.
- Não há rastreamento contínuo. As pesquisas são enviadas ao ViaCEP, e o endereço escolhido ao geocodificador e mapa quando o usuário solicita rota.

## Publicação no GitHub

Repositório de entrega: [HironNovais/fastdelivery-flutter](https://github.com/HironNovais/fastdelivery-flutter), branch `main`.

Para obter o código em outro computador:

```powershell
git clone https://github.com/HironNovais/fastdelivery-flutter.git
cd fastdelivery-flutter
flutter pub get
```

Para enviar alterações futuras a partir de um clone autenticado:

```powershell
git status
git add .
git commit -m "Descreve a alteração"
git push
```

Use a autenticação normal do GitHub, sem colocar tokens no código ou na URL. O `.gitignore` exclui SDKs gerados localmente, builds, bancos temporários, credenciais e configurações específicas da máquina. `pubspec.lock`, os stores gerados e o Gradle Wrapper fazem parte da entrega.
