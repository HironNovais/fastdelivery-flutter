# Avaliação do FastDelivery

Há duas formas de avaliar: instalar o APK em Android ou executar as verificações a partir do código-fonte.

## Instalação direta no Android

1. Abra a [Release v1.0.0](https://github.com/HironNovais/fastdelivery-flutter/releases/tag/v1.0.0) no celular e baixe **FastDelivery.apk**, na seção Assets. [Download direto](https://github.com/HironNovais/fastdelivery-flutter/releases/download/v1.0.0/FastDelivery.apk).
2. Abra o arquivo e siga as instruções de instalação do Android. Caso solicitado, autorize a instalação pelo navegador ou gerenciador de arquivos utilizado.
3. Abra o FastDelivery. Para novas consultas, mantenha conexão com a internet; o histórico já salvo pode ser consultado offline.

Requisitos: Android 7.0 ou superior. O APK universal suporta armeabi-v7a, arm64-v8a e x86_64. Para testar rotas, instale Google Maps ou Waze. O FastDelivery não exige login, chave de API nem instalação de ferramentas de desenvolvimento no celular.

O pacote está em modo release com assinatura de testes, para demonstração acadêmica. Não corresponde a uma distribuição assinada para loja.

## Verificação pelo código-fonte

Utilize preferencialmente Flutter **3.47.7 stable**, que inclui Dart **3.13.5**, e Git. Confira `flutter --version` e siga as instruções de instalação do [README](../README.md).

```powershell
git clone https://github.com/HironNovais/fastdelivery-flutter.git
cd fastdelivery-flutter
git checkout v1.0.0
flutter pub get
dart run build_runner build
flutter analyze
flutter test
```

O checkout da tag fixa a versão da entrega. `flutter analyze` e `flutter test` não exigem aparelho conectado nem chamadas reais ao ViaCEP. Resultado observado em 24/10/2026: **41 testes aprovados**. A análise registrada na implementação não apresentou apontamentos; o relatório original está em [VALIDACAO.md](VALIDACAO.md).

Com JDK 17, Android SDK e um Android conectado ou emulador aberto:

```powershell
flutter devices
flutter run -d ID_DO_DISPOSITIVO
```

Substitua `ID_DO_DISPOSITIVO` pelo identificador exibido por `flutter devices`. Para compilar o instalador:

```powershell
flutter build apk --release
```

Saída: `build/app/outputs/flutter-apk/app-release.apk`. O arquivo distribuído é uma cópia desse APK, renomeada para `FastDelivery.apk`.

## Roteiro funcional

| Caso | Ação | Resultado esperado |
| --- | --- | --- |
| Abertura | Iniciar o aplicativo | Splash animada e redirecionamento automático à Home |
| CEP válido | Consultar `01001000` | Praça da Sé, São Paulo/SP, com detalhes e CEP formatado |
| CEP inválido | Consultar `123` | Validação antes de chamar a API |
| CEP inexistente | Consultar `99999999` | Mensagem de resultado não encontrado |
| Busca por endereço | UF `SP`, cidade `São Paulo`, logradouro `Paulista` | Lista de correspondências; escolher uma salva a consulta e mostra detalhes |
| Dados obrigatórios | Omitir UF/cidade ou informar rua com menos de três caracteres | Validação visual sem requisição |
| Histórico | Consultar um CEP e abrir o histórico | Endereço real com data/hora, ordenado do mais recente |
| Persistência | Encerrar o processo, reabrir o app e acessar o histórico | Registro e última consulta preservados |
| Consulta repetida | Consultar novamente o mesmo CEP | Registro atualizado, sem duplicação por CEP |
| Uso offline | Após salvar um endereço, desligar a rede e abrir o histórico | Dados locais identificados e disponíveis; nova consulta remota mostra erro |
| Rota | Abrir um endereço e tocar em Traçar rota | Geocodificação e escolha entre mapas instalados; o mapa utiliza a origem atual |

O ViaCEP não fornece número de imóvel nem coordenadas. O destino da rota é aproximado e precisa ser conferido no mapa. A disponibilidade dos resultados e da geocodificação depende dos serviços externos.

## Evidências disponíveis

- Suíte automatizada executada novamente em **24/10/2026**: 41 testes aprovados.
- Execução nativa realizada no emulador **Android 16 / API 36 / x86_64**.
- Consulta real de `01001000` apresentou Praça da Sé na interface.
- Após encerrar e reabrir o processo Android, o registro continuou no histórico.
- APK release compilado, assinatura APK v2 verificada, instalação e abertura no emulador concluídas.
- O aplicativo ainda precisa de validação em aparelho físico e da abertura de rotas reais nos aplicativos de mapas. Compilação e execução iOS não foram realizadas neste Windows; exigem macOS/Xcode.

## Integridade do APK

Arquivo: `FastDelivery.apk` — **54.070.444 bytes**.

SHA-256:

```text
b166a3a60f5f98df7a840a0012b86d8bb6cf49a800182ad1bb21bdb90203aed1
```

Em PowerShell, a conferência opcional pode ser feita com:

```powershell
Get-FileHash .\FastDelivery.apk -Algorithm SHA256
```

O arquivo `SHA256SUMS.txt` anexado à Release contém o mesmo hash. A compilação local gera um APK funcional, mas seu hash pode variar conforme ambiente e assinatura.
