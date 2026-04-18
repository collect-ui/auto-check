SELECT
  a.file_id,
  a.file_id AS "key",
  a.project_code,
  a.name,
  a.name AS title,
  a.path,
  a.parent_id,
  a.is_dir,
  CASE WHEN a.is_dir = '1' THEN 'FolderOutlined' ELSE 'FileOutlined' END AS icon,
  a.create_time,
  a.modify_time
FROM webshell_workspace_file a
WHERE 1=1
  AND a.is_delete = '0'
  AND a.project_code = {{.project_code}}
ORDER BY a.is_dir DESC, a.name ASC
