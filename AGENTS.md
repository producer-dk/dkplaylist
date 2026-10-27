# Release policy — user instruction, 2026-10-27

- Website code, UI, features and version changes go to beta first. Deploy them to production only after the user explicitly says OK to that reviewed release.
- Beta: https://beta.dkplaylist.com, Worker dkplaylist-beta, Git branch beta.
- Production: https://dkplaylist.com, Worker dkplaylist, Git branch main.
- BOTH Workers intentionally share D1 dkplaylist-db (c5fa57e9-a29c-49c3-9009-99bc7e4ca59b). This supersedes the earlier separate-database proposal.
- Catalog registrations, edits, recommendations and votes affect both sites immediately. Never treat beta data as disposable or insert dummy/test data into the shared database.
- User-approved data work can be applied directly to the shared DB; it does not authorize production code deployment. The 448-broadcast catalog import was explicitly approved with the switch to a shared DB.
- Preserve users, sessions, votes and existing gear IDs. Never replace the shared DB with a beta snapshot. Schema changes must remain backward compatible with production code until promotion.
- Default configuration and code pushes target beta. Do not push code to main, modify production Worker bindings or deploy production without explicit release approval.
- Finish implementation and beta verification, then report the beta URL and changes for the user's review. Approval applies only to that release, not future changes.
