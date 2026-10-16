# API reference

Base route: `/api/Shop` (as configured in `ShopBridge/App_Start/WebApiConfig.cs`). Replace the example `http://localhost:26536` base URL with the port assigned by Visual Studio.

> These endpoints describe current controller code. Examples are illustrative; no live integration test was executed while preparing this documentation.

## Endpoints

| Operation | Verb | URL | Controller method | SQL procedure | Success status |
| --- | --- | --- | --- | --- | --- |
| Read products | `GET` | `/api/Shop` | `GetProduct` | `dbo.list` | `200 OK` |
| Add product | `PUT` | `/api/Shop` | `AddItem` | `dbo.p_addItem` | `201 Created` |
| Edit product | `PATCH` | `/api/Shop` | `UpdateItem` | `dbo.p_updateItem` | `202 Accepted` |
| Delete product | `DELETE` | `/api/Shop?productID=1` | `DeleteItem` | `dbo.p_deleteItem` | `202 Accepted` |

This API uses **PUT to create**, which is an implementation choice rather than the typical `POST` convention. Do not silently substitute `POST`. The `ValuesController` is generated sample scaffolding; it does not manage the product table.

## Product payload

```json
{
  "Product_ID": 1,
  "ProductName": "Sample item",
  "ProductDescription": "Example description",
  "ProductPrice": 199.99
}
```

| Property | Type | Validation | Used by |
| --- | --- | --- | --- |
| `Product_ID` | number (`decimal` in C#) | No model annotation; maps to SQL `int` | Update (delete uses query parameter instead) |
| `ProductName` | string | Required; length 3–100 | Add, update |
| `ProductDescription` | string | Optional | Add, update |
| `ProductPrice` | number (`decimal` in C#) | Required annotation only | Add, update |

**Validation caveat:** `[Required]` on a non-nullable `decimal` does not ensure a positive price or distinguish a missing JSON field from the default `0`. The controller does not verify product existence before updating/deleting.

## Sample requests

Create:

```http
PUT /api/Shop HTTP/1.1
Host: localhost:26536
Content-Type: application/json
Accept: application/json

{
  "ProductName": "Desk lamp",
  "ProductDescription": "Warm white LED",
  "ProductPrice": 499.00
}
```

Update:

```http
PATCH /api/Shop HTTP/1.1
Host: localhost:26536
Content-Type: application/json
Accept: application/json

{
  "Product_ID": 1,
  "ProductName": "Desk lamp",
  "ProductDescription": "Updated LED model",
  "ProductPrice": 549.00
}
```

Delete:

```http
DELETE /api/Shop?productID=1 HTTP/1.1
Host: localhost:26536
Accept: application/json
```

List:

```http
GET /api/Shop HTTP/1.1
Host: localhost:26536
Accept: application/json
```

The GET response is serialized from an ADO.NET `DataTable` with the database column names (`product_id`, `name`, `description`, `price`); exact formatting depends on the negotiated serializer. Write responses contain a string such as `Rows affected are 1`; exact affected-row counts depend on SQL Server behavior and the existing data.

## Errors and API caveats

- Bad add/update model: `400 Bad Request` with model errors from the controller.
- SQL errors: not translated into domain-specific error objects; runtime may return server errors.
- Delete invokes a stored procedure with `productID` from the query string. A missing/invalid ID is not explicitly handled with a friendly 400 in the controller.
- No authentication, authorization, request versioning, pagination, pagination metadata, or OpenAPI/Swagger definition is implemented.
- The controller applies `[HttpPatch]` to update, so a REST client and any intermediary must support PATCH.

Run the checked-in examples from [`examples/ShopBridge.http`](../examples/ShopBridge.http) or use the manual test checklist in [testing](testing.md).
