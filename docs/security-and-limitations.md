# Security, operational constraints, and known limitations

This is a legacy development/sample project. **Do not expose it to a public network or use it with valuable production data without a separate security review.** The documentation changes in this PR do not fix the issues below.

## Findings from source review

| Area | Current state | Recommended follow-up |
| --- | --- | --- |
| Authentication/authorization | Product endpoints have no authentication or authorization checks | Add an explicit authentication and authorization policy |
| Connection configuration | `ShopController.cs` embeds its SQL Server connection details and also has unused hard-coded SQL-login constants | Remove embedded credentials, use external secured configuration, and rotate any reused real passwords |
| Database initialization | Original `DB Scripts/script.sql` drops the database and specifies a machine-specific file path | Use the provided non-destructive local bootstrap; retain backups and review SQL before execution |
| Validation | Product price has no positive-only rule; missing IDs are not checked for existence | Add price range and explicit ID/not-found validation |
| SQL timeout | ADO.NET commands set timeout to zero (unbounded) | Configure finite timeouts and cancellation behavior |
| Error handling | `CustomExceptionFilter.OnException` is empty | Log safely and define consistent error responses |
| API design | `PUT` creates, `PATCH` edits, `DELETE` takes `productID` query parameter | Document a versioned, conventional REST API before redesigning |
| Persistence shape | The legacy `product` table has an identity column without a declared PK | Consider a PK/migrations after checking real deployed data |
| UI | Home page is stock ASP.NET template | Implement a product UI only if required |
| Tests | Existing tests cover starter controllers only | Add product-API and database tests |
| Deployment | No deployment automation or hardened environment profiles identified | Define deployment, TLS, backup, logging and permissions standards |

## Database access safety

The controller's **active** connection uses Windows integrated authentication against SQL Server, not the unused SQL-login constants. The identity running IIS Express needs SQL login/database access and execute permissions. Avoid enabling SQL `sa` or putting passwords in source code.

## Supported claims and open questions

Verified from repository source: .NET Framework 4.8; Web API 2; IIS Express settings; SQL Server ADO.NET; table/procedure names; controller routes and response codes. **Not verified by execution:** dependency restore, SQL bootstrap behavior on a given server version, tests, IIS Express launch, endpoint responses, deployment. These require the review checklist in [testing](testing.md).

No invented performance charts, geographic maps, hosting architecture, or cloud services are included: the repository does not contain data to support them.
