SELECT
  a.*,
  CASE WHEN a.is_dir = '1' THEN '目录' ELSE '文件' END AS file_type_name
FROM (require('./base.sql')) a
ORDER BY a.is_dir DESC, a.name ASC, a.create_time DESC
