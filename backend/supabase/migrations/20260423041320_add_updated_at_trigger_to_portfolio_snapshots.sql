CREATE TRIGGER update_portfolio_snapshots_updated_at BEFORE
UPDATE ON public.portfolio_snapshots FOR EACH ROW EXECUTE PROCEDURE public.handle_updated_at ();