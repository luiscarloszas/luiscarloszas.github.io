-- =============================================================================
-- TFS • TRANSPORTES FLORÊNCIO & SILVA
-- Script de Configuração da Base de Dados Supabase (PostgreSQL) - CORRIGIDO
-- =============================================================================

-- 1. LIMPEZA & REPARAÇÃO DO SISTEMA DE AUTENTICAÇÃO (Remove o erro Database error querying schema)
ALTER TABLE IF EXISTS public.clients DROP CONSTRAINT IF EXISTS clients_user_id_fkey;
ALTER TABLE IF EXISTS public.proposals DROP CONSTRAINT IF EXISTS proposals_user_id_fkey;

-- Limpar qualquer registo incompleto que tenha sido inserido manualmente via SQL
DELETE FROM auth.users WHERE email = 'admin@tfs.pt';

-- Normalizar quaisquer tokens NULL existentes na tabela de autenticação
UPDATE auth.users
SET 
  confirmation_token = COALESCE(confirmation_token, ''),
  recovery_token = COALESCE(recovery_token, ''),
  email_change = COALESCE(email_change, ''),
  email_change_token_new = COALESCE(email_change_token_new, ''),
  email_change_token_current = COALESCE(email_change_token_current, ''),
  phone_change = COALESCE(phone_change, ''),
  phone_change_token = COALESCE(phone_change_token, '')
WHERE confirmation_token IS NULL OR recovery_token IS NULL;

-- 2. EXTENSÃO PARA UUIDs & FUNÇÃO AUXILIAR
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

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
    user_id UUID,
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

DROP TRIGGER IF EXISTS tr_clients_updated_at ON public.clients;
CREATE TRIGGER tr_clients_updated_at
    BEFORE UPDATE ON public.clients
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE INDEX IF NOT EXISTS idx_clients_name ON public.clients(name);
CREATE INDEX IF NOT EXISTS idx_clients_nif ON public.clients(nif);
CREATE INDEX IF NOT EXISTS idx_clients_created_at ON public.clients(created_at DESC);

-- =============================================================================
-- 4. TABELA DE PROPOSTAS COMERCIAIS (public.proposals)
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.proposals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID,
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
    status TEXT DEFAULT 'Rascunho',
    created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL
);

DROP TRIGGER IF EXISTS tr_proposals_updated_at ON public.proposals;
CREATE TRIGGER tr_proposals_updated_at
    BEFORE UPDATE ON public.proposals
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE INDEX IF NOT EXISTS idx_proposals_ref ON public.proposals(proposal_ref);
CREATE INDEX IF NOT EXISTS idx_proposals_client_id ON public.proposals(client_id);
CREATE INDEX IF NOT EXISTS idx_proposals_status ON public.proposals(status);
CREATE INDEX IF NOT EXISTS idx_proposals_created_at ON public.proposals(created_at DESC);

-- =============================================================================
-- 5. PERMISSÕES & SEGURANÇA (RLS)
-- =============================================================================
GRANT USAGE ON SCHEMA public TO postgres, anon, authenticated, service_role, supabase_auth_admin;
GRANT ALL ON ALL TABLES IN SCHEMA public TO postgres, anon, authenticated, service_role, supabase_auth_admin;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO postgres, anon, authenticated, service_role, supabase_auth_admin;

ALTER TABLE public.clients ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.proposals ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Acesso total a clientes para autenticados" ON public.clients;
CREATE POLICY "Acesso total a clientes para autenticados"
    ON public.clients FOR ALL
    TO authenticated
    USING (true)
    WITH CHECK (true);

DROP POLICY IF EXISTS "Acesso total a propostas para autenticados" ON public.proposals;
CREATE POLICY "Acesso total a propostas para autenticados"
    ON public.proposals FOR ALL
    TO authenticated
    USING (true)
    WITH CHECK (true);
