# 🚛 TFS • Simulador Comercial & Custos de Transporte

> **Transportes Florêncio & Silva (TFS)**  
> Plataforma comercial de cálculo de custos operacionais, simulação de tarifas, margens de rentabilidade e gestão de clientes e propostas comerciais conectada ao **Supabase**.

---

## 🌟 Funcionalidades Principais

- **7 Perfis de Frota Editáveis:** Articulados frigoríficos e lona (DAF + Schmitz), rígidos de 23p, 20p e 14p, e ligeiros 3.5t.
- **Estrutura Completa de Custos:**
  - **CapEx & Financiamento:** Valor de trator, semirreboque/caixa, equipamentos, meses de amortização, valor residual e taxas de juro.
  - **Custos Fixos:** Motoristas (diurnos e acréscimos noturnos), seguros, IUC, IPO/ATP, telemetria/GPS e estrutura central.
  - **Custos Variáveis:** Consumo de combustível, indexação de gasóleo profissional (-0,18 €/L), cálculo automático de AdBlue (5%), manutenção/km, pneus, grupo de frio, lavagens ATP e portagens.
- **Regimes Operacionais:** 1 Turno Diurno, Operação 24h (2 Motoristas) e 24h/7d Contínuo (3 Motoristas).
- **3 Modalidades de Faturação ao Cliente:**
  1. **Modelo Híbrido:** Diária Fixa + Tarifa Variável por Km (recomendado).
  2. **100% ao Quilómetro:** Tarifa única por km com diluição de custos fixos.
  3. **100% à Diária (Plafond):** Diária fechada com franquia de km e taxa para quilómetros excedentes.
- **Proteção Comercial com Piso de 5,0%:** Travão automático que impede a aplicação de descontos comerciais que reduzam a margem líquida real abaixo do piso mínimo de rentabilidade.
- **Multiplicador de Frota & KPIs Executivos:** Projeção de 1 a 100+ viaturas com faturação anual, EBITDA consolidado, lucro líquido, cálculo de motoristas com margem de reserva (10%), break-even em km/dia e payback do CapEx.
- **Autenticação Segura & Sessão Permanente (Supabase Auth):**
  - Acesso restrito com email e palavra-passe.
  - **Sem registo público na página de login:** a criação e gestão de utilizadores é realizada internamente dentro do dashboard.
  - Sessão persistente: ao abrir a página, a conexão mantém-se ativa automaticamente sem necessidade de digitar credenciais a cada acesso.
- **Gestão de Clientes no Supabase:** Registo de empresas, NIF/NIPC, contactos, emails, telefones e moradas com associação direta às propostas comerciais.
- **Histórico & Gestão de Propostas no Supabase:**
  - Gravação de propostas com referência única (ex.: `TFS-2026-XXXX`).
  - Estados da proposta: *Rascunho*, *Apresentada*, *Em Negociação*, *Aprovada*, *Recusada*.
  - Carregamento instantâneo dos parâmetros de qualquer proposta guardada de volta para o simulador.
  - Documento oficial pronto a copiar e enviar ao cliente.

---

## 📁 Estrutura do Projeto

```text
├── index.html                   # Aplicação completa (Frontend, Cálculos, Interface e Supabase)
├── schema.sql                   # Script SQL com as tabelas, índices e políticas de RLS no Supabase
├── supabase-config.js           # Credenciais locais do Supabase (ignorado no Git)
├── supabase-config.example.js   # Exemplo de configuração para versionamento no Git
├── .env                         # Variáveis de ambiente locais (ignorado no Git)
├── .env.example                 # Exemplo de variáveis de ambiente para o GitHub
├── .gitignore                   # Ficheiros ignorados pelo Git (segurança)
└── README.md                    # Manual completo de utilização e configuração
```

---

## 🚀 Guia de Configuração e Instalação

### 1. Criar e Configurar o Projeto no Supabase

