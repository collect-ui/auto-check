# Go Model `ID` Naming Rule

## Purpose

This project has repeated regressions caused by model field names using `Id` instead of `ID`.
When database columns are `*_id`, Go model fields must use `ID` in the identifier name.

This rule is mandatory for generated models and manually edited models.

## Mandatory Rules

1. If DB column name is `*_id`, the Go field name must end with `ID` (all caps).
2. Never use `Id` or `iD` in Go model field names.
3. Keep gorm/json tags mapped to snake_case DB columns as-is.
4. Apply the same rule to combined names such as `WxSyncUserID`, `DocProjectID`.

## Examples

Correct:

```go
AgencyID       string `gorm:"column:agency_id" json:"agency_id"`
UserID         string `gorm:"column:user_id" json:"user_id"`
DepartmentID   string `gorm:"column:department_id" json:"department_id"`
RoleID         string `gorm:"column:role_id" json:"role_id"`
CompanyID      string `gorm:"column:company_id" json:"company_id"`
WxSyncUserID   string `gorm:"column:wx_sync_user_id" json:"wx_sync_user_id"`
```

Incorrect:

- `AgencyId`
- `UserId`
- `DepartmentId`
- `RoleId`
- `CompanyId`
- `WxSyncUserId`

## Checklist Before Commit

1. Check all `*_id` columns in changed model files use `ID` in Go field names.
2. Check `gorm:"column:xxx_id"` and `json:"xxx_id"` tags remain unchanged.
3. If model is regenerated, re-check naming after generation.
4. If model is manually edited, run a quick search for `Id` in the edited model file.

## Why This Matters

`ID`/`Id` inconsistency causes mapping drift across model fields, template params, and update logic.
This can lead to values not being written back or not being read from cache correctly.
