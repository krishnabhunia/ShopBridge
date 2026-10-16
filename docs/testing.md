# Testing and verification

## Existing automated tests

The repository contains an MSTest test project targeting .NET Framework 4.8:
- `ShopBridge.Tests/Controllers/HomeControllerTest.cs` checks that the MVC home action returns a view and expected title.
- `ShopBridge.Tests/Controllers/ValuesControllerTest.cs` covers generated template methods (`Get`, `GetById`, `Post`, `Put`, `Delete`).

These tests **do not exercise product CRUD, SQL Server, or the real `ShopController`**. There is no existing production integration-test suite to demonstrate database-backed success.

## Run the existing tests

1. Open `ShopBridge.sln` in Visual Studio on Windows.
2. Restore NuGet packages for both the web and test projects.
3. Build in `Debug` or `Release`.
4. Open **Test Explorer** and select **Run All Tests**. The project references MSTest 1.2.0 packages.
5. Record failures and environment details; do not assume passing results without running them.

## Automated GitHub Actions checks

The `ShopBridge build and tests` workflow (`.github/workflows/build-and-test.yml`) runs on a Windows Server 2022 GitHub-hosted runner. It restores NuGet packages, compiles the .NET Framework 4.8 solution, runs the existing MSTest suite, then invokes `ci/test-sql-localdb.ps1` on a disposable Microsoft SQL Server LocalDB instance.

The LocalDB check actually executes `DB Scripts/setup-safe.sql` twice and tests schema creation, the four SQL stored procedures, and existing-row preservation after re-running setup. It **does not launch IIS Express or exercise product API endpoints over HTTP**; the local application runtime must still be manually smoke-tested using the checklist below.

Check the **Actions / Checks** tabs on the pull request for run statuses. A workflow definition alone is not proof that a test passed.

## Manual API validation (local database only)

Run [the non-destructive SQL bootstrap](../DB%20Scripts/setup-safe.sql), then start IIS Express. Replace the sample port with the actual port.

| Step | Request | Expected high-level observation |
| --- | --- | --- |
| 1 | `GET /api/Shop` | 200; products list (possibly empty) |
| 2 | `PUT /api/Shop` with valid JSON | 201; affected-rows message |
| 3 | `GET /api/Shop` | Added product appears |
| 4 | `PATCH /api/Shop` with product ID + new values | 202; affected-rows message |
| 5 | `GET /api/Shop` | Updated values appear |
| 6 | `PUT /api/Shop` with `ProductName` shorter than 3 chars | 400; model validation errors |
| 7 | `DELETE /api/Shop?productID=...` | 202; affected-rows message |
| 8 | `GET /api/Shop` | Deleted product no longer appears |

Use a disposable database: the test sequence changes local product rows. The examples and success codes are based on source inspection and should be confirmed in the target environment.

## Documentation review checklist

- [ ] All linked Markdown files render correctly on GitHub.
- [ ] Mermaid diagrams render in the GitHub PR.
- [ ] The default-branch SQL script's destructive behavior is prominently noted.
- [ ] Commands do not disclose credentials or claim cloud deployment support.
- [ ] SQL bootstrap is reviewed and tested on a fresh **local** SQL Server.
- [ ] Existing MSTest tests are actually run on Windows.
- [ ] API smoke tests are exercised against the configured IIS Express URL.

## Good follow-up tests

Add isolated tests for product validation, SQL failure handling, create/update/delete not-found behavior, authentication policy (once added), and a disposable SQL Server integration-test fixture. Such runtime changes are **out of scope** for this documentation pilot.