1. Aceda a [https://supabase.com](https://supabase.com) e crie uma conta ou inicie sessão.
2. Crie um novo projeto (ex.: `TFS-Simulador-Comercial`).
3. Obtenha as credenciais da API em **Project Settings** > **API**:
   - **Project URL:** `https://[seu-projeto].supabase.co`
   - **Project API Keys:** utilize a chave `anon` ou `publishable`.  
     *(⚠️ NUNCA utilize a chave `service_role` no frontend)*.

### 2. Criar as Tabelas e Políticas de Segurança (SQL Editor)

1. No painel do Supabase, clique no menu **SQL Editor** na barra lateral.
2. Crie uma **New Query**.
3. Abra o ficheiro `schema.sql` deste projeto, copie todo o seu conteúdo, cole no SQL Editor e clique em **RUN**.
4. Este script irá criar:
   - A tabela `public.clients` (com gatilhos de data e índices de pesquisa).
   - A tabela `public.proposals` (com métricas, textos e parâmetros de simulação).
   - As políticas de segurança **Row Level Security (RLS)** para garantir que apenas utilizadores autenticados possam consultar e manipular os dados.

### 3. Criar o Primeiro Utilizador (Administrador)

Como o formulário de login foi concebido **sem opção de registo público** por motivos de segurança interna corporativa, crie o primeiro utilizador no painel do Supabase:

1. No painel do Supabase, vá a **Authentication** > **Users**.
2. Clique em **Add User** > **Create User**.
3. Indique o email corporativo (ex.: `comercial@tfs.pt`) e uma palavra-passe segura.
4. Confirme a criação.
5. Pronto! Agora já pode iniciar sessão na aplicação com este utilizador.
6. **Novos utilizadores:** Uma vez dentro do simulador, pode registar novos colaboradores diretamente pelo botão **👥 Utilizadores** no cabeçalho executivo.

### 4. Configurar as Credenciais no Projeto

Tem três formas práticas de configurar as credenciais:

#### Opção A: Ficheiro `supabase-config.js` (Recomendado para uso local)
Copie o ficheiro de exemplo e insira os seus dados:
```bash
cp supabase-config.example.js supabase-config.js
```
Edite o ficheiro `supabase-config.js`:
```javascript
window.SUPABASE_CONFIG = {
  url: 'https://seu-projeto.supabase.co',
  anonKey: 'sua-chave-publica-anon'
};
```
*(Este ficheiro está no `.gitignore` e não será enviado para o GitHub).*

#### Opção B: Ficheiro `.env`
Se utilizar um servidor local (como Live Server, Vite ou Python):
```env
projetct_url='https://seu-projeto.supabase.co'
public_key='sua-chave-publica-anon'
```

#### Opção C: Diretamente pela Interface
Ao abrir o `index.html` no browser, na tela de login clique em **⚙️ Configurar Base de Dados**. Introduza o URL e a Chave Pública. Os dados são guardados de forma segura no `localStorage` do seu navegador e a **conexão fica sempre ativa** nas próximas vezes.

---

## 🔒 Segurança de Credenciais & Publicação no GitHub

O projeto já se encontra preparado para publicação segura no GitHub:

1. O ficheiro `.gitignore` já está configurado para **proteger os ficheiros confidenciais**:
   - `.env`
   - `supabase-config.js`
2. **Passos para enviar para o GitHub:**

```bash
# Inicializar o repositório git (se ainda não o tiver feito)
git init

# Adicionar os ficheiros protegidos
git add .

# Criar o primeiro commit
git commit -m "feat: Simulador Comercial TFS com autenticação e base de dados Supabase"

# Associar ao repositório remoto no GitHub
git branch -M main
git remote add origin https://github.com/SEU_UTILIZADOR/SEU_REPOSITORIO.git

# Enviar os dados
git push -u origin main
```

---

## 💡 Como Utilizar no Dia a Dia

1. **Abrir a Aplicação:** Abra o ficheiro `index.html` em qualquer navegador web moderno.
2. **Iniciar Sessão:** Insira o seu email e palavra-passe. A sessão permanece guardada de forma persistente.
3. **Gerir Clientes:**
   - Clique em **🏢 Clientes** no cabeçalho para consultar, pesquisar, registar ou editar empresas clientes.
4. **Simular a Operação:**
   - Escolha o perfil da viatura pretendida ou crie um novo perfil personalizado.
   - Ajuste os quilómetros da rota, regime de turnos e margem comercial.
   - Selecione a modalidade de faturação contratual (Híbrido, Ao Km ou Diária com Plafond).
   - Associe o cliente no bloco da **Proposta Comercial TFS**.
5. **Guardar e Partilhar Propostas:**
   - Clique em **💾 Guardar no Supabase** para armazenar a proposta com uma referência oficial.
   - Aceda a **📂 Propostas** para ver o histórico, alterar o estado (Apresentada, Aprovada, etc.) ou recarregar os parâmetros de uma simulação anterior com 1 clique.
6. **Gerir Colaboradores:**
   - No botão **👥 Utilizadores**, qualquer utilizador autenticado pode alterar a sua própria palavra-passe ou criar novos acessos para colegas da equipa comercial.

---

## 🛠️ Tecnologias Utilizadas

- **HTML5 & Vanilla JavaScript (ES6+):** Código limpo, rápido e sem necessidade obrigatória de compilação ou Node.js.
- **Tailwind CSS (CDN):** Interface moderna, executiva e responsiva adaptada a qualquer ecrã e impressão.
- **Supabase (PostgreSQL & Auth):** Base de dados em nuvem, gestão de acessos com JWT e políticas de segurança RLS.
- **Google Fonts (Inter):** Tipografia profissional de alta legibilidade.

---

## 📄 Licença e Confidencialidade

Projeto desenvolvido para a **Transportes Florêncio & Silva (TFS)**. Todos os direitos reservados.
