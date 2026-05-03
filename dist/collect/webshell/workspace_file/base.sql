SELECT
  a.*,
  CASE
    WHEN (
      SELECT c.project_dir
      FROM webshell_workspace_project c
      WHERE c.project_code = a.project_code AND c.is_delete = '0'
      ORDER BY c.modify_time DESC
      LIMIT 1
    ) IS NOT NULL
      AND (
        SELECT c.project_dir
        FROM webshell_workspace_project c
        WHERE c.project_code = a.project_code AND c.is_delete = '0'
        ORDER BY c.modify_time DESC
        LIMIT 1
      ) != ''
      AND a.path LIKE (
        SELECT c.project_dir
        FROM webshell_workspace_project c
        WHERE c.project_code = a.project_code AND c.is_delete = '0'
        ORDER BY c.modify_time DESC
        LIMIT 1
      ) || '/%'
      THEN substr(a.path, length((
        SELECT c.project_dir
        FROM webshell_workspace_project c
        WHERE c.project_code = a.project_code AND c.is_delete = '0'
        ORDER BY c.modify_time DESC
        LIMIT 1
      )) + 1)
    ELSE a.path
  END AS path_display
FROM webshell_workspace_file a
WHERE 1=1
  AND a.is_delete = '0'
{{ if .project_code }}
  AND a.project_code = {{.project_code}}
{{ end }}
{{ if .name }}
  AND a.name LIKE {{.name}}
{{ end }}
{{ if .keyword }}
  AND (
    a.name LIKE {{.keyword}}
    OR a.path LIKE {{.keyword}}
    OR (
      CASE
        WHEN (
          SELECT c.project_dir
          FROM webshell_workspace_project c
          WHERE c.project_code = a.project_code AND c.is_delete = '0'
          ORDER BY c.modify_time DESC
          LIMIT 1
        ) IS NOT NULL
          AND (
            SELECT c.project_dir
            FROM webshell_workspace_project c
            WHERE c.project_code = a.project_code AND c.is_delete = '0'
            ORDER BY c.modify_time DESC
            LIMIT 1
          ) != ''
          AND a.path LIKE (
            SELECT c.project_dir
            FROM webshell_workspace_project c
            WHERE c.project_code = a.project_code AND c.is_delete = '0'
            ORDER BY c.modify_time DESC
            LIMIT 1
          ) || '/%'
          THEN substr(a.path, length((
            SELECT c.project_dir
            FROM webshell_workspace_project c
            WHERE c.project_code = a.project_code AND c.is_delete = '0'
            ORDER BY c.modify_time DESC
            LIMIT 1
          )) + 1)
        ELSE a.path
      END
    ) LIKE {{.keyword}}
  )
{{ end }}
{{ if .parent_id }}
  AND a.parent_id = {{.parent_id}}
{{ end }}
{{ if .root_only }}
  AND (a.parent_id = '' OR a.parent_id = '0' OR a.parent_id IS NULL)
{{ end }}
{{ if .is_dir }}
  AND a.is_dir = {{.is_dir}}
{{ end }}
{{ if .path_exact }}
  AND a.path = {{.path_exact}}
{{ end }}
{{ if .exclude_file_id }}
  AND a.file_id != {{.exclude_file_id}}
{{ end }}
{{ if .pagination }}
LIMIT {{.start}}, {{.size}}
{{ end }}
