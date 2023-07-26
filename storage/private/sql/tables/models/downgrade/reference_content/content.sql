-- model downgrade (base + contents + reference contents -> base + contents)
-- Author: Julio María Meca Hansen <jmecahansen@gmail.com>

-- bootstrapping
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS m_%MODEL%_refs_cnts;
DROP TRIGGER IF EXISTS t_%MODEL%_refs_cnts_evnt_delt;
DROP TRIGGER IF EXISTS t_%MODEL%_refs_cnts_evnt_updt;
DROP TABLE IF EXISTS m_%MODEL%_refs_cnts_elem;
DROP TRIGGER IF EXISTS t_%MODEL%_refs_cnts_elem_evnt_delt;
DROP TRIGGER IF EXISTS t_%MODEL%_refs_cnts_elem_evnt_updt;
DROP TABLE IF EXISTS m_%MODEL%_refs_cnts_elem_revs;
DROP TRIGGER IF EXISTS t_%MODEL%_refs_cnts_elem_revs_evnt_delt;
DROP TRIGGER IF EXISTS t_%MODEL%_refs_cnts_elem_revs_evnt_updt;
SET FOREIGN_KEY_CHECKS = 1;