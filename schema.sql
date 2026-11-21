-- =============================================================================
-- TFS • TRANSPORTES FLORÊNCIO & SILVA
-- Script de Configuração da Base de Dados Supabase (PostgreSQL)
-- =============================================================================
-- Instruções:
-- 1. Abra o painel do seu projeto no Supabase: https://supabase.com/dashboard
-- 2. Vá ao menu "SQL Editor" na barra lateral esquerda.
-- 3. Crie uma "New Query", cole todo o conteúdo deste ficheiro e clique em "RUN".
-- =============================================================================

-- 1. EXTENSÃO PARA UUIDs
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. FUNÇÃO AUXILIAR PARA ATUALIZAR TIMESTAMP
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = timezone('utc'::text, now());
    RETURN NEW;
END;
$$ language 'plpgsql';

-- =============================================================================
-- 3. TABELA DE CLIENTES (public.clients)
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.clients (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    name TEXT NOT NULL,
    nif TEXT,
    contact_person TEXT,
    email TEXT,
    phone TEXT,
    address TEXT,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Trigger para updated_at em clients
DROP TRIGGER IF EXISTS tr_clients_updated_at ON public.clients;
CREATE TRIGGER tr_clients_updated_at
    BEFORE UPDATE ON public.clients
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Índices para pesquisa rápida
CREATE INDEX IF NOT EXISTS idx_clients_name ON public.clients(name);
CREATE INDEX IF NOT EXISTS idx_clients_nif ON public.clients(nif);
CREATE INDEX IF NOT EXISTS idx_clients_created_at ON public.clients(created_at DESC);

-- =============================================================================
-- 4. TABELA DE PROPOSTAS COMERCIAIS (public.proposals)
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.proposals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    client_id UUID REFERENCES public.clients(id) ON DELETE SET NULL,
    client_name TEXT,
    proposal_ref TEXT NOT NULL,
    profile_id TEXT,
    profile_name TEXT,
    shift_mode TEXT,
    shift_label TEXT,
    billing_mode TEXT,
    sim_km NUMERIC,
    fleet_size INTEGER DEFAULT 1,
    discount_pct NUMERIC DEFAULT 0,
    fuel_price NUMERIC,
    daily_fixed NUMERIC DEFAULT 0,
    rate_per_km NUMERIC DEFAULT 0,
    daily_base_price NUMERIC DEFAULT 0,
    daily_extra_rate NUMERIC DEFAULT 0,
    daily_rev_day NUMERIC DEFAULT 0,
    fleet_rev_year NUMERIC DEFAULT 0,
    fleet_ebitda_year NUMERIC DEFAULT 0,
    net_margin_pct NUMERIC DEFAULT 0,
    proposal_text TEXT,
    simulation_params JSONB,
    status TEXT DEFAULT 'Rascunho', -- 'Rascunho', 'Apresentada', 'Em Negociação', 'Aprovada', 'Recusada'
    created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Trigger para updated_at em proposals
DROP TRIGGER IF EXISTS tr_proposals_updated_at ON public.proposals;
CREATE TRIGGER tr_proposals_updated_at
    BEFORE UPDATE ON public.proposals
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Índices para pesquisa e filtragem de propostas
CREATE INDEX IF NOT EXISTS idx_proposals_ref ON public.proposals(proposal_ref);
CREATE INDEX IF NOT EXISTS idx_proposals_client_id ON public.proposals(client_id);
CREATE INDEX IF NOT EXISTS idx_proposals_status ON public.proposals(status);
CREATE INDEX IF NOT EXISTS idx_proposals_created_at ON public.proposals(created_at DESC);

-- =============================================================================
-- 5. SEGURANÇA E POLÍTICAS DE ACESSO (Row Level Security - RLS)
-- =============================================================================
-- Ativação da RLS para garantir que apenas utilizadores autenticados tenham acesso aos dados
ALTER TABLE public.clients ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.proposals ENABLE ROW LEVEL SECURITY;

-- Políticas para a tabela CLIENTS (utilizadores autenticados podem ver, criar, atualizar e eliminar)
DROP POLICY IF EXISTS "Autenticados podem ler clientes" ON public.clients;
CREATE POLICY "Autenticados podem ler clientes"
    ON public.clients FOR SELECT
    TO authenticated
    USING (true);

DROP POLICY IF EXISTS "Autenticados podem inserir clientes" ON public.clients;
CREATE POLICY "Autenticados podem inserir clientes"
    ON public.clients FOR INSERT
    TO authenticated
    WITH CHECK (auth.role() = 'authenticated');

DROP POLICY IF EXISTS "Autenticados podem atualizar clientes" ON public.clients;
CREATE POLICY "Autenticados podem atualizar clientes"
    ON public.clients FOR UPDATE
    TO authenticated
    USING (auth.role() = 'authenticated');

DROP POLICY IF EXISTS "Autenticados podem eliminar clientes" ON public.clients;
CREATE POLICY "Autenticados podem eliminar clientes"
    ON public.clients FOR DELETE
    TO authenticated
    USING (auth.role() = 'authenticated');

-- Políticas para a tabela PROPOSALS (utilizadores autenticados podem ver, criar, atualizar e eliminar)
DROP POLICY IF EXISTS "Autenticados podem ler propostas" ON public.proposals;
CREATE POLICY "Autenticados podem ler propostas"
    ON public.proposals FOR SELECT
    TO authenticated
    USING (true);

DROP POLICY IF EXISTS "Autenticados podem inserir propostas" ON public.proposals;
CREATE POLICY "Autenticados podem inserir propostas"
    ON public.proposals FOR INSERT
    TO authenticated
    WITH CHECK (auth.role() = 'authenticated');

DROP POLICY IF EXISTS "Autenticados podem atualizar propostas" ON public.proposals;
CREATE POLICY "Autenticados podem atualizar propostas"
    ON public.proposals FOR UPDATE
    TO authenticated
    USING (auth.role() = 'authenticated');

DROP POLICY IF EXISTS "Autenticados podem eliminar propostas" ON public.proposals;
CREATE POLICY "Autenticados podem eliminar propostas"
    ON public.proposals FOR DELETE
    TO authenticated
    USING (auth.role() = 'authenticated');

-- =============================================================================
-- FIM DO SCRIPT
-- =============================================================================
