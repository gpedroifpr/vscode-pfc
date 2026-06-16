# 🔧 Configuração da IA - DevStack

## ✅ Correções Implementadas

1. ✅ **Removidas chaves API hardcoded** - Segurança melhorada
2. ✅ **Adicionado suporte a variáveis de ambiente** - Usando `flutter_dotenv`
3. ✅ **Melhorado tratamento de erros** - Mensagens informativas ao usuário
4. ✅ **Validação de chaves** - Verifica se a chave está configurada
5. ✅ **Timeout adicionado** - Evita travamentos

---

## 🚀 Como Fazer Funcionar

### **Passo 1: Gerar Chave API do Google Gemini**

1. Abra: https://aistudio.google.com/app/apikeys
2. Clique em "Create API Key" (ou "New API key")
3. Escolha "Create API key in existing project"
4. **Copie a chave** (Ctrl+C)

### **Passo 2: Configurar Chave no Projeto**

1. Abra o arquivo `.env` na raiz do projeto
2. Substitua `SUA_CHAVE_GEMINI_AQUI` pela sua chave
3. **NÃO commite este arquivo!** (já está no .gitignore)

Exemplo:
```
GEMINI_API_KEY=AIzaSy...sua_chave_aqui...123xyz
```

### **Passo 3: Instalar Dependências**

Execute no terminal:
```bash
flutter pub get
```

### **Passo 4: Executar o Projeto**

```bash
flutter run
```

ou para web:
```bash
flutter run -d web
```

---

## ⚠️ Possíveis Erros e Soluções

### **Erro 429 (Too Many Requests)**
- **Causa**: Limite diário excedido (1000 requisições/dia no plano gratuito)
- **Solução**: 
  - Aguarde até amanhã
  - Ou compre créditos: https://console.cloud.google.com/billing

### **Erro 401 (Chave Inválida)**
- **Causa**: Chave expirada ou digitada errada
- **Solução**: 
  - Gere uma nova em: https://aistudio.google.com/app/apikeys
  - Copie corretamente no `.env`

### **Erro "Chave não configurada"**
- **Causa**: Arquivo `.env` vazio ou não encontrado
- **Solução**: 
  - Verifique se `.env` existe na pasta raiz do projeto
  - Preencheu com sua chave?

### **Erro de Conexão**
- **Causa**: Sem internet ou firewall bloqueando
- **Solução**: 
  - Verifique conexão
  - Tente um VPN se estiver bloqueado na sua região

---

## 📱 Testando a Integração

1. Abra o app
2. Clique no botão **"Ask AI"** (flutuante)
3. Digite uma pergunta, ex: *"Como usar Flutter?"*
4. Aguarde a resposta

Se funcionar, parabéns! 🎉

---

## 🔐 Segurança

- ✅ Chaves **NÃO** estão mais no código
- ✅ Arquivo `.env` está no `.gitignore`
- ✅ Mensagens de erro informativas mas seguras

---

## 📚 Próximos Passos (Opcional)

1. **Adicionar suporte a OpenAI** (implementado, só precisa da chave)
2. **Persistência de conversas** - Salvar em SQLite
3. **Rate limiting no cliente** - Para evitar 429
4. **Feedback do usuário** - Like/Dislike das respostas

---

**Precisa de ajuda?** Verifique os erros no console do app! 🚀
