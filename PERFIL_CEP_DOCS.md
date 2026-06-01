# 📋 Documentação - Tela de Perfil com Consultor de CEP

## Visão Geral
A tela de perfil agora inclui um **consultor de CEP obrigatório** que permite que os usuários preencham automaticamente seus dados de endereço através da API ViaCEP.

## Funcionalidades Implementadas

### 1. **Dados Pessoais**
- Nome Completo
- Email
- Telefone

### 2. **Endereço com Consultor de CEP** ⭐
- **Campo CEP** (obrigatório, marcado com *)
  - Aceita apenas 8 dígitos
  - Máximo de 8 caracteres
  - Botão de consulta ao lado (lupa)
  
- **Autopreenchimento Automático**
  Após consultar um CEP válido, os campos abaixo são preenchidos automaticamente:
  - Rua
  - Bairro
  - Cidade
  - Estado

- **Campos Adicionais de Endereço**
  - Número (preenchido manualmente)
  - Complemento (opcional)

## Como Usar

### Passo 1: Acessar a Tela de Perfil
- Toque no ícone de **Perfil** na barra de navegação inferior
- Ou navegue pela aba Profile (5º ícone)

### Passo 2: Ativar o Modo de Edição
- Clique no botão **"Editar"** no canto superior direito
- O botão mudará para **"Salvar"** quando estiver em modo de edição

### Passo 3: Preencher os Dados Pessoais
- Nome Completo
- Email
- Telefone

### Passo 4: Consultar CEP
1. Digite um CEP válido (apenas 8 dígitos) no campo CEP
2. Clique no botão de busca (lupa) ao lado do campo
3. O sistema consultará a API ViaCEP
4. Se encontrado, os campos de endereço serão preenchidos automaticamente:
   - ✅ Rua
   - ✅ Bairro
   - ✅ Cidade
   - ✅ Estado

### Passo 5: Completar o Endereço
- Preencha o **Número** do imóvel
- Adicione um **Complemento** se necessário (apartamento, bloco, etc.)

### Passo 6: Salvar o Perfil
- Clique no botão **"Salvar"** para concluir a edição
- O perfil será atualizado

## Validações Implementadas

✅ **CEP inválido**: Exibe erro se o CEP não tem 8 dígitos
❌ **CEP não encontrado**: Mostra mensagem de erro se o CEP não existe na base de dados
🔄 **Carregamento**: Exibe indicador de progresso durante a consulta
📍 **Obrigatoriedade**: O campo CEP é marcado com * indicando que é obrigatório

## Exemplos de CEPs para Teste

| CEP | Cidade | Estado |
|-----|--------|--------|
| 01310100 | São Paulo | SP |
| 20040020 | Rio de Janeiro | RJ |
| 30130100 | Belo Horizonte | MG |
| 70040902 | Brasília | DF |
| 40015800 | Salvador | BA |

## Integração com a Aplicação

A tela de perfil foi integrada ao sistema de navegação existente:
- Aba 4 na barra de navegação inferior
- Ícone de pessoa com contorno
- Acesso rápido ao profile clicando no avatar no header

## API Utilizada

**ViaCEP** - Consultor de CEP Brasileiro
- Endpoint: `https://viacep.com.br/ws/{cep}/json/`
- Tipo: REST API
- Autenticação: Não requerida
- Limite de requisições: 120 por minuto

## Tratamento de Erros

A aplicação trata os seguintes cenários:

1. **Conexão com a Internet**: Se não houver conexão, exibe mensagem de erro
2. **CEP Inválido**: Se o CEP não tiver 8 dígitos, desabilita o botão de busca
3. **CEP Não Encontrado**: Se o CEP não existir na base ViaCEP
4. **Erro de Servidor**: Se houver falha na API

## Benefícios

✨ **Experiência do Usuário Melhorada**
- Menos trabalho manual para preenchimento de endereço
- Validação automática de CEPs
- Interface intuitiva

🎓 **Requisito Acadêmico**
- Implementação de consultor de CEP conforme solicitado pelo professor
- Demonstração de integração com API pública
- Validação de dados em tempo real

## Notas Técnicas

- **Linguagem**: Dart/Flutter
- **Framework**: Flutter
- **Gerenciamento de Estado**: StatefulWidget
- **HTTP Client**: Package `http`
- **Formatação**: Google Fonts (Poppins)
- **Tema**: Dark Mode com acentos Ciano Neon

---

**Status**: ✅ Implementado e Funcional
**Última Atualização**: Maio 2026
